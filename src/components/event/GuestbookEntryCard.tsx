import { formatRelative } from "@/lib/utils/date";
import {
  canViewGuestbookEntry,
  guestbookAuthorLabel,
  guestbookEntryContent,
} from "@/lib/utils/guestbook";
import type { GuestbookEntry } from "@/lib/types";

export function GuestbookEntryCard({
  entry,
  viewerName,
  isOwner,
  compact,
}: {
  entry: GuestbookEntry;
  viewerName: string;
  isOwner: boolean;
  compact?: boolean;
}) {
  const canView = canViewGuestbookEntry(entry, viewerName, isOwner);
  const content = guestbookEntryContent(entry, viewerName, isOwner);
  const author = guestbookAuthorLabel(entry, viewerName, isOwner);

  return (
    <div
      className={`rounded-xl border border-blush bg-surface ${
        compact ? "p-3" : "p-4"
      }`}
    >
      <div className="flex items-center justify-between gap-2">
        <div className="flex min-w-0 items-center gap-1.5">
          <p className="truncate text-sm font-semibold text-ink">{author}</p>
          {entry.isPrivate && canView ? (
            <span
              className="shrink-0 text-[10px] text-ink-muted"
              aria-label="비공개 메시지"
            >
              🔒
            </span>
          ) : null}
        </div>
        <p className="shrink-0 text-xs text-ink-muted">
          {formatRelative(entry.createdAt)}
        </p>
      </div>
      <p
        className={`mt-2 text-sm ${
          canView ? "text-ink" : "text-ink-muted"
        }`}
      >
        {content}
      </p>
    </div>
  );
}
