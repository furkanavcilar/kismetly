import React, { useState } from 'react';
import { Heart, Send, Loader } from 'lucide-react';

interface CompatibilityResponse {
  person1: string;
  person2: string;
  analysis: string;
  timestamp: string;
}

export default function LoveCompatibility() {
  const [name1, setName1] = useState('');
  const [name2, setName2] = useState('');
  const [birthDate1, setBirthDate1] = useState('');
  const [birthDate2, setBirthDate2] = useState('');
  const [sign1, setSign1] = useState('');
  const [sign2, setSign2] = useState('');
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<CompatibilityResponse | null>(null);
  const [error, setError] = useState('');

  const zodiacSigns = [
    'aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo',
    'libra', 'scorpio', 'sagittarius', 'capricorn', 'aquarius', 'pisces'
  ];

  const handleAnalyze = async () => {
    if (!name1.trim() || !name2.trim()) {
      setError('Please enter both names');
      return;
    }

    setLoading(true);
    setError('');
    
    try {
      const response = await fetch('/api/compatibility/analyze', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          name1,
          name2,
          birthDate1: birthDate1 || undefined,
          birthDate2: birthDate2 || undefined,
          sign1: sign1 || undefined,
          sign2: sign2 || undefined
        })
      });

      if (!response.ok) throw new Error('Failed to analyze compatibility');
      
      const data = await response.json();
      setResult(data);
    } catch (err: any) {
      setError(err.message || 'Failed to analyze compatibility');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-3 mb-8">
        <Heart className="w-8 h-8 text-red-400" />
        <h2 className="text-3xl font-bold text-white">Love Compatibility</h2>
      </div>

      {!result ? (
        <div className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="rounded-xl border border-purple-500/30 bg-gradient-to-br from-purple-900/20 to-pink-900/20 p-6">
              <h3 className="text-lg font-semibold text-pink-300 mb-4">First Person</h3>
              <div className="space-y-3">
                <input
                  type="text"
                  value={name1}
                  onChange={(e) => setName1(e.target.value)}
                  placeholder="First name"
                  className="w-full rounded-lg bg-slate-800/50 border border-purple-500/20 text-white placeholder-gray-500 p-3 focus:border-purple-400 focus:outline-none"
                />
                <input
                  type="date"
                  value={birthDate1}
                  onChange={(e) => setBirthDate1(e.target.value)}
                  className="w-full rounded-lg bg-slate-800/50 border border-purple-500/20 text-white placeholder-gray-500 p-3 focus:border-purple-400 focus:outline-none"
                />
                <select
                  value={sign1}
                  onChange={(e) => setSign1(e.target.value)}
                  className="w-full rounded-lg bg-slate-800/50 border border-purple-500/20 text-white placeholder-gray-500 p-3 focus:border-purple-400 focus:outline-none"
                >
                  <option value="">Select zodiac sign (optional)</option>
                  {zodiacSigns.map((sign) => (
                    <option key={sign} value={sign}>
                      {sign.charAt(0).toUpperCase() + sign.slice(1)}
                    </option>
                  ))}
                </select>
              </div>
            </div>

            <div className="rounded-xl border border-purple-500/30 bg-gradient-to-br from-purple-900/20 to-pink-900/20 p-6">
              <h3 className="text-lg font-semibold text-pink-300 mb-4">Second Person</h3>
              <div className="space-y-3">
                <input
                  type="text"
                  value={name2}
                  onChange={(e) => setName2(e.target.value)}
                  placeholder="First name"
                  className="w-full rounded-lg bg-slate-800/50 border border-purple-500/20 text-white placeholder-gray-500 p-3 focus:border-purple-400 focus:outline-none"
                />
                <input
                  type="date"
                  value={birthDate2}
                  onChange={(e) => setBirthDate2(e.target.value)}
                  className="w-full rounded-lg bg-slate-800/50 border border-purple-500/20 text-white placeholder-gray-500 p-3 focus:border-purple-400 focus:outline-none"
                />
                <select
                  value={sign2}
                  onChange={(e) => setSign2(e.target.value)}
                  className="w-full rounded-lg bg-slate-800/50 border border-purple-500/20 text-white placeholder-gray-500 p-3 focus:border-purple-400 focus:outline-none"
                >
                  <option value="">Select zodiac sign (optional)</option>
                  {zodiacSigns.map((sign) => (
                    <option key={sign} value={sign}>
                      {sign.charAt(0).toUpperCase() + sign.slice(1)}
                    </option>
                  ))}
                </select>
              </div>
            </div>
          </div>

          {error && (
            <div className="rounded-lg bg-red-900/20 border border-red-500/30 text-red-300 p-3">
              {error}
            </div>
          )}

          <button
            onClick={handleAnalyze}
            disabled={loading}
            className="w-full rounded-lg bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-500 hover:to-pink-500 disabled:from-gray-600 disabled:to-gray-600 text-white font-semibold py-3 transition-all flex items-center justify-center gap-2"
          >
            {loading ? (
              <>
                <Loader className="w-5 h-5 animate-spin" />
                Analyzing connection...
              </>
            ) : (
              <>
                <Send className="w-5 h-5" />
                Analyze Compatibility
              </>
            )}
          </button>
        </div>
      ) : (
        <div className="space-y-6">
          <div className="rounded-xl border border-purple-500/30 bg-gradient-to-br from-purple-900/20 to-pink-900/20 p-6">
            <h3 className="text-lg font-semibold text-pink-300 mb-2">
              {result.person1} 💕 {result.person2}
            </h3>
            <p className="text-sm text-gray-400">{new Date(result.timestamp).toLocaleDateString()}</p>
          </div>

          <div className="rounded-xl border border-purple-500/30 bg-gradient-to-br from-purple-900/20 to-pink-900/20 p-6">
            <h3 className="text-lg font-semibold text-pink-300 mb-4">✨ Compatibility Analysis</h3>
            <div className="prose prose-invert max-w-none">
              {result.analysis.split('\n').map((paragraph, index) => (
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
              setName1('');
              setName2('');
              setBirthDate1('');
              setBirthDate2('');
              setSign1('');
              setSign2('');
            }}
            className="w-full rounded-lg border border-purple-500/30 hover:border-purple-400 text-purple-300 hover:text-purple-100 font-semibold py-2 transition-all"
          >
            Check Another Compatibility
          </button>
        </div>
      )}
    </div>
  );
}

