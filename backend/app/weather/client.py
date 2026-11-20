import time

import httpx

URL = "https://api.open-meteo.com/v1/forecast"
CACHE_TTL_SECONDS = 30 * 60  # 30 dakika

# anahtar: (lat, lon, days) -> (kaydedilme zamanı, saatlik veri)
_cache: dict[tuple[float, float, int], tuple[float, dict]] = {}


def _cache_key(lat: float, lon: float, days: int) -> tuple[float, float, int]:
    # 2 ondalık ~1 km: yakın noktalar aynı kaydı kullanır
    return (round(lat, 2), round(lon, 2), days)


def clear_cache() -> None:
    _cache.clear()


def get_hourly(lat, lon, days=1):
    key = _cache_key(lat, lon, days)
    hit = _cache.get(key)
    if hit is not None and time.time() - hit[0] < CACHE_TTL_SECONDS:
        return hit[1]

    params = {
        "latitude": lat,
        "longitude": lon,
        "hourly": "apparent_temperature,wind_speed_10m,precipitation_probability,uv_index",
        "timezone": "Europe/Istanbul",
        "forecast_days": days,
    }
    response = httpx.get(URL, params=params, timeout=10)
    response.raise_for_status()
    data = response.json()["hourly"]

    _cache[key] = (time.time(), data)
    return data