import pandas as pd
import numpy as np
import random
from datetime import datetime, timedelta


def generate_synthetic_data(num_rows=10000):
    print(f"Generating {num_rows} rows of synthetic data...")

    # 1. Base Configuration
    # We simulate data points every 10 seconds
    base_time = datetime.now() - timedelta(days=1)
    timestamps = [base_time + timedelta(seconds=i * 10) for i in range(num_rows)]

    temperatures = []
    vibrations = []
    voltages = []
    statuses = []

    # 2. Simulation State (The "Virtual Machine")
    current_temp = 55.0  # Operating temperature (Celsius)
    current_vib = 12.0  # Operating vibration (Hz)

    for i in range(num_rows):
        status = "Healthy"

        # --- LOGIC A: DRIFT (For Supervised Learning) ---
        # Scenario: After 3000 cycles, the machine starts degrading (wear and tear).
        # The temperature slowly creeps up.
        if i > 3000:
            current_temp += 0.01
            if current_temp > 75:
                status = "Warning"

        # --- LOGIC B: NOISE (Realistic Sensor Fluctuation) ---
        # Sensors are never perfect. We add "Gaussian Noise".
        # np.random.normal(mean, std_dev)
        temp_reading = current_temp + np.random.normal(0, 1.0)
        vib_reading = current_vib + np.random.normal(0, 2.0)
        volt_reading = 220 + np.random.normal(0, 5.0)  # 220V standard

        # --- LOGIC C: ANOMALIES (For Unsupervised Learning) ---
        # Scenario: Random shocks or loose bolts.
        # 1% chance of a massive spike in vibration.
        if random.random() < 0.01:
            vib_reading += 50.0  # Jump to ~60+ Hz
            status = "Critical"

        # --- LOGIC D: CRITICAL FAILURE ---
        # If temp gets too high, it's a critical failure.
        if temp_reading > 90:
            status = "Critical"

        # Store the data
        temperatures.append(round(temp_reading, 2))
        vibrations.append(round(vib_reading, 2))
        voltages.append(round(volt_reading, 2))
        statuses.append(status)

    # 3. Create DataFrame and Save
    df = pd.DataFrame(
        {
            "Timestamp": timestamps,
            "Machine_ID": ["M-001"] * num_rows,
            "Temperature": temperatures,
            "Vibration": vibrations,
            "Voltage": voltages,
            "Status": statuses,
        }
    )

    df.to_csv("sensor_data.csv", index=False)
    print("✅ Success! 'sensor_data.csv' has been created.")
    print("--- Class Distribution ---")
    print(df["Status"].value_counts())


if __name__ == "__main__":
    generate_synthetic_data()
