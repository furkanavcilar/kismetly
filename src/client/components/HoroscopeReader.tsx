import React, { useState, useEffect } from 'react';
import { Star, Send, Loader } from 'lucide-react';

interface HoroscopeResponse {
  sign: string;
  timeframe: string;
  horoscope: string;
  date: string;
}

const zodiacSigns = [
  'aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo',
  'libra', 'scorpio', 'sagittarius', 'capricorn', 'aquarius', 'pisces'
];

export default function HoroscopeReader() {
  const [selectedSign, setSelectedSign] = useState('aries');
  const [timeframe, setTimeframe] = useState<'daily' | 'weekly' | 'monthly'>('daily');
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<HoroscopeResponse | null>(null);
  const [error, setError] = useState('');

  const handleGenerate = async () => {
    setLoading(true);
    setError('');
    setResult(null);
    
    try {
      const response = await fetch('/api/horoscope/generate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ sign: selectedSign, timeframe })
      });

      if (!response.ok) throw new Error('Failed to generate horoscope');
      
      const data = await response.json();
      setResult(data);
    } catch (err: any) {
      setError(err.message || 'Failed to generate horoscope');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-3 mb-8">
        <Star className="w-8 h-8 text-yellow-400" />
        <h2 className="text-3xl font-bold text-white">Horoscope Reader</h2>
      </div>

      {!result ? (
        <div className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="rounded-xl border border-purple-500/30 bg-gradient-to-br from-purple-900/20 to-pink-900/20 p-6">
              <label className="block text-sm font-medium text-gray-300 mb-3">
                Select Your Zodiac Sign:
              </label>
              <div className="grid grid-cols-3 gap-2">
                {zodiacSigns.map((sign) => (
                  <button
                    key={sign}
                    onClick={() => setSelectedSign(sign)}
                    className={`px-3 py-2 rounded-lg font-semibold transition-all text-sm ${
                      selectedSign === sign
                        ? 'bg-gradient-to-r from-purple-600 to-pink-600 text-white'
                        : 'bg-slate-800/30 text-gray-300 border border-purple-500/20 hover:border-purple-400'
                    }`}
                  >
                    {sign.charAt(0).toUpperCase() + sign.slice(1).substring(0, 3)}
                  </button>
                ))}
              </div>
            </div>

            <div className="rounded-xl border border-purple-500/30 bg-gradient-to-br from-purple-900/20 to-pink-900/20 p-6">
              <label className="block text-sm font-medium text-gray-300 mb-3">
                Timeframe:
              </label>
              <div className="space-y-2">
                {(['daily', 'weekly', 'monthly'] as const).map((tf) => (
                  <label key={tf} className="flex items-center gap-3 cursor-pointer">
                    <input
                      type="radio"
                      name="timeframe"
                      value={tf}
                      checked={timeframe === tf}
                      onChange={() => setTimeframe(tf)}
                      className="w-4 h-4 accent-purple-500"
                    />
                    <span className="text-gray-300 capitalize">{tf} Reading</span>
                  </label>
                ))}
              </div>
            </div>
          </div>

          {error && (
            <div className="rounded-lg bg-red-900/20 border border-red-500/30 text-red-300 p-3">
              {error}
            </div>
          )}

          <button
            onClick={handleGenerate}
            disabled={loading}
            className="w-full rounded-lg bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-500 hover:to-pink-500 disabled:from-gray-600 disabled:to-gray-600 text-white font-semibold py-3 transition-all flex items-center justify-center gap-2"
          >
            {loading ? (
              <>
                <Loader className="w-5 h-5 animate-spin" />
                Reading the cosmos...
              </>
            ) : (
              <>
                <Send className="w-5 h-5" />
                Generate Horoscope
              </>
            )}
          </button>
        </div>
      ) : (
        <div className="space-y-6">
          <div className="rounded-xl border border-purple-500/30 bg-gradient-to-br from-purple-900/20 to-pink-900/20 p-6">
            <h3 className="text-lg font-semibold text-yellow-300 mb-2">
              {result.sign} • {result.timeframe.charAt(0).toUpperCase() + result.timeframe.slice(1)}
            </h3>
            <p className="text-sm text-gray-400">{new Date(result.date).toLocaleDateString()}</p>
          </div>

          <div className="rounded-xl border border-purple-500/30 bg-gradient-to-br from-purple-900/20 to-pink-900/20 p-6">
            <div className="prose prose-invert max-w-none">
              {result.horoscope.split('\n').map((paragraph, index) => (
                paragraph.trim() && (
                  <p key={index} className="text-gray-200 leading-relaxed mb-4">
                    {paragraph}
                  </p>
                )
              ))}
            </div>
          </div>

          <button
            onClick={() => setResult(null)}
            className="w-full rounded-lg border border-purple-500/30 hover:border-purple-400 text-purple-300 hover:text-purple-100 font-semibold py-2 transition-all"
          >
            Generate New Reading
          </button>
        </div>
      )}
    </div>
  );
}

