import { useState, useRef, useEffect } from 'react';
import { Send, Loader2, Bot, User, Trash2 } from 'lucide-react';
import { useChat } from '@/lib/api';
import { useSearchStore } from '@/stores/searchStore';

export function CortexChat(): JSX.Element {
  const [input, setInput] = useState('');
  const endRef = useRef<HTMLDivElement>(null);
  const chat = useChat();
  const { chatHistory, addMessage, clearChat } = useSearchStore();

  useEffect(() => {
    endRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [chatHistory]);

  const handleSend = () => {
    const msg = input.trim();
    if (!msg || chat.isPending) return;
    addMessage('user', msg);
    setInput('');
    chat.mutate(
      { message: msg, history: chatHistory },
      {
        onSuccess: (res) => addMessage('assistant', res.message),
        onError: (err) => addMessage('assistant', `Error: ${err.message}`),
      }
    );
  };

  return (
    <div className="flex h-[500px] flex-col rounded-xl border border-ghost-purple-700/50 bg-ghost-purple-950/50">
      <div className="flex items-center justify-between border-b border-ghost-purple-700/50 px-4 py-3">
        <div className="flex items-center gap-2">
          <Bot className="h-5 w-5 text-ghost-purple-400" />
          <span className="text-sm font-semibold text-white">Cortex Chat</span>
        </div>
        {chatHistory.length > 0 && (
          <button onClick={clearChat} className="text-ghost-purple-500 transition hover:text-ghost-purple-300">
            <Trash2 className="h-4 w-4" />
          </button>
        )}
      </div>

      <div className="flex-1 space-y-4 overflow-y-auto px-4 py-4">
        {chatHistory.length === 0 && (
          <div className="flex h-full items-center justify-center">
            <p className="text-sm text-ghost-purple-500">Ask me about the paranormal research data...</p>
          </div>
        )}
        {chatHistory.map((msg, i) => (
          <div key={i} className={`flex gap-3 ${msg.role === 'user' ? 'justify-end' : ''}`}>
            {msg.role === 'assistant' && <Bot className="mt-1 h-5 w-5 flex-shrink-0 text-ghost-purple-400" />}
            <div className={`max-w-[80%] rounded-lg px-3 py-2 text-sm ${
              msg.role === 'user'
                ? 'bg-ghost-purple-600 text-white'
                : 'bg-ghost-purple-900/50 text-ghost-purple-200'
            }`}>
              {msg.content}
            </div>
            {msg.role === 'user' && <User className="mt-1 h-5 w-5 flex-shrink-0 text-ghost-purple-400" />}
          </div>
        ))}
        {chat.isPending && (
          <div className="flex gap-3">
            <Bot className="mt-1 h-5 w-5 text-ghost-purple-400" />
            <div className="rounded-lg bg-ghost-purple-900/50 px-3 py-2">
              <Loader2 className="h-4 w-4 animate-spin text-ghost-purple-400" />
            </div>
          </div>
        )}
        <div ref={endRef} />
      </div>

      <div className="border-t border-ghost-purple-700/50 p-3">
        <div className="flex gap-2">
          <input
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={(e) => { if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); handleSend(); } }}
            placeholder="Ask about sightings, recordings, anomalies..."
            className="flex-1 rounded-lg border border-ghost-purple-700 bg-ghost-purple-900/50 px-3 py-2 text-sm text-white placeholder-ghost-purple-500 focus:border-ghost-purple-500 focus:outline-none"
          />
          <button
            onClick={handleSend}
            disabled={!input.trim() || chat.isPending}
            className="rounded-lg bg-ghost-purple-600 px-4 py-2 text-white transition hover:bg-ghost-purple-500 disabled:opacity-50"
          >
            <Send className="h-4 w-4" />
          </button>
        </div>
      </div>
    </div>
  );
}
