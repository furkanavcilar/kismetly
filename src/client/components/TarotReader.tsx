import React, { useState } from 'react';
import { Wand2, Send, Loader } from 'lucide-react';

interface TarotResponse {
  question: string;
  spreadType: string;
  spreadName: string;
  cards: Array<{ name: string; arcana: string }>;
  reversedCards: string[];
  reading: string;
  timestamp: string;
}

export default function TarotReader() {
  const [question, setQuestion] = useState('');
  const [spreadType, setSpreadType] = useState<'single' | 'threesome' | 'celtic_cross' | 'horseshoe'>('single');
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<TarotResponse | null>(null);
  const [error, setError] = useState('');

  const spreads = [
    { value: 'single', label: 'Single Card', description: 'A focused insight' },
    { value: 'threesome', label: 'Three-Card', description: 'Past, Present, Future' },
    { value: 'celtic_cross', label: 'Celtic Cross', description: 'Comprehensive reading' },
    { value: 'horseshoe', label: 'Horseshoe', description: 'Outcome-focused' }
  ];

  const handleDraw = async () => {
    if (!question.trim()) {
      setError('Please ask a question for the cards');
      return;
    }

    setLoading(true);
    setError('');
    
    try {
      const response = await fetch('/api/tarot/draw', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ question, spreadType })
      });

      if (!response.ok) throw new Error('Failed to draw cards');
      
      const data = await response.json();
      setResult(data);
    } catch (err: any) {
      setError(err.message || 'Failed to draw cards');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-3 mb-8">
        <Wand2 className="w-8 h-8 text-indigo-400" />
        <h2 className="text-3xl font-bold text-white">Tarot Reader</h2>
      </div>

      {!result ? (
        <div className="space-y-4">
          <div className="rounded-xl border border-purple-500/30 bg-gradient-to-br from-purple-900/20 to-pink-900/20 p-6">
            <label className="block text-sm font-medium text-gray-300 mb-2">
              What would you like to ask the cards?
            </label>
            <textarea
              value={question}
              onChange={(e) => setQuestion(e.target.value)}
              placeholder="Ask a question about your situation, challenge, or future..."
              className="w-full h-32 rounded-lg bg-slate-800/50 border border-purple-500/20 text-white placeholder-gray-500 p-4 focus:border-purple-400 focus:outline-none transition-colors"
            />
          </div>

          <div className="rounded-xl border border-purple-500/30 bg-gradient-to-br from-purple-900/20 to-pink-900/20 p-6">
            <label className="block text-sm font-medium text-gray-300 mb-4">
              Choose a Spread:
            </label>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              {spreads.map((spread) => (
                <button
                  key={spread.value}
                  onClick={() => setSpreadType(spread.value as any)}
                  className={`p-4 rounded-lg border transition-all text-left ${
                    spreadType === spread.value
                      ? 'border-purple-400 bg-purple-900/40'
                      : 'border-purple-500/20 bg-slate-800/20 hover:border-purple-500/40'
                  }`}
                >
                  <div className="font-semibold text-white">{spread.label}</div>
                  <div className="text-sm text-gray-400">{spread.description}</div>
                </button>
              ))}
            </div>
          </div>

          {error && (
            <div className="rounded-lg bg-red-900/20 border border-red-500/30 text-red-300 p-3">
              {error}
            </div>
          )}

          <button
            onClick={handleDraw}
            disabled={loading}
            className="w-full rounded-lg bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-500 hover:to-pink-500 disabled:from-gray-600 disabled:to-gray-600 text-white font-semibold py-3 transition-all flex items-center justify-center gap-2"
          >
            {loading ? (
              <>
                <Loader className="w-5 h-5 animate-spin" />
                Drawing cards...
              </>
            ) : (
              <>
                <Send className="w-5 h-5" />
                Draw Cards
              </>
            )}
          </button>
        </div>
      ) : (
        <div className="space-y-6">
          <div className="rounded-xl border border-purple-500/30 bg-gradient-to-br from-purple-900/20 to-pink-900/20 p-6">
            <h3 className="text-sm font-medium text-gray-400 mb-2">Spread: {result.spreadName}</h3>
            <p className="text-white font-semibold mb-4">Your Question: {result.question}</p>
            <div className="grid grid-cols-auto gap-2 mb-4">
              {result.reversedCards.map((card, index) => (
                <div key={index} className="px-3 py-2 bg-slate-800/50 border border-purple-500/20 rounded text-sm text-purple-300">
                  {card}
                </div>
              ))}
            </div>
          </div>

          <div className="rounded-xl border border-purple-500/30 bg-gradient-to-br from-purple-900/20 to-pink-900/20 p-6">
            <h3 className="text-lg font-semibold text-indigo-300 mb-4">✨ The Reading</h3>
            <div className="prose prose-invert max-w-none">
              {result.reading.split('\n').map((paragraph, index) => (
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
              setQuestion('');
            }}
            className="w-full rounded-lg border border-purple-500/30 hover:border-purple-400 text-purple-300 hover:text-purple-100 font-semibold py-2 transition-all"
          >
            Draw New Cards
          </button>
        </div>
      )}
    </div>
  );
}

