import type { Metadata } from 'next';
import './globals.css';
import GhostParticles from '@/components/GhostParticles';
import Link from 'next/link';
import { Ghost, Upload, MapPin, Home } from 'lucide-react';

export const metadata: Metadata = {
  title: 'SnowGhostBreakers - Paranormal Data Upload',
  description: 'Upload and track ghost sightings with AI-powered analysis',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className="dark">
      <body className="min-h-screen bg-ghost-darker relative overflow-x-hidden">
        <GhostParticles />
        <nav className="fixed top-0 w-full z-50 bg-ghost-darker/80 backdrop-blur-xl border-b border-ghost-border">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex items-center justify-between h-16">
              <Link href="/" className="flex items-center gap-3 group">
                <Ghost className="w-8 h-8 text-ghost-green group-hover:animate-ghost-float transition-all" />
                <span className="font-creepy text-2xl text-ghost-green text-glow tracking-wider">
                  SnowGhostBreakers
                </span>
              </Link>
              <div className="flex items-center gap-1">
                <NavLink href="/" icon={<Home className="w-4 h-4" />} label="Dashboard" />
                <NavLink href="/upload" icon={<Upload className="w-4 h-4" />} label="Upload" />
                <NavLink href="/sightings" icon={<MapPin className="w-4 h-4" />} label="Sightings" />
              </div>
            </div>
          </div>
        </nav>
        <main className="pt-20 relative z-10 min-h-screen">
          {children}
        </main>
      </body>
    </html>
  );
}

function NavLink({ href, icon, label }: { href: string; icon: React.ReactNode; label: string }) {
  return (
    <Link
      href={href}
      className="flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-medium text-gray-400 hover:text-ghost-green hover:bg-ghost-green/10 transition-all duration-200"
    >
      {icon}
      {label}
    </Link>
  );
}
