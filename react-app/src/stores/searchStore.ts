import { create } from 'zustand';

interface SearchStore {
  query: string;
  setQuery: (q: string) => void;
  chatHistory: Array<{ role: 'user' | 'assistant'; content: string }>;
  addMessage: (role: 'user' | 'assistant', content: string) => void;
  clearChat: () => void;
}

export const useSearchStore = create<SearchStore>((set, get) => ({
  query: '',
  setQuery: (q) => set({ query: q }),
  chatHistory: [],
  addMessage: (role, content) => set({ chatHistory: [...get().chatHistory, { role, content }] }),
  clearChat: () => set({ chatHistory: [] }),
}));
