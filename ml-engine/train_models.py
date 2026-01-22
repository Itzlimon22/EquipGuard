import pandas as pd
import pickle
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier, IsolationForest
from sklearn.metrics import classification_report


def train():
    print("🚀 Starting Model Training...")

    # 1. Load Data
    df = pd.read_csv("sensor_data.csv")

    # Select Features (Inputs)
    # We ignore Timestamp and Machine_ID for the actual math
    features = ["Temperature", "Vibration", "Voltage"]
    X = df[features]

    # Select Target (Output for Supervised Learning)
    y = df["Status"]

    # 2. Preprocessing
    # ML models work best when numbers are on the same scale (0 to 1-ish)
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)

    # ---------------------------------------------------------
    # MODEL A: Unsupervised Learning (Isolation Forest)
    # Goal: Detect anomalies without knowing the labels.
    # ---------------------------------------------------------
    print("\nTraining Unsupervised Model (Isolation Forest)...")
    # contamination=0.02 means we guess about 2% of the data is bad
    iso_forest = IsolationForest(n_estimators=100, contamination=0.02, random_state=42)
    iso_forest.fit(X_scaled)

    # quick test: -1 means anomaly, 1 means normal
    anomalies = iso_forest.predict(X_scaled)
    print(f" -> Detected {list(anomalies).count(-1)} anomalies in the dataset.")

    # ---------------------------------------------------------
    # MODEL B: Supervised Learning (Random Forest)
    # Goal: Classify exact status (Healthy vs Warning vs Critical)
    # ---------------------------------------------------------
    print("\nTraining Supervised Model (Random Forest)...")

    # Split data: 80% for training, 20% for testing
    X_train, X_test, y_train, y_test = train_test_split(
        X_scaled, y, test_size=0.2, random_state=42
    )

    rf_classifier = RandomForestClassifier(n_estimators=100, random_state=42)
    rf_classifier.fit(X_train, y_train)

    # Evaluate
    accuracy = rf_classifier.score(X_test, y_test)
    print(f" -> Supervised Model Accuracy: {accuracy * 100:.2f}%")
    print("\nDetailed Report:")
    print(classification_report(y_test, rf_classifier.predict(X_test)))

    # ---------------------------------------------------------
    # 3. Save Everything (Pickle)
    # We need to save the Models AND the Scaler.
    # If we don't save the scaler, we can't normalize new live data correctly.
    # ---------------------------------------------------------
    print("\n💾 Saving models to .pkl files...")

    with open("model_unsupervised.pkl", "wb") as f:
        pickle.dump(iso_forest, f)

    with open("model_supervised.pkl", "wb") as f:
        pickle.dump(rf_classifier, f)

    with open("scaler.pkl", "wb") as f:
        pickle.dump(scaler, f)

    print("✅ Done! Models saved in 'ml-engine' folder.")


if __name__ == "__main__":
    train()
