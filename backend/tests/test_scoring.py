from app.weather.scoring import best_window, score_hour, window_label

TIMES = [f"2000-01-01T{h:02d}:00" for h in range(24)]


def test_ideal_weather():
    assert score_hour(20, 5, 0, 3, "bike") == 10
    assert score_hour(20, 5, 0, 3, "walk") == 10


def test_feels_like_bands_bike():
    temps = (20, 16, 13, 10, 6, 2, -3)
    assert [score_hour(t, 5, 0, 1, "bike") for t in temps] == [10, 9, 8, 6, 4, 2, 1]


def test_feels_like_bands_walk():
    temps = (20, 16, 13, 10, 6, 2, -3)
    assert [score_hour(t, 5, 0, 1, "walk") for t in temps] == [10, 10, 9, 9, 8, 6, 4]


def test_heat_same_for_both():
    for activity in ("bike", "walk"):
        assert [score_hour(t, 5, 0, 1, activity) for t in (26, 30, 34, 38)] == [9, 7, 5, 3]


def test_darkness_penalty():
    assert score_hour(20, 5, 0, 0, "bike", hour=22) == 8
    assert score_hour(20, 5, 0, 0, "walk", hour=22) == 9
    assert score_hour(20, 5, 0, 0, "bike", hour=7) == 10


def test_november_night_vs_noon():
    assert score_hour(3, 5, 0, 0, "bike", hour=1) == 0
    assert score_hour(3, 5, 0, 0, "walk", hour=1) == 5
    assert score_hour(14, 10, 0, 2, "bike", hour=12) == 8
    assert score_hour(14, 10, 0, 2, "walk", hour=12) == 9


def test_cold_and_wind_together():
    assert score_hour(7, 22, 0, 0, "bike", hour=8) == 2
    assert score_hour(7, 22, 0, 0, "walk", hour=8) == 7


def test_rain_and_storm():
    assert score_hour(20, 5, 45, 0, "bike") == 8
    assert score_hour(20, 5, 45, 0, "walk") == 9
    assert score_hour(20, 40, 80, 0, "bike") == 0
    assert score_hour(20, 40, 80, 0, "walk") == 2


def test_hot_sunny_noon():
    assert score_hour(34, 5, 0, 9, "bike") == 2
    assert score_hour(34, 5, 0, 9, "walk") == 2


def test_score_never_negative():
    assert score_hour(-10, 50, 100, 11, "bike", hour=2) == 0


def test_best_window_picks_highest_two_hours():
    scores = [5] * 24
    scores[9], scores[10] = 8, 8
    scores[13], scores[14] = 10, 9
    start, end = best_window(TIMES, scores)
    assert window_label(TIMES, start, end) == "13:00–15:00"


def test_best_window_only_looks_ahead():
    scores = [5] * 24
    scores[6], scores[7] = 10, 10      # sabah çok iyi
    scores[12], scores[13] = 8, 8      # öğlen iyi
    assert window_label(TIMES, *best_window(TIMES, scores)) == "06:00–08:00"
    # saat 09:00'da bakınca sabah geçmiş, öğlen önerilir
    assert window_label(TIMES, *best_window(TIMES, scores, start=9)) == "12:00–14:00"


def test_best_window_tie_picks_earliest():
    scores = [10] * 24
    assert window_label(TIMES, *best_window(TIMES, scores)) == "06:00–08:00"


def test_best_window_ignores_night():
    scores = [5] * 24
    scores[2], scores[3] = 10, 10
    scores[22], scores[23] = 10, 10
    assert best_window(TIMES, scores) is None


def test_no_good_hours():
    assert best_window(TIMES, [6] * 24) is None