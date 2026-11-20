import time
from datetime import datetime
from zoneinfo import ZoneInfo

import httpx

URL = "https://api.open-meteo.com/v1/forecast"
CACHE_TTL_SECONDS = 30 * 60
STALE_MAX_SECONDS = 6 * 60 * 60
TZ = ZoneInfo("Europe/Istanbul")

_cache: dict[tuple[float, float, int, str], tuple[float, dict]] = {}


def _today() -> str:
    return datetime.now(TZ).date().isoformat()


def _cache_key(lat, lon, days):
    # Tarih de anahtarda: gece yarısından sonra dünün verisi dönmesin.
    return (round(lat, 2), round(lon, 2), days, _today())


def clear_cache() -> None:
    _cache.clear()


def get_hourly_with_meta(lat, lon, days=1):
    """(veri, alındığı zaman, eski_mi). Open-Meteo çökerse 6 saatten yeni kaydı stale=True ile döndürür."""
    key = _cache_key(lat, lon, days)
    hit = _cache.get(key)
    now = time.time()
    if hit is not None and now - hit[0] < CACHE_TTL_SECONDS:
        return hit[1], hit[0], False
    params = {
        "latitude": lat,
        "longitude": lon,
        "hourly": "apparent_temperature,wind_speed_10m,precipitation_probability,uv_index",
        "timezone": "Europe/Istanbul",
        "forecast_days": days,
    }
    try:
        response = httpx.get(URL, params=params, timeout=10)
        response.raise_for_status()
        data = response.json()["hourly"]
    except httpx.HTTPError:
        if hit is not None and now - hit[0] < STALE_MAX_SECONDS:
            return hit[1], hit[0], True
        raise
    _cache[key] = (now, data)
    return data, now, False


def get_hourly(lat, lon, days=1):
    return get_hourly_with_meta(lat, lon, days)[0]
