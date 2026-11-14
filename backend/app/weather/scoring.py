WINDOW_HOURS = 2     # önerilen zaman aralığının uzunluğu
GOOD_SCORE = 7       # "İyi" ve üstü


def temperature_penalty(feels_like, bike):
    """Hissedilen sıcaklığa göre puan kesintisi. 18-24°C ideal."""
    if feels_like > 36:
        return 7
    if feels_like > 32:
        return 5
    if feels_like > 28:
        return 3
    if feels_like > 24:
        return 1
    if feels_like >= 18:
        return 0
    # Soğuk: bisiklette hız rüzgârı yüzünden daha çok hissedilir
    if feels_like >= 15:
        return 1 if bike else 0
    if feels_like >= 12:
        return 2 if bike else 1
    if feels_like >= 8:
        return 4 if bike else 1
    if feels_like >= 4:
        return 6 if bike else 2
    if feels_like >= 0:
        return 8 if bike else 4
    return 9 if bike else 6


def is_dark(hour):
    return hour < 7 or hour >= 18


def score_hour(feels_like, wind, rain_prob, uv, activity, hour=12):
    """Bir saatin bisiklet veya yürüyüş için uygunluk skoru (0-10)."""
    bike = activity == "bike"
    score = 10 - temperature_penalty(feels_like, bike)

    # Karanlık
    if is_dark(hour):
        score -= 2 if bike else 1

    # Rüzgâr
    if wind > 35:
        score -= 5 if bike else 2
    elif wind >= 25:
        score -= 3 if bike else 1
    elif wind >= 15 and bike:
        score -= 1

    # Soğuk + rüzgâr birlikte daha çok üşütür
    if feels_like < 10 and wind >= 20:
        score -= 1

    # Yağmur
    heavy_rain = rain_prob > 60
    if heavy_rain:
        score -= 5 if bike else 3
    elif rain_prob >= 30:
        score -= 2 if bike else 1

    # Fırtına: yoğun yağmur + sert rüzgâr
    if heavy_rain and wind > 35:
        score -= 2 if bike else 3

    # UV
    if uv >= 8:
        score -= 3
    elif uv >= 6:
        score -= 1

    return max(score, 0)


def best_window(times, scores, start=0, threshold=GOOD_SCORE, length=WINDOW_HOURS):
    """start'tan itibaren 06:00-22:00 arasında ortalaması en yüksek 2 saatlik pencere.
    Eşitlikte en erken pencere. Hiçbiri threshold'a ulaşmazsa None."""
    best = None
    for i in range(start, len(times) - length + 1):
        first_hour = int(times[i][11:13])
        last_hour = int(times[i + length - 1][11:13])
        if first_hour < 6 or last_hour >= 22 or last_hour < first_hour:
            continue
        avg = sum(scores[i:i + length]) / length
        if avg >= threshold and (best is None or avg > best[0]):
            best = (avg, i)
    if best is None:
        return None
    return best[1], best[1] + length


def window_label(times, start, end):
    """(start, end) aralığını '10:00–12:00' gibi yazıya çevirir."""
    end_hour = int(times[end - 1][11:13]) + 1
    return f"{times[start][11:16]}–{end_hour:02d}:00"


def window_warnings(feels_like, rain_prob, uv, start, end):
    """Önerilen aralıkta dikkat edilmesi gerekenler."""
    notes = []
    coldest = min(feels_like[start:end])
    rainiest = max(rain_prob[start:end])
    highest_uv = max(uv[start:end])
    if coldest <= 12:
        notes.append(f"Serin (en düşük {coldest:.0f}°C), kat kat giyin")
    if rainiest >= 30:
        notes.append(f"Yağmur ihtimali %{rainiest}, yağmurluk al")
    if highest_uv >= 8:
        notes.append(f"UV çok yüksek ({highest_uv:.0f}), öğlen saatlerinde gölgede kal")
    elif highest_uv >= 3:
        notes.append(f"UV {highest_uv:.0f}, güneş kremi ve şapka önerilir")
    return notes


def clothing_tips(feels_like, wind, rain_prob, uv, activity, hour):
    """O saatin havasına göre öneriler: [{"type": ..., "text": ...}].
    Her tür sadece o koşul varsa eklenir; gündüz ve gece metinleri farklıdır."""
    bike = activity == "bike"
    night = is_dark(hour)
    tips = []

    def add(kind, day_text, night_text=None):
        tips.append({"type": kind, "text": night_text if (night and night_text) else day_text})

    # Sıcaklık
    if feels_like < 5:
        add("temperature",
            "Mont, bere ve eldiven giy" + (", boynunu da ört" if bike else ""),
            "Mont, bere, eldiven ve atkı; gece hava daha da soğuyacak")
    elif feels_like < 10:
        add("temperature",
            "Kalın ceket giy, kat kat giyin" + ("; eldiven al" if bike else ""),
            "Kalın mont giy; gece sıcaklık düşmeye devam ediyor")
    elif feels_like < 15:
        add("temperature",
            "Rüzgârlık al" if bike else "İnce bir ceket ya da hırka al",
            "Üstüne bir kat daha al; gece serinliyor")
    elif feels_like > 30:
        add("temperature",
            "Öğlen saatlerinden kaçın; bol su al, gölgede mola ver",
            "Hava hâlâ sıcak; yanına bol su al")
    elif feels_like > 25:
        add("temperature",
            "İnce, açık renkli giysiler giy ve su al",
            "Hafif giysiler yeterli; su almayı unutma")

    # Rüzgâr
    if wind >= 20:
        w = f"Rüzgâr {wind:.0f} km/s: "
        if bike:
            add("wind", w + "rüzgâra karşı vites küçült, yavaş sür",
                w + "karanlıkta ani rüzgâra dikkat, yavaş sür")
        else:
            add("wind", w + "rüzgârlık giy, şapkanı sabitle",
                w + "rüzgârlık giy, açık alanlardan kaçın")

    # Yağmur
    if rain_prob >= 30:
        if bike:
            add("rain", "Yağmurluk giy; ıslak zeminde fren mesafesi uzar",
                "Yağmurluk giy; ıslak zemin ve karanlık, hızını düşür")
        else:
            add("rain", "Şemsiye veya yağmurluk al, su geçirmez ayakkabı giy",
                "Şemsiye al; ıslak zeminde kaymayan ayakkabı giy, görünür ol")

    # Güneş (gece UV 0 olduğu için kendiliğinden çıkmaz)
    if uv >= 6:
        add("sun", "Güneş kremi, şapka ve güneş gözlüğü; 12:00-15:00 arası gölgede kal")
    elif uv >= 3:
        add("sun", "Güneş kremi ve şapka")

    # Görünürlük
    if night:
        add("visibility", "Ön ve arka lamba, reflektörlü yelek" if bike
            else "Açık renkli ya da reflektörlü giysi, fener; aydınlık yolları seç")

    # Güvenlik
    if bike:
        add("safety", "Kaskını tak")
    return tips