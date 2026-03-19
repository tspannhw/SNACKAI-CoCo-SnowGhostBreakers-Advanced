import { Ghost, Search, Filter } from 'lucide-react';

export default function Sightings(): JSX.Element {
  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-white">Sightings</h1>
          <p className="mt-2 text-ghost-purple-300">
            Browse and analyze paranormal sighting reports
          </p>
        </div>
        <button className="btn-primary">
          <Ghost className="mr-2 h-4 w-4" />
          Report Sighting
        </button>
      </div>

      <div className="flex gap-4">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-ghost-purple-400" />
          <input
            type="text"
            placeholder="Search sightings..."
            className="w-full rounded-lg border border-ghost-purple-700 bg-ghost-purple-900/50 py-2 pl-10 pr-4 text-white placeholder:text-ghost-purple-400 focus:border-ghost-purple-500 focus:outline-none focus:ring-2 focus:ring-ghost-purple-500/20"
          />
        </div>
        <button className="btn-secondary">
          <Filter className="mr-2 h-4 w-4" />
          Filters
        </button>
      </div>

      <div className="card bg-ghost-purple-900/50 border-ghost-purple-700/50">
        <p className="text-center text-ghost-purple-300">
          Sighting data will be loaded from Snowflake once configured.
        </p>
      </div>
    </div>
  );
}
