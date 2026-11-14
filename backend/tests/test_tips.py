from app.weather.scoring import clothing_tips


def types(tips):
    return [t["type"] for t in tips]


def texts(tips):
    return " | ".join(t["text"] for t in tips)


def test_only_rain_when_only_raining():
    tips = clothing_tips(20, 5, 70, 0, "walk", 12)
    assert types(tips) == ["rain"]
    assert "Şemsiye" in texts(tips)


def test_only_wind_when_only_windy():
    assert types(clothing_tips(20, 30, 0, 0, "walk", 12)) == ["wind"]


def test_day_and_night_texts_differ():
    day = clothing_tips(3, 5, 0, 0, "walk", 12)
    night = clothing_tips(3, 5, 0, 0, "walk", 22)
    assert day[0]["type"] == night[0]["type"] == "temperature"
    assert day[0]["text"] != night[0]["text"]
    assert "visibility" in types(night) and "visibility" not in types(day)


def test_uv_only_in_daytime_values():
    assert "sun" in types(clothing_tips(20, 5, 0, 7, "walk", 13))
    assert "sun" not in types(clothing_tips(20, 5, 0, 0, "walk", 22))


def test_bike_rain_night():
    tips = clothing_tips(12, 22, 50, 0, "bike", 2)
    assert types(tips) == ["temperature", "wind", "rain", "visibility", "safety"]
    assert "karanlık" in texts(tips)