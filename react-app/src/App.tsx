import { Routes, Route, Navigate, Link } from 'react-router-dom';
import { Suspense, lazy } from 'react';
import { Ghost } from 'lucide-react';

// Lazy-loaded page components
const Dashboard = lazy(() => import('@/pages/Dashboard'));
const Sightings = lazy(() => import('@/pages/Sightings'));
const Analytics = lazy(() => import('@/pages/Analytics'));
const Map = lazy(() => import('@/pages/Map'));
const Settings = lazy(() => import('@/pages/Settings'));
const Capture = lazy(() => import('@/pages/Capture'));
const MediaDashboard = lazy(() => import('@/pages/MediaDashboard'));
const MediaDetail = lazy(() => import('@/pages/MediaDetail'));
const Search = lazy(() => import('@/pages/Search'));

// Loading fallback component
function LoadingFallback(): JSX.Element {
  return (
    <div className="flex min-h-screen items-center justify-center bg-ghost-purple-950">
      <div className="flex flex-col items-center gap-4">
        <Ghost className="h-16 w-16 animate-ghost-float text-ghost-purple-400" />
        <div className="h-2 w-32 overflow-hidden rounded-full bg-ghost-purple-800">
          <div className="h-full w-1/2 animate-pulse rounded-full bg-ghost-purple-500" />
        </div>
        <p className="text-sm text-ghost-purple-300">Loading...</p>
      </div>
    </div>
  );
}

// Layout component
function Layout({ children }: { children: React.ReactNode }): JSX.Element {
  return (
    <div className="min-h-screen bg-gradient-to-br from-ghost-purple-950 via-ghost-blue-950 to-ghost-purple-900">
      <nav className="border-b border-ghost-purple-800/50 bg-ghost-purple-950/80 backdrop-blur-sm">
        <div className="mx-auto flex h-16 max-w-7xl items-center justify-between px-4">
          <div className="flex items-center gap-3">
            <Ghost className="h-8 w-8 text-ghost-purple-400" />
            <span className="text-xl font-bold text-white">SnowGhost Breakers</span>
          </div>
          <div className="flex items-center gap-6">
            <Link to="/" className="text-sm text-ghost-purple-300 hover:text-white transition-colors">
              Dashboard
            </Link>
            <Link to="/sightings" className="text-sm text-ghost-purple-300 hover:text-white transition-colors">
              Sightings
            </Link>
            <Link to="/capture" className="text-sm text-ghost-purple-300 hover:text-white transition-colors">
              Capture
            </Link>
            <Link to="/media" className="text-sm text-ghost-purple-300 hover:text-white transition-colors">
              Media
            </Link>
            <Link to="/search" className="text-sm text-ghost-purple-300 hover:text-white transition-colors">
              Search
            </Link>
            <Link to="/analytics" className="text-sm text-ghost-purple-300 hover:text-white transition-colors">
              Analytics
            </Link>
            <Link to="/map" className="text-sm text-ghost-purple-300 hover:text-white transition-colors">
              Map
            </Link>
            <Link to="/settings" className="text-sm text-ghost-purple-300 hover:text-white transition-colors">
              Settings
            </Link>
          </div>
        </div>
      </nav>
      <main className="mx-auto max-w-7xl px-4 py-8">{children}</main>
    </div>
  );
}

function App(): JSX.Element {
  return (
    <Layout>
      <Suspense fallback={<LoadingFallback />}>
        <Routes>
          <Route path="/" element={<Dashboard />} />
          <Route path="/sightings" element={<Sightings />} />
          <Route path="/capture" element={<Capture />} />
          <Route path="/media" element={<MediaDashboard />} />
          <Route path="/media/:id" element={<MediaDetail />} />
          <Route path="/search" element={<Search />} />
          <Route path="/analytics" element={<Analytics />} />
          <Route path="/map" element={<Map />} />
          <Route path="/settings" element={<Settings />} />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </Suspense>
    </Layout>
  );
}

export default App;
