import * as Tabs from '@radix-ui/react-tabs';
import { Mic, Camera, Video, Upload } from 'lucide-react';
import { AudioRecorder } from '@/components/media/AudioRecorder';
import { PhotoCapture } from '@/components/media/PhotoCapture';
import { VideoRecorder } from '@/components/media/VideoRecorder';
import { MediaUploadForm } from '@/components/media/MediaUploadForm';
import { useMediaStore } from '@/stores/mediaStore';

export default function Capture(): JSX.Element {
  const { clearCapture } = useMediaStore();

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-white">Media Capture</h1>
        <p className="mt-2 text-ghost-purple-300">
          Record audio, take photos, or capture video for paranormal investigation
        </p>
      </div>

      <Tabs.Root defaultValue="audio" onValueChange={() => clearCapture()}>
        <Tabs.List className="flex gap-1 rounded-lg bg-ghost-purple-900/50 p-1">
          <Tabs.Trigger
            value="audio"
            className="flex flex-1 items-center justify-center gap-2 rounded-md px-4 py-2.5 text-sm text-ghost-purple-300 transition data-[state=active]:bg-ghost-purple-700 data-[state=active]:text-white"
          >
            <Mic className="h-4 w-4" /> Audio
          </Tabs.Trigger>
          <Tabs.Trigger
            value="photo"
            className="flex flex-1 items-center justify-center gap-2 rounded-md px-4 py-2.5 text-sm text-ghost-purple-300 transition data-[state=active]:bg-ghost-purple-700 data-[state=active]:text-white"
          >
            <Camera className="h-4 w-4" /> Photo
          </Tabs.Trigger>
          <Tabs.Trigger
            value="video"
            className="flex flex-1 items-center justify-center gap-2 rounded-md px-4 py-2.5 text-sm text-ghost-purple-300 transition data-[state=active]:bg-ghost-purple-700 data-[state=active]:text-white"
          >
            <Video className="h-4 w-4" /> Video
          </Tabs.Trigger>
        </Tabs.List>

        <div className="mt-4">
          <Tabs.Content value="audio"><AudioRecorder /></Tabs.Content>
          <Tabs.Content value="photo"><PhotoCapture /></Tabs.Content>
          <Tabs.Content value="video"><VideoRecorder /></Tabs.Content>
        </div>
      </Tabs.Root>

      <div>
        <h2 className="mb-3 flex items-center gap-2 text-lg font-semibold text-white">
          <Upload className="h-5 w-5" /> Upload Details
        </h2>
        <MediaUploadForm />
      </div>
    </div>
  );
}
