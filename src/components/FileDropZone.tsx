'use client';

import { useCallback, useState } from 'react';
import { useDropzone } from 'react-dropzone';
import { motion, AnimatePresence } from 'framer-motion';
import { Upload, X, FileImage, FileAudio, FileVideo, File } from 'lucide-react';

interface FileDropZoneProps {
  onFilesChange: (files: File[]) => void;
}

const iconMap: Record<string, typeof File> = {
  image: FileImage,
  audio: FileAudio,
  video: FileVideo,
};

function getFileIcon(type: string) {
  const category = type.split('/')[0];
  return iconMap[category] || File;
}

function formatSize(bytes: number) {
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1048576) return `${(bytes / 1024).toFixed(1)} KB`;
  return `${(bytes / 1048576).toFixed(1)} MB`;
}

export default function FileDropZone({ onFilesChange }: FileDropZoneProps) {
  const [files, setFiles] = useState<File[]>([]);

  const onDrop = useCallback((accepted: File[]) => {
    const updated = [...files, ...accepted];
    setFiles(updated);
    onFilesChange(updated);
  }, [files, onFilesChange]);

  const removeFile = (index: number) => {
    const updated = files.filter((_, i) => i !== index);
    setFiles(updated);
    onFilesChange(updated);
  };

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: {
      'image/*': ['.png', '.jpg', '.jpeg', '.gif', '.webp'],
      'audio/*': ['.mp3', '.wav', '.ogg'],
      'video/*': ['.mp4', '.webm', '.mov'],
    },
    maxSize: 50 * 1024 * 1024,
  });

  return (
    <div className="space-y-4">
      <div
        {...getRootProps()}
        className={`relative border-2 border-dashed rounded-xl p-8 text-center cursor-pointer transition-all duration-300 ${
          isDragActive
            ? 'border-ghost-green bg-ghost-green/10 shadow-ghost'
            : 'border-ghost-border hover:border-ghost-green/50 hover:bg-ghost-green/5'
        }`}
      >
        <input {...getInputProps()} />
        <motion.div
          animate={isDragActive ? { scale: 1.1, y: -5 } : { scale: 1, y: 0 }}
          className="flex flex-col items-center gap-3"
        >
          <Upload className={`w-12 h-12 ${isDragActive ? 'text-ghost-green' : 'text-gray-500'}`} />
          <div>
            <p className="text-lg font-medium text-gray-300">
              {isDragActive ? 'Drop your evidence here...' : 'Drag & drop evidence files'}
            </p>
            <p className="text-sm text-gray-500 mt-1">
              Images, audio, or video — up to 50MB each
            </p>
          </div>
        </motion.div>
      </div>

      <AnimatePresence>
        {files.map((file, i) => {
          const Icon = getFileIcon(file.type);
          return (
            <motion.div
              key={`${file.name}-${i}`}
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 20 }}
              className="flex items-center gap-3 p-3 rounded-lg bg-ghost-card border border-ghost-border"
            >
              <Icon className="w-5 h-5 text-ghost-green flex-shrink-0" />
              <div className="flex-1 min-w-0">
                <p className="text-sm text-gray-300 truncate">{file.name}</p>
                <p className="text-xs text-gray-500">{formatSize(file.size)}</p>
              </div>
              <button
                onClick={() => removeFile(i)}
                className="p-1 rounded-md hover:bg-red-500/20 text-gray-500 hover:text-red-400 transition-colors"
              >
                <X className="w-4 h-4" />
              </button>
            </motion.div>
          );
        })}
      </AnimatePresence>
    </div>
  );
}
