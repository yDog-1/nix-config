import json
import sys


translations = {
    "Patchy rain nearby": "所により雨",
    "Patchy snow nearby": "所により雪",
    "Patchy sleet nearby": "所によりみぞれ",
    "Patchy freezing drizzle nearby": "所により着氷性の霧雨",
    "Thundery outbreaks in nearby": "所により雷雨",
    "Moderate or heavy rain with thunder": "雷を伴う強い雨",
    "Patchy light rain with thunder": "雷を伴う弱い雨",
    "Moderate or heavy snow with thunder": "雷を伴う強い雪",
    "Patchy light snow with thunder": "雷を伴う弱い雪",
    "Moderate or heavy rain shower": "強いにわか雨",
    "Torrential rain shower": "激しいにわか雨",
    "Light rain shower": "弱いにわか雨",
    "Moderate or heavy snow showers": "強いにわか雪",
    "Light snow showers": "弱いにわか雪",
    "Moderate or heavy sleet showers": "強いにわかみぞれ",
    "Light sleet showers": "弱いにわかみぞれ",
    "Moderate or heavy showers of ice pellets": "強い氷粒のにわか雨",
    "Light showers of ice pellets": "弱い氷粒のにわか雨",
    "Moderate or heavy freezing rain": "強い着氷性の雨",
    "Light freezing rain": "弱い着氷性の雨",
    "Heavy freezing drizzle": "強い着氷性の霧雨",
    "Freezing drizzle": "着氷性の霧雨",
    "Freezing fog": "着氷性の霧",
    "Blowing snow": "地吹雪",
    "Blizzard": "吹雪",
    "Ice pellets": "氷粒",
}

result = json.load(sys.stdin)
for english, japanese in translations.items():
    result["tooltip"] = result["tooltip"].replace(english, japanese)
print(json.dumps(result, ensure_ascii=False))
