'use client';

import { motion } from 'framer-motion';
import { LucideIcon } from 'lucide-react';

interface StatsCardProps {
  title: string;
  value: string | number;
  icon: LucideIcon;
  color?: 'green' | 'purple' | 'red' | 'yellow';
  subtitle?: string;
}

const colorMap = {
  green: {
    bg: 'bg-ghost-green/10',
    border: 'border-ghost-green/30',
    text: 'text-ghost-green',
    glow: 'shadow-ghost',
  },
  purple: {
    bg: 'bg-ghost-purple/10',
    border: 'border-ghost-purple/30',
    text: 'text-ghost-purple',
    glow: 'shadow-purple',
  },
  red: {
    bg: 'bg-red-500/10',
    border: 'border-red-500/30',
    text: 'text-red-400',
    glow: '',
  },
  yellow: {
    bg: 'bg-yellow-500/10',
    border: 'border-yellow-500/30',
    text: 'text-yellow-400',
    glow: '',
  },
};

export default function StatsCard({ title, value, icon: Icon, color = 'green', subtitle }: StatsCardProps) {
  const c = colorMap[color];

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      whileHover={{ y: -4, scale: 1.02 }}
      className={`relative rounded-xl border ${c.border} ${c.bg} p-6 backdrop-blur-sm card-hover overflow-hidden`}
    >
      <div className="flex items-start justify-between">
        <div>
          <p className="text-sm text-gray-400 font-medium">{title}</p>
          <p className={`text-3xl font-bold mt-2 ${c.text}`}>{value}</p>
          {subtitle && <p className="text-xs text-gray-500 mt-1">{subtitle}</p>}
        </div>
        <div className={`p-3 rounded-lg ${c.bg}`}>
          <Icon className={`w-6 h-6 ${c.text}`} />
        </div>
      </div>
      <div className={`absolute -bottom-4 -right-4 w-24 h-24 rounded-full ${c.bg} blur-2xl opacity-50`} />
    </motion.div>
  );
}
