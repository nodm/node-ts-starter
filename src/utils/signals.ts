const handleIntTermSignals: NodeJS.SignalsListener = async (
  signal: NodeJS.Signals,
) => {
  // Perform cleanup tasks or gracefully shut down
  // the application before it exits
  process.kill(process.pid, signal);
};

export function registerSignalHandlers() {
  process.once('SIGINT', handleIntTermSignals);
  process.on('SIGTERM', handleIntTermSignals);
}