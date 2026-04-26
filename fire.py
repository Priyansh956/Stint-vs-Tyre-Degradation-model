from analysis import analyze_race
import json

res = analyze_race(
    year = 2020,
    race_name = "Japanese Grand Prix",
    driver = "HAM"
)

json.dumps(res)