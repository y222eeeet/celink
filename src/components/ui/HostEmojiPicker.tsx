"use client";

import { HOST_EMOJI_STICKERS } from "@/lib/constants/host-emoji";

interface HostEmojiPickerProps {
  open: boolean;
  selectedId: string | null;
  onSelect: (stickerId: string) => void;
  onClose: () => void;
}

export function HostEmojiPickerButton({
  active,
  onClick,
}: {
  active: boolean;
  onClick: () => void;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      aria-label="주최자 이모티콘"
      aria-expanded={active}
      className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-xl border text-lg transition ${
        active
          ? "border-primary bg-primary/15 text-primary-deep"
          : "border-blush bg-surface text-ink-muted hover:bg-cream-dark"
      }`}
    >
      😊
    </button>
  );
}

export function HostEmojiPickerPanel({
  open,
  selectedId,
  onSelect,
  onClose,
}: HostEmojiPickerProps) {
  if (!open) return null;

  return (
    <div className="rounded-xl border border-blush bg-surface p-3">
      <div className="mb-2 flex items-center justify-between">
        <p className="text-xs font-semibold text-ink-muted">지우님 이모티콘</p>
        <button
          type="button"
          onClick={onClose}
          className="text-xs text-primary-deep"
        >
          닫기
        </button>
      </div>
      <div className="grid grid-cols-4 gap-2">
        {HOST_EMOJI_STICKERS.map((sticker) => (
          <button
            key={sticker.id}
            type="button"
            onClick={() => onSelect(sticker.id)}
            className={`flex flex-col items-center gap-1 rounded-lg p-2 transition ${
              selectedId === sticker.id
                ? "bg-primary/15 ring-2 ring-primary/40"
                : "hover:bg-cream-dark"
            }`}
          >
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              src={sticker.imageUrl}
              alt={sticker.label}
              width={48}
              height={48}
              className="h-12 w-12 object-contain"
            />
            <span className="text-[10px] text-ink-muted">{sticker.label}</span>
          </button>
        ))}
      </div>
    </div>
  );
}
