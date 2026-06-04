import { getHostEmojiSticker } from "@/lib/constants/host-emoji";

export function HostEmojiSticker({
  stickerId,
  size = 48,
  className = "",
}: {
  stickerId: string;
  size?: number;
  className?: string;
}) {
  const sticker = getHostEmojiSticker(stickerId);
  if (!sticker) return null;

  return (
    // eslint-disable-next-line @next/next/no-img-element
    <img
      src={sticker.imageUrl}
      alt={sticker.label}
      width={size}
      height={size}
      className={`shrink-0 object-contain ${className}`}
    />
  );
}
