import pickle
import pandas as pd
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import uvicorn

# 1. Initialize the App
app = FastAPI(title="EquipGuard ML API")

# --- NEW: ALLOW FRONTEND TO TALK TO BACKEND ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins (for development only)
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
# ----------------------------------------------

# Global variables to hold our models
model_sup = None  # Supervised (Random Forest)
model_unsup = None  # Unsupervised (Isolation Forest)
scaler = None  # The Normalizer


# 2. Load Models on Startup
@app.on_event("startup")
def load_models():
    global model_sup, model_unsup, scaler
    try:
        # Load the files we created in Sprint 5
        with open("model_supervised.pkl", "rb") as f:
            model_sup = pickle.load(f)

        with open("model_unsupervised.pkl", "rb") as f:
            model_unsup = pickle.load(f)

        with open("scaler.pkl", "rb") as f:
            scaler = pickle.load(f)

        print("✅ Models loaded successfully!")
    except FileNotFoundError:
        print("❌ Error: Model files not found. Did you run train_models.py?")


# 3. Define Input Shape
class SensorInput(BaseModel):
    Temperature: float
    Vibration: float
    Voltage: float


# 4. The Smart Prediction Endpoint
@app.post("/predict")
def predict_failure(data: SensorInput):
    if not model_sup or not scaler:
        raise HTTPException(status_code=500, detail="Models not loaded")

    # Step A: Convert input to DataFrame (matches training format)
    input_df = pd.DataFrame(
        [
            {
                "Temperature": data.Temperature,
                "Vibration": data.Vibration,
                "Voltage": data.Voltage,
            }
        ]
    )

    # Step B: Normalize the data (Scale 0-1)
    # Warning: We must use the SAME scaler from training
    scaled_data = scaler.transform(input_df)

    # Step C: Get Predictions
    # 1. Supervised Prediction (Healthy vs Critical)
    pred_status = model_sup.predict(scaled_data)[0]

    # 2. Unsupervised Prediction (-1 = Anomaly, 1 = Normal)
    anomaly_score = model_unsup.predict(scaled_data)[0]
    is_anomaly = True if anomaly_score == -1 else False

    # Step D: Return Result
    return {
        "input": data,
        "prediction": {
            "status": pred_status,  # "Healthy", "Warning", or "Critical"
            "is_anomaly": is_anomaly,  # True/False
        },
    }


if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8000)
