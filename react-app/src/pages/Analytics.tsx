import { BarChart3, TrendingUp, PieChart } from 'lucide-react';

export default function Analytics(): JSX.Element {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-white">Analytics</h1>
        <p className="mt-2 text-ghost-purple-300">
          Insights and trends from paranormal activity data
        </p>
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <div className="card bg-ghost-purple-900/50 border-ghost-purple-700/50">
          <div className="flex items-center gap-2 mb-4">
            <BarChart3 className="h-5 w-5 text-ghost-purple-400" />
            <h2 className="text-lg font-semibold text-white">Sightings Over Time</h2>
          </div>
          <div className="h-64 flex items-center justify-center text-ghost-purple-400">
            <p>Chart will render here with Recharts</p>
          </div>
        </div>

        <div className="card bg-ghost-purple-900/50 border-ghost-purple-700/50">
          <div className="flex items-center gap-2 mb-4">
            <PieChart className="h-5 w-5 text-ghost-purple-400" />
            <h2 className="text-lg font-semibold text-white">Threat Distribution</h2>
          </div>
          <div className="h-64 flex items-center justify-center text-ghost-purple-400">
            <p>Pie chart will render here with Recharts</p>
          </div>
        </div>

        <div className="card bg-ghost-purple-900/50 border-ghost-purple-700/50 lg:col-span-2">
          <div className="flex items-center gap-2 mb-4">
            <TrendingUp className="h-5 w-5 text-ghost-purple-400" />
            <h2 className="text-lg font-semibold text-white">Activity Trends</h2>
          </div>
          <div className="h-64 flex items-center justify-center text-ghost-purple-400">
            <p>Trend analysis will render here once data is connected</p>
          </div>
        </div>
      </div>
    </div>
  );
}
