import { Ghost, Activity, MapPin, AlertTriangle } from 'lucide-react';

export default function Dashboard(): JSX.Element {
  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-3xl font-bold text-white">Dashboard</h1>
        <p className="mt-2 text-ghost-purple-300">
          Monitor paranormal activity across all sectors
        </p>
      </div>

      <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
        <div className="card bg-ghost-purple-900/50 border-ghost-purple-700/50">
          <div className="flex items-center gap-4">
            <div className="rounded-lg bg-ghost-purple-600/20 p-3">
              <Ghost className="h-6 w-6 text-ghost-purple-400" />
            </div>
            <div>
              <p className="text-sm text-ghost-purple-300">Total Sightings</p>
              <p className="text-2xl font-bold text-white">1,247</p>
            </div>
          </div>
        </div>

        <div className="card bg-ghost-purple-900/50 border-ghost-purple-700/50">
          <div className="flex items-center gap-4">
            <div className="rounded-lg bg-threat-high-600/20 p-3">
              <AlertTriangle className="h-6 w-6 text-threat-high-400" />
            </div>
            <div>
              <p className="text-sm text-ghost-purple-300">Active Alerts</p>
              <p className="text-2xl font-bold text-white">23</p>
            </div>
          </div>
        </div>

        <div className="card bg-ghost-purple-900/50 border-ghost-purple-700/50">
          <div className="flex items-center gap-4">
            <div className="rounded-lg bg-ghost-blue-600/20 p-3">
              <MapPin className="h-6 w-6 text-ghost-blue-400" />
            </div>
            <div>
              <p className="text-sm text-ghost-purple-300">Active Zones</p>
              <p className="text-2xl font-bold text-white">8</p>
            </div>
          </div>
        </div>

        <div className="card bg-ghost-purple-900/50 border-ghost-purple-700/50">
          <div className="flex items-center gap-4">
            <div className="rounded-lg bg-threat-low-600/20 p-3">
              <Activity className="h-6 w-6 text-threat-low-400" />
            </div>
            <div>
              <p className="text-sm text-ghost-purple-300">Resolved Today</p>
              <p className="text-2xl font-bold text-white">42</p>
            </div>
          </div>
        </div>
      </div>

      <div className="card bg-ghost-purple-900/50 border-ghost-purple-700/50">
        <h2 className="text-lg font-semibold text-white">Recent Activity</h2>
        <p className="mt-4 text-ghost-purple-300">
          Activity feed will be displayed here once connected to Snowflake.
        </p>
      </div>
    </div>
  );
}
