import type { GuestbookEntry } from "@/lib/types";

export function canViewGuestbookEntry(
  entry: GuestbookEntry,
  viewerName: string,
  isOwner: boolean
): boolean {
  if (!entry.isPrivate) return true;
  if (isOwner) return true;
  return entry.authorName.trim() === viewerName.trim();
}

export function guestbookEntryContent(
  entry: GuestbookEntry,
  viewerName: string,
  isOwner: boolean
): string {
  if (canViewGuestbookEntry(entry, viewerName, isOwner)) {
    return entry.content;
  }
  return "비공개 메시지";
}

export function guestbookAuthorLabel(
  entry: GuestbookEntry,
  viewerName: string,
  isOwner: boolean
): string {
  if (!entry.isPrivate || canViewGuestbookEntry(entry, viewerName, isOwner)) {
    return entry.authorName;
  }
  return "비공개 메시지";
}
