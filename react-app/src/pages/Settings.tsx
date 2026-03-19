import { Settings as SettingsIcon, Database, Bell, Palette } from 'lucide-react';

export default function Settings(): JSX.Element {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-white">Settings</h1>
        <p className="mt-2 text-ghost-purple-300">
          Configure your SnowGhost Breakers experience
        </p>
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <div className="card bg-ghost-purple-900/50 border-ghost-purple-700/50">
          <div className="flex items-center gap-3 mb-4">
            <Database className="h-5 w-5 text-ghost-purple-400" />
            <h2 className="text-lg font-semibold text-white">Snowflake Connection</h2>
          </div>
          <div className="space-y-4">
            <div>
              <label className="block text-sm text-ghost-purple-300 mb-1">Account</label>
              <input
                type="text"
                placeholder="your-account.snowflakecomputing.com"
                className="w-full rounded-lg border border-ghost-purple-700 bg-ghost-purple-950 py-2 px-3 text-white placeholder:text-ghost-purple-500 focus:border-ghost-purple-500 focus:outline-none"
              />
            </div>
            <div>
              <label className="block text-sm text-ghost-purple-300 mb-1">Warehouse</label>
              <input
                type="text"
                placeholder="COMPUTE_WH"
                className="w-full rounded-lg border border-ghost-purple-700 bg-ghost-purple-950 py-2 px-3 text-white placeholder:text-ghost-purple-500 focus:border-ghost-purple-500 focus:outline-none"
              />
            </div>
            <button className="btn-primary w-full">Test Connection</button>
          </div>
        </div>

        <div className="card bg-ghost-purple-900/50 border-ghost-purple-700/50">
          <div className="flex items-center gap-3 mb-4">
            <Bell className="h-5 w-5 text-ghost-purple-400" />
            <h2 className="text-lg font-semibold text-white">Notifications</h2>
          </div>
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <span className="text-ghost-purple-300">High threat alerts</span>
              <input type="checkbox" defaultChecked className="rounded" />
            </div>
            <div className="flex items-center justify-between">
              <span className="text-ghost-purple-300">New sightings</span>
              <input type="checkbox" defaultChecked className="rounded" />
            </div>
            <div className="flex items-center justify-between">
              <span className="text-ghost-purple-300">System updates</span>
              <input type="checkbox" className="rounded" />
            </div>
          </div>
        </div>

        <div className="card bg-ghost-purple-900/50 border-ghost-purple-700/50">
          <div className="flex items-center gap-3 mb-4">
            <Palette className="h-5 w-5 text-ghost-purple-400" />
            <h2 className="text-lg font-semibold text-white">Appearance</h2>
          </div>
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <span className="text-ghost-purple-300">Dark mode</span>
              <input type="checkbox" defaultChecked className="rounded" />
            </div>
            <div className="flex items-center justify-between">
              <span className="text-ghost-purple-300">Animations</span>
              <input type="checkbox" defaultChecked className="rounded" />
            </div>
          </div>
        </div>

        <div className="card bg-ghost-purple-900/50 border-ghost-purple-700/50">
          <div className="flex items-center gap-3 mb-4">
            <SettingsIcon className="h-5 w-5 text-ghost-purple-400" />
            <h2 className="text-lg font-semibold text-white">Advanced</h2>
          </div>
          <div className="space-y-4">
            <button className="btn-secondary w-full">Export Data</button>
            <button className="btn-secondary w-full text-threat-high-400 border-threat-high-400/50 hover:bg-threat-high-900/20">
              Clear Cache
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
