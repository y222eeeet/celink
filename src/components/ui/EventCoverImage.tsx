import Image from "next/image";

const coverImageClass = "object-cover object-center";

interface EventCoverImageProps {
  src: string;
  alt?: string;
  sizes?: string;
  priority?: boolean;
}

/** 리스트 카드 좌측 — 카드 높이에 맞춰 이미지가 꽉 차도록 */
export function EventCoverCardSide({
  src,
  alt = "",
  sizes = "112px",
  priority,
  className = "h-full w-full",
}: EventCoverImageProps & { className?: string }) {
  return (
    <div
      className={`relative min-h-28 overflow-hidden bg-cream-dark ${className}`}
    >
      <Image
        src={src}
        alt={alt}
        fill
        sizes={sizes}
        priority={priority}
        className={coverImageClass}
      />
    </div>
  );
}

/** 리스트·프로필 카드용 정방형 썸네일 */
export function EventCoverThumbnail({
  src,
  alt = "",
  sizes = "112px",
  priority,
  className = "w-28",
}: EventCoverImageProps & { className?: string }) {
  return (
    <div
      className={`relative aspect-square shrink-0 self-start overflow-hidden bg-cream-dark ${className}`}
    >
      <Image
        src={src}
        alt={alt}
        fill
        sizes={sizes}
        priority={priority}
        className={coverImageClass}
      />
    </div>
  );
}

/** 이벤트 상세 히어로 */
export function EventCoverHero({
  src,
  alt = "",
  sizes = "512px",
  priority,
  className = "h-[min(52vw,300px)] min-h-[200px] w-full",
}: EventCoverImageProps & { className?: string }) {
  return (
    <div className={`relative overflow-hidden bg-cream-dark ${className}`}>
      <Image
        src={src}
        alt={alt}
        fill
        sizes={sizes}
        priority={priority}
        className={coverImageClass}
      />
    </div>
  );
}

/** 홈 다가오는 이벤트 featured 카드 */
export function EventCoverFeatured({
  src,
  alt = "",
  sizes = "(max-width: 512px) 100vw, 400px",
  priority,
}: EventCoverImageProps) {
  return (
    <div className="relative aspect-[4/5] w-full overflow-hidden bg-cream-dark">
      <Image
        src={src}
        alt={alt}
        fill
        sizes={sizes}
        priority={priority}
        className={`${coverImageClass} opacity-90 transition duration-300 group-hover:scale-[1.02] group-hover:opacity-100`}
      />
    </div>
  );
}
