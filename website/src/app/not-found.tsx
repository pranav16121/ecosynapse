import Link from 'next/link';
import { Activity, Home, ArrowLeft } from 'lucide-react';

export default function NotFound() {
  return (
    <div className="min-h-screen bg-slate-950 text-slate-100 flex flex-col items-center justify-center p-6 text-center font-sans">
      <div className="max-w-md w-full bg-slate-900 border border-slate-800 rounded-3xl p-8 space-y-6 shadow-2xl">
        <div className="h-16 w-16 bg-rose-500/10 border border-rose-500/20 text-rose-400 rounded-2xl mx-auto flex items-center justify-center font-mono text-xl font-bold">
          404
        </div>

        <div className="space-y-2">
          <h1 className="text-2xl font-bold tracking-tight text-white">Bin Node Not Found</h1>
          <p className="text-xs text-slate-400">
            The page or smart bin telemetry endpoint you requested does not exist in the EcoSynapse network.
          </p>
        </div>

        <Link
          href="/"
          className="inline-flex items-center justify-center gap-2 bg-emerald-500 hover:bg-emerald-600 text-slate-950 font-bold text-xs px-6 py-3 rounded-xl transition-all shadow-lg shadow-emerald-500/20 w-full"
        >
          <ArrowLeft className="h-4 w-4" /> Return to EcoSynapse Home
        </Link>
      </div>
    </div>
  );
}

