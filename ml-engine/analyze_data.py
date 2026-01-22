import pandas as pd
import matplotlib.pyplot as plt


def visualize_data():
    # 1. Load the data
    df = pd.read_csv("sensor_data.csv")

    # Convert string timestamp to datetime objects for better plotting
    df["Timestamp"] = pd.to_datetime(df["Timestamp"])

    print("📊 Plotting data... (Close the window to finish)")

    # 2. Setup the Plotting Grid (2 rows, 1 column)
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 8), sharex=True)

    # --- PLOT 1: Temperature (The "Drift") ---
    # We color the "Critical" points in Red
    ax1.plot(
        df["Timestamp"], df["Temperature"], label="Temperature", color="blue", alpha=0.6
    )

    # Highlight critical failures (Temp > 90)
    critical_data = df[df["Status"] == "Critical"]
    ax1.scatter(
        critical_data["Timestamp"],
        critical_data["Temperature"],
        color="red",
        label="Critical Failure",
        zorder=5,
    )

    ax1.set_title("Machine Temperature (Look for the upward trend!)")
    ax1.set_ylabel("Temp (°C)")
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # --- PLOT 2: Vibration (The "Anomalies") ---
    ax2.plot(
        df["Timestamp"], df["Vibration"], label="Vibration", color="green", alpha=0.6
    )

    # Highlight anomalies
    # In our generator, high vibration often triggered "Critical" or "Warning"
    high_vib = df[df["Vibration"] > 50]
    ax2.scatter(
        high_vib["Timestamp"],
        high_vib["Vibration"],
        color="orange",
        label="Vibration Spike",
        zorder=5,
    )

    ax2.set_title("Machine Vibration (Look for random spikes!)")
    ax2.set_xlabel("Time")
    ax2.set_ylabel("Vibration (Hz)")
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.show()


if __name__ == "__main__":
    visualize_data()
