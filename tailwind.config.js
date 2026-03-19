/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./src/**/*.{js,ts,jsx,tsx,mdx}'],
  theme: {
    extend: {
      colors: {
        ghost: {
          green: '#00ff88',
          purple: '#8b5cf6',
          dark: '#0a0a1a',
          darker: '#050510',
          card: '#111127',
          border: '#1e1e3f',
          muted: '#6b7280',
          glow: 'rgba(0, 255, 136, 0.15)',
        },
      },
      fontFamily: {
        creepy: ['Creepster', 'cursive'],
        body: ['Inter', 'sans-serif'],
      },
      boxShadow: {
        ghost: '0 0 20px rgba(0, 255, 136, 0.3)',
        'ghost-lg': '0 0 40px rgba(0, 255, 136, 0.4)',
        purple: '0 0 20px rgba(139, 92, 246, 0.3)',
      },
      animation: {
        'ghost-float': 'ghostFloat 6s ease-in-out infinite',
        'ghost-pulse': 'ghostPulse 2s ease-in-out infinite',
        'fade-in': 'fadeIn 0.5s ease-out',
        'slide-up': 'slideUp 0.5s ease-out',
      },
      keyframes: {
        ghostFloat: {
          '0%, 100%': { transform: 'translateY(0px) rotate(0deg)', opacity: '0.7' },
          '50%': { transform: 'translateY(-20px) rotate(5deg)', opacity: '1' },
        },
        ghostPulse: {
          '0%, 100%': { boxShadow: '0 0 20px rgba(0, 255, 136, 0.3)' },
          '50%': { boxShadow: '0 0 40px rgba(0, 255, 136, 0.6)' },
        },
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { opacity: '0', transform: 'translateY(20px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
      },
    },
  },
  plugins: [],
};
