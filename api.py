from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from analysis import analyze_race


# ===============================
# App initialization
# ===============================
app = FastAPI(
    title="F1 Tyre Degradation Analysis API",
    description="Backend service for stint-level tyre degradation analysis using FastF1",
    version="1.0.0"
)

# ===============================
# CORS (needed for Flutter / web)
# ===============================
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],        # tighten later if you deploy
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ===============================
# Health check endpoint
# ===============================
@app.get("/")
def health_check():
    return {
        "status": "ok",
        "message": "F1 Analysis API is running"
    }

# ===============================
# Analysis endpoint
# ===============================
@app.get("/analyze")
def analyze(
    year: int,
    race: str,
    driver: str
):
    """
    Example:
    /analyze?year=2025&race=Japanese Grand Prix&driver=VER
    """

    try:
        results = analyze_race(
            year=year,
            race_name=race,
            driver=driver
        )

        if not results:
            raise HTTPException(
                status_code=404,
                detail="No valid stints found for given inputs"
            )

        return {
            "year": year,
            "race": race,
            "driver": driver,
            "num_stints": len(results),
            "results": results
        }

    except ValueError as e:
        # for bad inputs like invalid race name, driver code, etc.
        raise HTTPException(
            status_code=400,
            detail=str(e)
        )

    except Exception as e:
        # catch-all for FastF1 / modeling failures
        raise HTTPException(
            status_code=500,
            detail=f"Internal server error: {str(e)}"
        )
