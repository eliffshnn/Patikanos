import httpx
import pytest

import app.weather.client as weather_client


class FakeResponse:
    def __init__(self, hourly, status=200):
        self._hourly = hourly
        self.status_code = status

    def raise_for_status(self):
        if self.status_code >= 400:
            raise httpx.HTTPStatusError(
                "hata", request=httpx.Request("GET", weather_client.URL), response=None
            )

    def json(self):
        return {"hourly": self._hourly}


@pytest.fixture
def calls(monkeypatch):
    """Open-Meteo'ya giden istekleri sayar; gerçek ağa çıkmaz."""
    weather_client.clear_cache()
    made = []

    def fake_get(url, params, timeout):
        made.append(params)
        return FakeResponse({"time": ["2000-01-01T00:00"], "n": len(made)})

    monkeypatch.setattr(weather_client.httpx, "get", fake_get)
    yield made
    weather_client.clear_cache()


def test_second_call_uses_cache(calls):
    first = weather_client.get_hourly(37.21, 28.36)
    second = weather_client.get_hourly(37.21, 28.36)
    assert len(calls) == 1
    assert first == second


def test_nearby_points_share_cache(calls):
    weather_client.get_hourly(37.2101, 28.3602)
    weather_client.get_hourly(37.2099, 28.3598)  # 2 ondalıkta aynı nokta
    assert len(calls) == 1


def test_different_days_are_cached_separately(calls):
    weather_client.get_hourly(37.21, 28.36, days=1)
    weather_client.get_hourly(37.21, 28.36, days=2)
    assert len(calls) == 2


def test_cache_expires_after_ttl(calls, monkeypatch):
    now = [1000.0]
    monkeypatch.setattr(weather_client.time, "time", lambda: now[0])

    weather_client.get_hourly(37.21, 28.36)
    now[0] += weather_client.CACHE_TTL_SECONDS + 1
    weather_client.get_hourly(37.21, 28.36)
    assert len(calls) == 2


def test_errors_are_not_cached(monkeypatch):
    weather_client.clear_cache()
    made = []

    def failing_get(url, params, timeout):
        made.append(params)
        return FakeResponse({}, status=500)

    monkeypatch.setattr(weather_client.httpx, "get", failing_get)
    for _ in range(2):
        with pytest.raises(httpx.HTTPStatusError):
            weather_client.get_hourly(37.21, 28.36)
    assert len(made) == 2

def test_new_day_does_not_use_yesterdays_cache(calls, monkeypatch):
    monkeypatch.setattr(weather_client, "_today", lambda: "2026-11-20")
    weather_client.get_hourly(37.21, 28.36)
    monkeypatch.setattr(weather_client, "_today", lambda: "2026-11-21")
    weather_client.get_hourly(37.21, 28.36)
    assert len(calls) == 2


def test_stale_data_returned_when_open_meteo_down(calls, monkeypatch):
    now = [1000.0]
    monkeypatch.setattr(weather_client.time, "time", lambda: now[0])
    data, _, stale = weather_client.get_hourly_with_meta(37.21, 28.36)
    assert stale is False

    def failing_get(url, params, timeout):
        return FakeResponse({}, status=500)

    monkeypatch.setattr(weather_client.httpx, "get", failing_get)
    now[0] += weather_client.CACHE_TTL_SECONDS + 1
    old, fetched_at, stale = weather_client.get_hourly_with_meta(37.21, 28.36)
    assert stale is True and old == data and fetched_at == 1000.0

    now[0] += weather_client.STALE_MAX_SECONDS
    with pytest.raises(httpx.HTTPStatusError):
        weather_client.get_hourly_with_meta(37.21, 28.36)
