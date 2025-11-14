import React, { useState, useRef, useEffect } from 'react';
import { MessageCircle, Send, Loader } from 'lucide-react';

interface Message {
  role: 'user' | 'assistant';
  content: string;
  timestamp: number;
}

export default function ChatAdvisor() {
  const [messages, setMessages] = useState<Message[]>([
    {
      role: 'assistant',
      content: 'Welcome to Kismet. I\'m here to guide you through your spiritual journey. Whether you have questions about your dreams, your path forward, your relationships, or anything touching your soul—I\'m listening. What\'s on your heart today?',
      timestamp: Date.now()
    }
  ]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const handleSendMessage = async () => {
    if (!input.trim()) return;

    const userMessage: Message = {
      role: 'user',
      content: input,
      timestamp: Date.now()
    };

    setMessages(prev => [...prev, userMessage]);
    setInput('');
    setLoading(true);
    setError('');

    try {
      const response = await fetch('/api/chat/ask', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          message: input,
          conversationHistory: messages
        })
      });

      if (!response.ok) throw new Error('Failed to get response');
      
      const data = await response.json();

      const assistantMessage: Message = {
        role: 'assistant',
        content: data.message,
        timestamp: data.timestamp
      };

      setMessages(prev => [...prev, assistantMessage]);
    } catch (err: any) {
      setError(err.message || 'Failed to get response');
      // Remove user message on error
      setMessages(prev => prev.slice(0, -1));
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-3 mb-8">
        <MessageCircle className="w-8 h-8 text-blue-400" />
        <h2 className="text-3xl font-bold text-white">Spiritual Chat with Kismet</h2>
      </div>

      <div className="rounded-xl border border-purple-500/30 bg-gradient-to-br from-purple-900/20 to-pink-900/20 p-6 flex flex-col h-96">
        {/* Messages Container */}
        <div className="flex-1 overflow-y-auto space-y-4 mb-4">
          {messages.map((msg, index) => (
            <div
              key={index}
              className={`flex ${msg.role === 'user' ? 'justify-end' : 'justify-start'}`}
            >
              <div
                className={`max-w-xs lg:max-w-md px-4 py-3 rounded-lg ${
                  msg.role === 'user'
                    ? 'bg-purple-600/40 border border-purple-500/50 text-white rounded-br-none'
                    : 'bg-blue-900/30 border border-blue-500/30 text-gray-200 rounded-bl-none'
                }`}
              >
                <p className="text-sm leading-relaxed">{msg.content}</p>
                <p className="text-xs text-gray-400 mt-1 opacity-50">
                  {new Date(msg.timestamp).toLocaleTimeString([], {
                    hour: '2-digit',
                    minute: '2-digit'
                  })}
                </p>
              </div>
            </div>
          ))}
          
          {loading && (
            <div className="flex justify-start">
              <div className="bg-blue-900/30 border border-blue-500/30 px-4 py-3 rounded-lg rounded-bl-none">
                <div className="flex gap-2">
                  <Loader className="w-4 h-4 animate-spin text-blue-400" />
                  <span className="text-sm text-gray-300">Kismet is thinking...</span>
                </div>
              </div>
            </div>
          )}
          
          {error && (
            <div className="flex justify-start">
              <div className="bg-red-900/30 border border-red-500/30 text-red-300 px-4 py-3 rounded-lg text-sm">
                {error}
              </div>
            </div>
          )}
          
          <div ref={messagesEndRef} />
        </div>

        {/* Input Area */}
        <div className="flex gap-2 border-t border-purple-500/20 pt-4">
          <input
            type="text"
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyPress={(e) => {
              if (e.key === 'Enter' && !loading) {
                handleSendMessage();
              }
            }}
            placeholder="Ask Kismet anything..."
            disabled={loading}
            className="flex-1 rounded-lg bg-slate-800/50 border border-purple-500/20 text-white placeholder-gray-500 p-3 focus:border-purple-400 focus:outline-none transition-colors disabled:opacity-50"
          />
          <button
            onClick={handleSendMessage}
            disabled={loading || !input.trim()}
            className="px-4 py-2 rounded-lg bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-500 hover:to-pink-500 disabled:from-gray-600 disabled:to-gray-600 text-white font-semibold transition-all flex items-center justify-center"
          >
            <Send className="w-5 h-5" />
          </button>
        </div>
      </div>

      {/* Quick Questions */}
      <div className="rounded-xl border border-purple-500/30 bg-gradient-to-br from-purple-900/20 to-pink-900/20 p-6">
        <p className="text-sm text-gray-400 mb-3">Quick questions you could ask:</p>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-2">
          {[
            "What's my spiritual path?",
            "How can I find inner peace?",
            "Guide me through my current challenge",
            "What does my intuition tell me?"
          ].map((question, index) => (
            <button
              key={index}
              onClick={() => {
                setInput(question);
              }}
              className="text-left text-sm px-3 py-2 rounded border border-purple-500/30 text-purple-300 hover:border-purple-400 hover:text-purple-200 transition-all"
            >
              {question}
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}

