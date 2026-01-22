'use client'; // This is a Client Component (runs in browser)

import React, { useState, useEffect } from 'react';
import axios from 'axios';
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from 'recharts';
import { AlertTriangle, CheckCircle, Activity } from 'lucide-react';

// Define the shape of our data for TypeScript
interface DataPoint {
  time: string;
  temp: number;
  vib: number;
  status: string;
}

export default function Dashboard() {
  const [dataHistory, setDataHistory] = useState<DataPoint[]>([]);
  const [currentStatus, setCurrentStatus] = useState('Healthy');
  const [isAnomaly, setIsAnomaly] = useState(false);

  // This function simulates a sensor reading
  const fetchPrediction = async () => {
    // 1. Generate fake sensor data (Simulation logic)
    // Most of the time normal (50-60), sometimes spikes to 90+
    const fakeTemp = 50 + Math.random() * 20 + (Math.random() > 0.9 ? 40 : 0);
    const fakeVib = 10 + Math.random() * 5;
    const fakeVolt = 220 + Math.random() * 2;

    try {
      // 2. Send to YOUR Python API
      const response = await axios.post(
        'https://equipguard.onrender.com/predict',
        {
          Temperature: fakeTemp,
          Vibration: fakeVib,
          Voltage: fakeVolt,
        },
      );

      // 3. Process the result
      const result = response.data;
      const timestamp = new Date().toLocaleTimeString();

      // 4. Update Status State
      setCurrentStatus(result.prediction.status);
      setIsAnomaly(result.prediction.is_anomaly);

      // 5. Update Graph History (Keep last 20 points only)
      setDataHistory((prev) => {
        const newData = [
          ...prev,
          {
            time: timestamp,
            temp: fakeTemp,
            vib: fakeVib,
            status: result.prediction.status,
          },
        ];
        return newData.slice(-20);
      });
    } catch (error) {
      console.error('API Error - Is the Python Backend running?', error);
    }
  };

  // Run the fetch function every 2 seconds
  useEffect(() => {
    const interval = setInterval(fetchPrediction, 2000);
    return () => clearInterval(interval); // Cleanup on close
  }, []);

  return (
    <main className="min-h-screen bg-slate-950 text-white p-6 md:p-10">
      {/* Header */}
      <header className="flex justify-between items-center mb-8">
        <div>
          <h1 className="text-3xl font-bold text-blue-400">EquipGuard</h1>
          <p className="text-slate-400">
            Real-time Predictive Maintenance Console
          </p>
        </div>
        <div
          className={`px-4 py-2 rounded-full font-bold flex items-center gap-2 ${
            currentStatus === 'Critical'
              ? 'bg-red-500/20 text-red-400 border border-red-500'
              : currentStatus === 'Warning'
                ? 'bg-yellow-500/20 text-yellow-400 border border-yellow-500'
                : 'bg-green-500/20 text-green-400 border border-green-500'
          }`}
        >
          {currentStatus === 'Critical' ? (
            <AlertTriangle size={20} />
          ) : (
            <CheckCircle size={20} />
          )}
          Status: {currentStatus.toUpperCase()}
        </div>
      </header>

      {/* Main Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* KPI Cards */}
        <div className="lg:col-span-1 space-y-6">
          <div className="bg-slate-900 p-6 rounded-xl border border-slate-800">
            <h3 className="text-slate-400 mb-2 flex items-center gap-2">
              <Activity size={16} /> Anomaly Detection
            </h3>
            <p
              className={`text-4xl font-mono ${isAnomaly ? 'text-red-500 animate-pulse' : 'text-slate-200'}`}
            >
              {isAnomaly ? 'DETECTED' : 'Normal'}
            </p>
          </div>

          <div className="bg-slate-900 p-6 rounded-xl border border-slate-800">
            <h3 className="text-slate-400 mb-2">Live Temperature</h3>
            <p className="text-4xl font-mono text-blue-400">
              {dataHistory.length > 0
                ? dataHistory[dataHistory.length - 1].temp.toFixed(1)
                : '--'}
              °C
            </p>
          </div>
        </div>

        {/* Live Graph */}
        <div className="lg:col-span-2 bg-slate-900 p-6 rounded-xl border border-slate-800 h-[400px]">
          <h3 className="text-slate-400 mb-4">Live Sensor Telemetry</h3>
          <ResponsiveContainer width="100%" height="100%">
            <LineChart data={dataHistory}>
              <CartesianGrid strokeDasharray="3 3" stroke="#334155" />
              <XAxis dataKey="time" stroke="#94a3b8" />
              <YAxis stroke="#94a3b8" />
              <Tooltip
                contentStyle={{
                  backgroundColor: '#1e293b',
                  borderColor: '#334155',
                }}
                itemStyle={{ color: '#e2e8f0' }}
              />
              <Line
                type="monotone"
                dataKey="temp"
                stroke="#3b82f6"
                strokeWidth={3}
                dot={false}
                activeDot={{ r: 8 }}
              />
              <Line
                type="monotone"
                dataKey="vib"
                stroke="#10b981"
                strokeWidth={2}
                dot={false}
              />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </div>
    </main>
  );
}
