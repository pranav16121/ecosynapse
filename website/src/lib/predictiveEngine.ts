/**
 * EcoSynapse Time-Series Regression & Predictive Fill Engine
 * Analyzes historical fill rate velocity (delta fill / delta t) and calculates time-to-full predictions.
 */

export interface TelemetryPoint {
  timestamp: number;
  overallFill: number;
}

export function calculatePredictiveFullHours(
  currentFill: number,
  history: TelemetryPoint[] = []
): number {
  if (currentFill >= 100) return 0.0;
  if (currentFill <= 0) return 24.0;

  // Default baseline hourly fill rate (approx 3.5% per hour)
  let estimatedHourlyRate = 3.5;

  if (history.length >= 2) {
    const oldest = history[0];
    const latest = history[history.length - 1];
    const timeDiffHours = (latest.timestamp - oldest.timestamp) / (1000 * 60 * 60);

    if (timeDiffHours > 0) {
      const fillDiff = latest.overallFill - oldest.overallFill;
      if (fillDiff > 0) {
        estimatedHourlyRate = fillDiff / timeDiffHours;
      }
    }
  }

  // Ensure reasonable bounds for rate (minimum 1.0% / hr, maximum 50% / hr)
  const boundedRate = Math.max(1.0, Math.min(50.0, estimatedHourlyRate));
  const remainingFill = 100 - currentFill;
  const hoursRemaining = remainingFill / boundedRate;

  return Number(hoursRemaining.toFixed(1));
}

