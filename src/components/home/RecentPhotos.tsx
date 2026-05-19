import Image from "next/image";
import Link from "next/link";
import type { RecentPhoto } from "@/lib/types";
import { formatRelative } from "@/lib/utils/date";

interface RecentPhotosProps {
  photos: RecentPhoto[];
}

export function RecentPhotos({ photos }: RecentPhotosProps) {
  if (photos.length === 0) return null;

  return (
    <section className="mt-10 px-5" aria-labelledby="photos-heading">
      <div className="mb-3 flex items-end justify-between">
        <h2
          id="photos-heading"
          className="text-xs font-semibold uppercase tracking-widest text-rose-deep"
        >
          최근 업로드
        </h2>
        <Link
          href="/profile"
          className="text-xs text-ink-muted underline-offset-2 hover:text-ink hover:underline"
        >
          전체 보기
        </Link>
      </div>
      <div className="grid grid-cols-4 gap-1.5">
        {photos.slice(0, 4).map((photo) => (
          <Link
            key={photo.id}
            href={`/events/${photo.eventId}/album`}
            className="group relative aspect-square overflow-hidden rounded-lg bg-cream-dark"
          >
            <Image
              src={photo.imageUrl}
              alt={`${photo.eventTitle} 사진`}
              fill
              className="object-cover transition group-hover:opacity-90"
              sizes="25vw"
            />
            <div className="absolute inset-x-0 bottom-0 bg-gradient-to-t from-stone-900/70 to-transparent p-1.5 opacity-0 transition group-hover:opacity-100">
              <p className="truncate text-[9px] text-white">
                {formatRelative(photo.uploadedAt)}
              </p>
            </div>
          </Link>
        ))}
      </div>
    </section>
  );
}
