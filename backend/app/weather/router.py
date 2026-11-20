from datetime import datetime
from typing import Annotated, Literal
from zoneinfo import ZoneInfo

import httpx
from fastapi import APIRouter, HTTPException, Query
from fastapi.responses import JSONResponse

from app.weather.client import TZ, get_hourly_with_meta
from app.weather.scoring import best_window, clothing_tips, score_hour, window_label, window_warnings


class UTF8JSONResponse(JSONResponse):
    media_type = "application/json; charset=utf-8"


router = APIRouter(prefix="/weather", tags=["weather"], default_response_class=UTF8JSONResponse)


@router.get("/score")
def get_score(
    lat: Annotated[float, Query(ge=-90, le=90)],
    lon: Annotated[float, Query(ge=-180, le=180)],
    activity: Literal["bike", "walk"],
    day: Literal["today", "tomorrow"] = "today",
):
    try:
        h, fetched_at, stale = get_hourly_with_meta(lat, lon, days=2 if day == "tomorrow" else 1)
    except httpx.HTTPError:
        raise HTTPException(status_code=503, detail="Hava durumu servisine ulaşılamadı")

    if day == "tomorrow":
        h = {key: values[24:] for key, values in h.items()}

    times = h["time"]
    feels = h["apparent_temperature"]
    wind = h["wind_speed_10m"]
    rain = h["precipitation_probability"]
    uv = h["uv_index"]
    hours = [int(t[11:13]) for t in times]

    scores = [score_hour(feels[i], wind[i], rain[i], uv[i], activity, hours[i])
              for i in range(len(times))]

    now_key = datetime.now(ZoneInfo("Europe/Istanbul")).strftime("%Y-%m-%dT%H:00")
    now_i = times.index(now_key) if now_key in times else None

    # Bugün için sadece şu andan sonrasına bak
    start = now_i if (day == "today" and now_i is not None) else 0
    window = best_window(times, scores, start=start)
    best, warnings = None, []
    if window:
        w_start, w_end = window
        label = window_label(times, w_start, w_end)
        best = {"start": label[:5], "end": label[-5:]}
        warnings = window_warnings(feels, rain, uv, w_start, w_end)

    return {
        "activity": activity,
        "day": day,
        "updated_at": datetime.fromtimestamp(fetched_at, TZ).strftime("%H:%M"),
        "stale": stale,
        "now": {
            "time": times[now_i][11:16],
            "score": scores[now_i],
            "tips": clothing_tips(feels[now_i], wind[now_i], rain[now_i], uv[now_i],
                                  activity, hours[now_i]),
        } if now_i is not None else None,
        "best_window": best,
        "warnings": warnings,
        "hourly": [
            {"time": times[i][11:16], "score": scores[i], "feels_like": feels[i],
             "wind": wind[i], "rain_prob": rain[i], "uv": uv[i]}
            for i in range(len(times))
        ],
    }

@router.get("/week")
def get_week(
    lat: Annotated[float, Query(ge=-90, le=90)],
    lon: Annotated[float, Query(ge=-180, le=180)],
    activity: Literal["bike", "walk"],
):
    """7 günlük tahmin: her gün için en yüksek skor ve en iyi 2 saatlik zaman."""
    try:
        h, fetched_at, stale = get_hourly_with_meta(lat, lon, days=7)
    except httpx.HTTPError:
        raise HTTPException(status_code=503, detail="Hava durumu servisine ulaşılamadı")

    times = h["time"]
    feels = h["apparent_temperature"]
    hours = [int(t[11:13]) for t in times]
    scores = [score_hour(feels[i], h["wind_speed_10m"][i], h["precipitation_probability"][i],
                         h["uv_index"][i], activity, hours[i]) for i in range(len(times))]
    now_key = datetime.now(TZ).strftime("%Y-%m-%dT%H:00")

    days = []
    for d in range(0, len(times), 24):
        end = min(d + 24, len(times))
        start = d
        if d == 0 and now_key in times[d:end]:
            start = times.index(now_key)
        window = best_window(times[:end], scores[:end], start=start)
        daytime = [scores[i] for i in range(d, end) if 6 <= hours[i] < 22] or scores[d:end]
        day_feels = feels[d:end]
        days.append({
            "date": times[d][:10],
            "max_score": max(daytime),
            "min_feels_like": min(day_feels),
            "max_feels_like": max(day_feels),
            "best_window": ({"start": times[window[0]][11:16],
                             "end": window_label(times, *window)[-5:]} if window else None),
        })

    return {
        "activity": activity,
        "updated_at": datetime.fromtimestamp(fetched_at, TZ).strftime("%H:%M"),
        "stale": stale,
        "days": days,
    }
