import React, { useState } from 'react';
import { Moon, Send, Loader } from 'lucide-react';

interface DreamResponse {
  interpretation: string;
  dream: string;
  timestamp: string;
}

export default function DreamInterpreter() {
  const [dream, setDream] = useState('');
  const [mood, setMood] = useState('');
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<DreamResponse | null>(null);
  const [error, setError] = useState('');

  const handleInterpret = async () => {
    if (!dream.trim()) {
      setError('Please describe your dream');
      return;
    }

    setLoading(true);
    setError('');
    
    try {
      const response = await fetch('/api/dreams/interpret', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ description: dream, mood })
      });

      if (!response.ok) throw new Error('Failed to interpret dream');
      
      const data = await response.json();
      setResult(data);
    } catch (err: any) {
      setError(err.message || 'Failed to generate interpretation');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-3 mb-8">
        <Moon className="w-8 h-8 text-purple-400" />
        <h2 className="text-3xl font-bold text-white">Dream Interpreter</h2>
      </div>

      {!result ? (
        <div className="space-y-4">
          <div className="rounded-xl border border-purple-500/30 bg-gradient-to-br from-purple-900/20 to-pink-900/20 p-6">
            <label className="block text-sm font-medium text-gray-300 mb-2">
              Describe your dream in detail:
            </label>
            <textarea
              value={dream}
              onChange={(e) => setDream(e.target.value)}
              placeholder="I was walking through a forest where the trees had silver leaves and the sky was..."
              className="w-full h-40 rounded-lg bg-slate-800/50 border border-purple-500/20 text-white placeholder-gray-500 p-4 focus:border-purple-400 focus:outline-none transition-colors"
            />
          </div>

          <div className="rounded-xl border border-purple-500/30 bg-gradient-to-br from-purple-900/20 to-pink-900/20 p-6">
            <label className="block text-sm font-medium text-gray-300 mb-2">
              How did you feel when you woke up? (optional)
            </label>
            <input
              type="text"
              value={mood}
              onChange={(e) => setMood(e.target.value)}
              placeholder="e.g., confused, peaceful, anxious, inspired..."
              className="w-full rounded-lg bg-slate-800/50 border border-purple-500/20 text-white placeholder-gray-500 p-3 focus:border-purple-400 focus:outline-none transition-colors"
            />
          </div>

          {error && (
            <div className="rounded-lg bg-red-900/20 border border-red-500/30 text-red-300 p-3">
              {error}
            </div>
          )}

          <button
            onClick={handleInterpret}
            disabled={loading}
            className="w-full rounded-lg bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-500 hover:to-pink-500 disabled:from-gray-600 disabled:to-gray-600 text-white font-semibold py-3 transition-all flex items-center justify-center gap-2"
          >
            {loading ? (
              <>
                <Loader className="w-5 h-5 animate-spin" />
                Interpreting your dream...
              </>
            ) : (
              <>
                <Send className="w-5 h-5" />
                Interpret Dream
              </>
            )}
          </button>
        </div>
      ) : (
        <div className="space-y-6">
          <div className="rounded-xl border border-purple-500/30 bg-gradient-to-br from-purple-900/20 to-pink-900/20 p-6">
            <h3 className="text-lg font-semibold text-purple-300 mb-4">Your Dream</h3>
            <p className="text-gray-200 leading-relaxed">{result.dream}</p>
          </div>

          <div className="rounded-xl border border-purple-500/30 bg-gradient-to-br from-purple-900/20 to-pink-900/20 p-6">
            <h3 className="text-lg font-semibold text-purple-300 mb-4">✨ Spiritual Interpretation</h3>
            <div className="prose prose-invert max-w-none">
              {result.interpretation.split('\n').map((paragraph, index) => (
                paragraph.trim() && (
                  <p key={index} className="text-gray-200 leading-relaxed mb-4">
                    {paragraph}
                  </p>
                )
              ))}
            </div>
          </div>

          <button
            onClick={() => {
              setResult(null);
              setDream('');
              setMood('');
            }}
            className="w-full rounded-lg border border-purple-500/30 hover:border-purple-400 text-purple-300 hover:text-purple-100 font-semibold py-2 transition-all"
          >
            Interpret Another Dream
          </button>
        </div>
      )}
    </div>
  );
}

