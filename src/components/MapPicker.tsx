'use client';

import { useRef, useCallback, useState } from 'react';
import Map, { Marker, NavigationControl, MapRef } from 'react-map-gl/maplibre';
import { MapPin } from 'lucide-react';
import 'maplibre-gl/dist/maplibre-gl.css';

interface MapPickerProps {
  latitude: number;
  longitude: number;
  onLocationChange: (lat: number, lng: number) => void;
}

const MAP_STYLE = 'https://basemaps.cartocdn.com/gl/dark-matter-gl-style/style.json';

export default function MapPicker({ latitude, longitude, onLocationChange }: MapPickerProps) {
  const mapRef = useRef<MapRef>(null);
  const [viewState, setViewState] = useState({
    longitude: longitude || -74.006,
    latitude: latitude || 40.7128,
    zoom: 10,
  });

  const handleClick = useCallback((e: { lngLat: { lng: number; lat: number } }) => {
    onLocationChange(e.lngLat.lat, e.lngLat.lng);
  }, [onLocationChange]);

  return (
    <div className="space-y-2">
      <div className="relative rounded-xl overflow-hidden border border-ghost-border h-[300px]">
        <Map
          ref={mapRef}
          {...viewState}
          onMove={(e) => setViewState(e.viewState)}
          onClick={handleClick}
          mapStyle={MAP_STYLE}
          style={{ width: '100%', height: '100%' }}
        >
          <NavigationControl position="top-right" />
          {latitude !== 0 && longitude !== 0 && (
            <Marker latitude={latitude} longitude={longitude} anchor="bottom">
              <div className="relative">
                <MapPin className="w-8 h-8 text-ghost-green drop-shadow-lg" fill="rgba(0,255,136,0.3)" />
                <div className="absolute -bottom-1 left-1/2 -translate-x-1/2 w-3 h-3 bg-ghost-green rounded-full animate-ping" />
              </div>
            </Marker>
          )}
        </Map>
      </div>
      <div className="flex gap-4">
        <div className="flex-1">
          <label className="text-xs text-gray-500">Latitude</label>
          <input
            type="number"
            step="0.0001"
            value={latitude || ''}
            onChange={(e) => onLocationChange(parseFloat(e.target.value) || 0, longitude)}
            className="w-full mt-1 px-3 py-2 bg-ghost-card border border-ghost-border rounded-lg text-sm text-gray-300 focus:border-ghost-green focus:outline-none"
            placeholder="40.7128"
          />
        </div>
        <div className="flex-1">
          <label className="text-xs text-gray-500">Longitude</label>
          <input
            type="number"
            step="0.0001"
            value={longitude || ''}
            onChange={(e) => onLocationChange(latitude, parseFloat(e.target.value) || 0)}
            className="w-full mt-1 px-3 py-2 bg-ghost-card border border-ghost-border rounded-lg text-sm text-gray-300 focus:border-ghost-green focus:outline-none"
            placeholder="-74.006"
          />
        </div>
      </div>
    </div>
  );
}
