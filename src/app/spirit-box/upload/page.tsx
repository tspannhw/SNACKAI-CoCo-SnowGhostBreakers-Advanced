'use client';

import SpiritBoxUpload from '@/components/SpiritBoxUpload';
import { motion } from 'framer-motion';

export default function SpiritBoxUploadPage() {
  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <motion.div initial={{ opacity: 0, y: -20 }} animate={{ opacity: 1, y: 0 }} className="text-center mb-10">
        <h1 className="text-4xl font-creepy text-ghost-green text-glow tracking-wider">
          Spirit Box Upload
        </h1>
        <p className="text-gray-400 mt-2">Upload audio recordings for AI-powered paranormal analysis</p>
      </motion.div>
      <SpiritBoxUpload />

      <style jsx global>{`
        .form-input {
          width: 100%;
          padding: 0.625rem 0.875rem;
          background: #0a0a1a;
          border: 1px solid #1e1e3f;
          border-radius: 0.75rem;
          color: #e5e7eb;
          font-size: 0.875rem;
          transition: all 0.2s;
        }
        .form-input:focus {
          outline: none;
          border-color: #00ff88;
          box-shadow: 0 0 0 2px rgba(0, 255, 136, 0.1);
        }
        .form-input::placeholder {
          color: #4b5563;
        }
        .form-input option {
          background: #0a0a1a;
          color: #e5e7eb;
        }
      `}</style>
    </div>
  );
}
