import fastf1
import pandas as pd
import numpy as np

from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score

# Enable FastF1 cache
fastf1.Cache.enable_cache("fastf1_cache")


def analyze_race(year: int, race_name: str, driver: str):
    """
    Runs stint-level tyre degradation analysis for one driver in one race.
    Returns JSON-serializable results suitable for API / Flutter consumption.
    """

    # ===============================
    # 1. Load session
    # ===============================
    session = fastf1.get_session(year, race_name, "R")
    session.load()

    # ===============================
    # 2. Extract driver laps
    # ===============================
    laps = session.laps.pick_driver(driver)
    laps = laps[laps["LapTime"].notna()]

    # ===============================
    # 3. Clean laps
    # ===============================
    clean_laps = laps[
        (laps["PitInTime"].isna()) &
        (laps["PitOutTime"].isna()) &
        (laps["Deleted"] == False) &
        (laps["LapNumber"] > 1)
    ].copy()

    # ===============================
    # 4. Convert lap time to seconds
    # ===============================
    clean_laps["lap_time_s"] = (
        clean_laps["LapTime"].dt.total_seconds()
    )

    # ===============================
    # 5. Compute lap_in_stint
    # ===============================
    clean_laps["lap_in_stint"] = (
        clean_laps.groupby("Stint").cumcount() + 1
    )

    # ===============================
    # 6. Merge weather (track temperature)
    # ===============================
    weather = session.weather_data[["Time", "TrackTemp"]].dropna()
    weather = weather.sort_values("Time")

    clean_laps = clean_laps.sort_values("Time")

    clean_laps = pd.merge_asof(
        clean_laps,
        weather,
        on="Time",
        direction="nearest"
    )

    # ===============================
    # 7. Feature engineering
    # ===============================
    clean_laps["lap_in_stint_sq"] = clean_laps["lap_in_stint"] ** 2
    clean_laps["lap_temp_interaction"] = (
        clean_laps["lap_in_stint"] * clean_laps["TrackTemp"]
    )

    # ===============================
    # 8. Fit model per stint
    # ===============================
    results = {}

    for stint_id, stint_df in clean_laps.groupby("Stint"):
        X = stint_df[
            ["lap_in_stint", "lap_in_stint_sq", "lap_temp_interaction"]
        ].values

        y = stint_df["lap_time_s"].values

        model = LinearRegression()
        model.fit(X, y)

        y_pred = model.predict(X)
        residuals = y - y_pred

        rmse = np.sqrt(mean_squared_error(y, y_pred))
        mae = mean_absolute_error(y, y_pred)
        r2 = r2_score(y, y_pred)

        results[int(stint_id)] = {
            "compound": stint_df["Compound"].iloc[0],
            "num_laps": int(len(stint_df)),
            "avg_track_temp": float(stint_df["TrackTemp"].mean()),

            "rmse": float(rmse),
            "mae": float(mae),
            "r2": float(r2),

            "beta_0": float(model.intercept_),
            "beta_1": float(model.coef_[0]),   # linear degradation
            "beta_2": float(model.coef_[1]),   # quadratic degradation
            "beta_3": float(model.coef_[2]),   # temperature interaction

            "lap_in_stint": stint_df["lap_in_stint"].tolist(),
            "lap_time_s": stint_df["lap_time_s"].tolist(),
            "track_temp": stint_df["TrackTemp"].tolist(),
            "residuals": residuals.tolist()
        }

    return results
