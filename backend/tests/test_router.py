import httpx
import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient

import app.weather.router as weather_router


def fake_hourly(days, feels_by_day=(18.0, 35.0)):
    """Open-Meteo yerine kullanılan sahte veri: her gün 24 saat."""
    times, feels = [], []
    for d in range(days):
        for h in range(24):
            times.append(f"2000-01-{1 + d:02d}T{h:02d}:00")
            feels.append(feels_by_day[d % len(feels_by_day)])
    n = len(times)
    return {
        "time": times,
        "apparent_temperature": feels,
        "wind_speed_10m": [5.0] * n,
        "precipitation_probability": [0] * n,
        "uv_index": [2.0] * n,
    }


@pytest.fixture
def client(monkeypatch):
    calls = []

    def fake_get_hourly(lat, lon, days=1):
        calls.append(days)
        return fake_hourly(days), 0.0, False

    monkeypatch.setattr(weather_router, "get_hourly_with_meta", fake_get_hourly)
    app = FastAPI()
    app.include_router(weather_router.router)
    test_client = TestClient(app)
    test_client.calls = calls
    return test_client


def test_score_today(client):
    r = client.get("/weather/score", params={"lat": 37.21, "lon": 28.36, "activity": "bike"})
    assert r.status_code == 200
    body = r.json()
    assert len(body["hourly"]) == 24
    assert body["hourly"][12]["score"] == 10      # gündüz, 18°C
    assert body["hourly"][22]["score"] == 8       # karanlık
    assert body["best_window"] == {"start": "07:00", "end": "09:00"}
    assert client.calls == [1]
    assert body["stale"] is False
    assert len(body["updated_at"]) == 5


def test_score_tomorrow_uses_second_day(client):
    r = client.get("/weather/score",
                   params={"lat": 37.21, "lon": 28.36, "activity": "walk", "day": "tomorrow"})
    assert r.status_code == 200
    body = r.json()
    assert client.calls == [2]
    assert body["now"] is None
    assert len(body["hourly"]) == 24
    assert all(h["feels_like"] == 35.0 for h in body["hourly"])
    assert body["hourly"][12]["score"] == 5


def test_open_meteo_down_returns_503(monkeypatch, client):
    def broken(lat, lon, days=1):
        raise httpx.ConnectError("Open-Meteo kapalı")

    monkeypatch.setattr(weather_router, "get_hourly_with_meta", broken)
    r = client.get("/weather/score", params={"lat": 37.21, "lon": 28.36, "activity": "bike"})
    assert r.status_code == 503
    assert "ulaşılamadı" in r.json()["detail"]


@pytest.mark.parametrize("params", [
    {"lat": 200, "lon": 28.36, "activity": "bike"},
    {"lat": 37.21, "lon": -500, "activity": "bike"},
    {"lat": "abc", "lon": 28.36, "activity": "bike"},
    {"lat": 37.21, "lon": 28.36, "activity": "car"},
    {"lat": 37.21, "lon": 28.36, "activity": "bike", "day": "yesterday"},
    {"lon": 28.36, "activity": "bike"},
])
def test_invalid_input_returns_422(client, params):
    r = client.get("/weather/score", params=params)
    assert r.status_code == 422
    assert client.calls == []

def test_stale_flag_is_passed_through(monkeypatch, client):
    monkeypatch.setattr(weather_router, "get_hourly_with_meta",
                        lambda lat, lon, days=1: (fake_hourly(days), 0.0, True))
    r = client.get("/weather/score", params={"lat": 37.21, "lon": 28.36, "activity": "bike"})
    assert r.status_code == 200
    assert r.json()["stale"] is True


def test_week_has_seven_days(client):
    r = client.get("/weather/week", params={"lat": 37.21, "lon": 28.36, "activity": "walk"})
    assert r.status_code == 200
    body = r.json()
    assert client.calls == [7]
    assert len(body["days"]) == 7
    assert body["days"][1]["date"] == "2000-01-02"
    assert body["days"][2]["best_window"] is not None   # 18 derece: iyi bir gün
    assert body["days"][1]["max_feels_like"] == 35.0


def test_week_hot_day_scores_lower(client):
    days = client.get("/weather/week", params={"lat": 37.21, "lon": 28.36, "activity": "bike"}).json()["days"]
    assert days[1]["max_score"] < days[2]["max_score"]   # 35 derece gün < 18 derece gün


def test_week_returns_503_when_open_meteo_down(monkeypatch, client):
    def broken(lat, lon, days=1):
        raise httpx.ConnectError("yok")
    monkeypatch.setattr(weather_router, "get_hourly_with_meta", broken)
    r = client.get("/weather/week", params={"lat": 37.21, "lon": 28.36, "activity": "bike"})
    assert r.status_code == 503
