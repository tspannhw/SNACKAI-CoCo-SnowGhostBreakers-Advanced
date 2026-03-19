import { MapPin, Layers } from 'lucide-react';

export default function Map(): JSX.Element {
  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-white">Map</h1>
          <p className="mt-2 text-ghost-purple-300">
            Geographic visualization of paranormal activity
          </p>
        </div>
        <div className="flex gap-2">
          <button className="btn-secondary">
            <Layers className="mr-2 h-4 w-4" />
            Layers
          </button>
          <button className="btn-primary">
            <MapPin className="mr-2 h-4 w-4" />
            Center Map
          </button>
        </div>
      </div>

      <div className="card bg-ghost-purple-900/50 border-ghost-purple-700/50 p-0 overflow-hidden">
        <div className="h-[600px] flex items-center justify-center bg-ghost-purple-950">
          <div className="text-center">
            <MapPin className="mx-auto h-12 w-12 text-ghost-purple-500 mb-4" />
            <p className="text-ghost-purple-300">
              Leaflet map will render here.
            </p>
            <p className="text-sm text-ghost-purple-400 mt-2">
              Import and configure react-leaflet to enable the map view.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
