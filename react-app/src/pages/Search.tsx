import { useState, useEffect, useCallback } from 'react';
import { Search as SearchIcon, Loader2 } from 'lucide-react';
import { useSearch } from '@/lib/api';
import { useSearchStore } from '@/stores/searchStore';
import { CortexChat } from '@/components/CortexChat';

export default function Search(): JSX.Element {
  const { query, setQuery } = useSearchStore();
  const [localQuery, setLocalQuery] = useState(query);
  const search = useSearch();

  const doSearch = useCallback(() => {
    const q = localQuery.trim();
    if (!q) return;
    setQuery(q);
    search.mutate({ query: q, limit: 20 });
  }, [localQuery, setQuery, search]);

  useEffect(() => {
    const timer = setTimeout(() => {
      if (localQuery.trim().length >= 3) {
        doSearch();
      }
    }, 500);
    return () => clearTimeout(timer);
  }, [localQuery, doSearch]);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-white">Search &amp; Chat</h1>
        <p className="mt-2 text-ghost-purple-300">
          Search recordings with Cortex Search and chat with your research data
        </p>
      </div>

      <div className="flex gap-2">
        <div className="relative flex-1">
          <SearchIcon className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-ghost-purple-500" />
          <input
            value={localQuery}
            onChange={(e) => setLocalQuery(e.target.value)}
            onKeyDown={(e) => { if (e.key === 'Enter') doSearch(); }}
            placeholder="Search recordings, locations, transcripts..."
            className="w-full rounded-lg border border-ghost-purple-700 bg-ghost-purple-900/50 py-2.5 pl-10 pr-4 text-sm text-white placeholder-ghost-purple-500 focus:border-ghost-purple-500 focus:outline-none"
          />
        </div>
        <button
          onClick={doSearch}
          disabled={search.isPending}
          className="rounded-lg bg-ghost-purple-600 px-4 py-2 text-sm text-white transition hover:bg-ghost-purple-500 disabled:opacity-50"
        >
          {search.isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : 'Search'}
        </button>
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <div className="space-y-4">
          <h2 className="text-lg font-semibold text-white">Search Results</h2>

          {search.isPending && (
            <div className="flex justify-center py-8">
              <Loader2 className="h-6 w-6 animate-spin text-ghost-purple-400" />
            </div>
          )}

          {search.data && search.data.count === 0 && (
            <div className="rounded-xl border border-dashed border-ghost-purple-700/50 bg-ghost-purple-900/20 p-8 text-center">
              <p className="text-ghost-purple-400">No results found for &ldquo;{search.data.query}&rdquo;</p>
            </div>
          )}

          {search.data?.results.map((result, i) => (
            <div key={i} className="card bg-ghost-purple-900/50 border-ghost-purple-700/50">
              <div className="flex items-start justify-between">
                <p className="text-sm font-medium text-white">
                  {String(result['FILE_NAME'] ?? result['RECORDING_ID'] ?? `Result ${i + 1}`)}
                </p>
                {result['CLASSIFICATION_RESULT'] != null && (
                  <span className="rounded-full bg-ghost-purple-800/50 px-2 py-0.5 text-xs text-ghost-purple-300">
                    {String(result['CLASSIFICATION_RESULT'])}
                  </span>
                )}
              </div>
              {result['LOCATION_NAME'] != null && (
                <p className="mt-1 text-xs text-ghost-purple-400">{String(result['LOCATION_NAME'])}</p>
              )}
              {(result['AI_SUMMARY'] != null || result['SEARCHABLE_TEXT'] != null) && (
                <p className="mt-2 line-clamp-3 text-xs text-ghost-purple-300">
                  {String(result['AI_SUMMARY'] ?? result['SEARCHABLE_TEXT'] ?? '').substring(0, 300)}
                </p>
              )}
            </div>
          ))}

          {search.data?.fallback && (
            <p className="text-xs text-ghost-purple-500">Results from fallback search (Cortex Search may be suspended)</p>
          )}
        </div>

        <div>
          <h2 className="mb-4 text-lg font-semibold text-white">Cortex Chat</h2>
          <CortexChat />
        </div>
      </div>
    </div>
  );
}
