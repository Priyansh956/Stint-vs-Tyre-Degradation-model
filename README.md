# 🏎️ Stint vs Tyre Degradation Model

A full-stack application for analysing Formula 1 tyre degradation on a per-stint basis. The Python backend fetches real session data via FastF1 and fits a quadratic regression model to each stint, while the Flutter mobile app visualises lap times, residuals, and model metrics in real time.

---

## 📁 Project Structure

```
F1-reports/
├── f1/                        # Flutter mobile application
│   └── lib/
│       ├── models/
│       │   └── stint_analysis.dart
│       ├── pages/
│       │   └── home_page.dart
│       ├── services/
│       │   └── analysis_service.dart
│       ├── widgets/
│       │   ├── lap_time_chart.dart
│       │   └── residuals_chart.dart
│       └── main.dart
├── analysis.py                # Core tyre degradation modelling logic
├── api.py                     # FastAPI backend server
├── fire.py                    # Quick test script
└── OneRaceOneDriver.ipynb     # Exploratory notebook
```

---

## 🧠 How It Works

### Regression Model

For each stint, a multivariate linear regression is fitted using three features:

| Feature | Description |
|---|---|
| `lap_in_stint` | Linear tyre degradation over laps |
| `lap_in_stint²` | Quadratic (cliff) degradation |
| `lap_in_stint × TrackTemp` | Temperature interaction effect |

This produces four coefficients: **β₀** (intercept), **β₁** (linear deg), **β₂** (quadratic deg), **β₃** (temp interaction).

Model quality is reported via **RMSE**, **MAE**, and **R²**.

---

## ⚙️ Backend Setup (Python)

### Requirements

```bash
pip install fastapi uvicorn fastf1 pandas numpy scikit-learn
```

### Running the server

```bash
uvicorn api:app --host 0.0.0.0 --port 8000
```

> **Important:** Use `--host 0.0.0.0` so the server is reachable from a physical device on the same network.

### API Endpoint

```
GET /analyze?year=2023&race=Japanese Grand Prix&driver=VER
```

**Response:**
```json
{
  "year": 2023,
  "race": "Japanese Grand Prix",
  "driver": "VER",
  "num_stints": 2,
  "results": {
    "1": {
      "compound": "MEDIUM",
      "num_laps": 20,
      "avg_track_temp": 38.4,
      "rmse": 0.312,
      "mae": 0.251,
      "r2": 0.91,
      "beta_0": 91.4,
      "beta_1": 0.08,
      "beta_2": 0.002,
      "beta_3": -0.001,
      "lap_in_stint": [...],
      "lap_time_s": [...],
      "track_temp": [...],
      "residuals": [...]
    }
  }
}
```

FastF1 caches session data locally in `fastf1_cache/` — the **first request for a session takes 30–120 seconds** to download data; subsequent requests are near-instant.

---

## 📱 Flutter App Setup

### Requirements

- Flutter SDK (3.x+)
- Physical Android/iOS device or emulator

### Configuration

In `lib/services/analysis_service.dart`, set the base URL to your PC's local IP address:

```dart
static String baseUrl = "http://192.168.x.x:8000";
```

Find your IP with `ipconfig` (Windows) or `ip a` (Linux/macOS) — look for your Wi-Fi adapter's IPv4 address.

> Your phone and PC must be on the **same Wi-Fi network**.

### Android: Allow HTTP traffic

In `android/app/src/main/AndroidManifest.xml`, add:

```xml
<application
    android:usesCleartextTraffic="true"
    ...>
```

### Run

```bash
flutter pub get
flutter run
```

---

## 📊 Features

- Stint-by-stint tyre degradation analysis
- Quadratic regression with temperature interaction
- Interactive lap time chart per stint
- Residual plot to assess model fit
- RMSE / MAE / R² metrics displayed per stint
- Configurable API URL via in-app settings
- Dark theme UI

---

## 🔧 Tech Stack

| Layer | Technology |
|---|---|
| Mobile App | Flutter (Dart) |
| Charts | fl_chart |
| Backend | FastAPI (Python) |
| F1 Data | FastF1 |
| Modelling | scikit-learn |

---

## 📝 Notes

- The `fastf1_cache/` directory is excluded from version control (see `.gitignore`). It will be auto-created locally when the server first fetches a session.
- Pit laps, deleted laps, and the out-lap are excluded from modelling.
- Weather data is merged via `pd.merge_asof` on the lap timestamp for accurate per-lap track temperature.
