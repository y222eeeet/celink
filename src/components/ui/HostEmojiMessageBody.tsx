import { HostEmojiSticker } from "@/components/ui/HostEmojiSticker";

export function HostEmojiMessageBody({
  content,
  stickerId,
}: {
  content: string;
  stickerId?: string | null;
}) {
  const hasText = content.trim().length > 0;
  const hasSticker = Boolean(stickerId);

  if (!hasText && !hasSticker) return null;

  return (
    <div className="mt-2 space-y-2">
      {hasSticker && stickerId ? (
        <HostEmojiSticker stickerId={stickerId} size={56} />
      ) : null}
      {hasText ? <p className="text-sm text-ink">{content}</p> : null}
    </div>
  );
}
