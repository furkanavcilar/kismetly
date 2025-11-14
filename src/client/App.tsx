import React, { useState } from 'react';
import { Sparkles, Moon, Star, Heart, Wand2, MessageCircle } from 'lucide-react';
import DreamInterpreter from './components/DreamInterpreter';
import HoroscopeReader from './components/HoroscopeReader';
import TarotReader from './components/TarotReader';
import LoveCompatibility from './components/LoveCompatibility';
import ChatAdvisor from './components/ChatAdvisor';

type Feature = 'home' | 'dreams' | 'horoscope' | 'tarot' | 'compatibility' | 'chat';

function App() {
  const [currentFeature, setCurrentFeature] = useState<Feature>('home');

  const features = [
    {
      id: 'dreams',
      name: 'Dream Interpreter',
      icon: Moon,
      description: 'Unlock the mystical meanings hidden in your dreams'
    },
    {
      id: 'horoscope',
      name: 'Horoscope Reader',
      icon: Star,
      description: 'Discover your cosmic guidance for today'
    },
    {
      id: 'tarot',
      name: 'Tarot Cards',
      icon: Wand2,
      description: 'Draw cards for spiritual insight and direction'
    },
    {
      id: 'compatibility',
      name: 'Love Compatibility',
      icon: Heart,
      description: 'Explore the connection between two souls'
    },
    {
      id: 'chat',
      name: 'Spiritual Chat',
      icon: MessageCircle,
      description: 'Ask Kismet anything about your spiritual journey'
    }
  ];

  const renderFeature = () => {
    switch (currentFeature) {
      case 'dreams':
        return <DreamInterpreter />;
      case 'horoscope':
        return <HoroscopeReader />;
      case 'tarot':
        return <TarotReader />;
      case 'compatibility':
        return <LoveCompatibility />;
      case 'chat':
        return <ChatAdvisor />;
      default:
        return (
          <div className="space-y-8">
            <div className="text-center space-y-4">
              <div className="flex justify-center">
                <Sparkles className="w-16 h-16 text-purple-400 animate-pulse" />
              </div>
              <h1 className="text-4xl md:text-5xl font-bold bg-gradient-to-r from-purple-400 via-pink-400 to-purple-400 bg-clip-text text-transparent">
                Welcome to Kismetly
              </h1>
              <p className="text-xl text-gray-300 max-w-2xl mx-auto">
                Your personal AI spiritual guide. Every insight is uniquely generated just for you.
              </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {features.map((feature) => {
                const Icon = feature.icon;
                return (
                  <button
                    key={feature.id}
                    onClick={() => setCurrentFeature(feature.id as Feature)}
                    className="group relative overflow-hidden rounded-xl border border-purple-500/30 bg-gradient-to-br from-purple-900/20 to-pink-900/20 p-6 hover:border-purple-400 transition-all duration-300 hover:shadow-lg hover:shadow-purple-500/20"
                  >
                    <div className="relative z-10">
                      <Icon className="w-10 h-10 text-purple-400 mb-4 group-hover:text-pink-400 transition-colors" />
                      <h3 className="text-lg font-semibold text-white mb-2">{feature.name}</h3>
                      <p className="text-sm text-gray-300">{feature.description}</p>
                    </div>
                    <div className="absolute inset-0 bg-gradient-to-br from-purple-600/0 to-pink-600/0 group-hover:from-purple-600/10 group-hover:to-pink-600/10 transition-all duration-300" />
                  </button>
                );
              })}
            </div>
          </div>
        );
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900">
      {/* Animated background */}
      <div className="fixed inset-0 opacity-30">
        <div className="absolute inset-0 bg-gradient-to-br from-purple-600/20 via-transparent to-pink-600/20" />
        <div className="absolute top-0 -right-40 w-80 h-80 bg-purple-500/10 rounded-full blur-3xl animate-pulse" />
        <div className="absolute -bottom-40 -left-40 w-80 h-80 bg-pink-500/10 rounded-full blur-3xl animate-pulse" />
      </div>

      {/* Header */}
      <header className="relative border-b border-purple-500/20 bg-slate-900/50 backdrop-blur">
        <div className="max-w-7xl mx-auto px-4 py-4 flex items-center justify-between">
          <button
            onClick={() => setCurrentFeature('home')}
            className="flex items-center gap-2 group"
          >
            <Sparkles className="w-6 h-6 text-purple-400 group-hover:text-pink-400 transition-colors" />
            <h1 className="text-2xl font-bold bg-gradient-to-r from-purple-400 to-pink-400 bg-clip-text text-transparent">
              Kismetly
            </h1>
          </button>
          <p className="text-sm text-gray-400">✨ AI-Powered Spiritual Guidance ✨</p>
        </div>
      </header>

      {/* Main Content */}
      <main className="relative max-w-7xl mx-auto px-4 py-8">
        {currentFeature !== 'home' && (
          <button
            onClick={() => setCurrentFeature('home')}
            className="mb-6 px-4 py-2 rounded-lg border border-purple-500/30 text-purple-300 hover:text-purple-100 hover:border-purple-400 transition-all"
          >
            ← Back to Home
          </button>
        )}
        {renderFeature()}
      </main>

      {/* Footer */}
      <footer className="relative border-t border-purple-500/20 bg-slate-900/50 backdrop-blur mt-12">
        <div className="max-w-7xl mx-auto px-4 py-8 text-center text-sm text-gray-400">
          <p>🔮 Every reading is uniquely generated by AI in real-time 🔮</p>
          <p className="mt-2">Kismetly - Your Personal Spiritual Guide</p>
        </div>
      </footer>
    </div>
  );
}

export default App;

