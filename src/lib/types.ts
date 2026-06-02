export type EventType = "wedding" | "exhibition" | "performance" | "dol";

export type RSVPStatus = "pending" | "yes" | "no" | "maybe";

export type RelationType =
  | "family"
  | "bestFriend"
  | "friend"
  | "coworker"
  | "acquaintance"
  | "etc";

export interface EventSummary {
  id: string;
  type: EventType;
  title: string;
  date: string;
  location: string;
  coverImage: string;
  hostName: string;
  rsvpStatus: RSVPStatus;
  lastParticipatedAt: string | null;
  isUpcoming: boolean;
}

export interface ScheduleItem {
  id: string;
  time: string;
  title: string;
  note?: string | null;
}

export interface GuestbookEntry {
  id: string;
  authorName: string;
  content: string;
  isPrivate: boolean;
  createdAt: string;
}

export interface EventDetail {
  summary: EventSummary;
  description: string;
  dressCode?: string | null;
  notice?: string | null;
  schedule: ScheduleItem[];
  guestbook: GuestbookEntry[];
  photoURLs: string[];
}

export interface RecentPhoto {
  id: string;
  eventId: string;
  eventTitle: string;
  imageUrl: string;
  uploadedAt: string;
}

export interface Reminder {
  id: string;
  eventId: string;
  eventTitle: string;
  message: string;
}

export interface PhotoComment {
  id: string;
  authorName: string;
  content: string;
  createdAt: string;
}

export interface PhotoSocialState {
  likeCount: number;
  isLiked: boolean;
  comments: PhotoComment[];
}

export interface CelebrationLedgerEntry {
  id: string;
  senderName: string;
  relation: RelationType;
  amount: number;
}

export interface InvitedParticipantEntry {
  id: string;
  name: string;
  relation: RelationType;
  rsvpStatus: RSVPStatus;
}

export interface EventLedgerOverview {
  id: string;
  eventTitle: string;
  amount: number;
}

export interface SentGiftEntry {
  id: string;
  eventId: string;
  eventTitle: string;
  amount: number;
}

export interface EditableScheduleItem {
  id: string;
  time: string;
  title: string;
  note: string;
}

export type CreateEventStep = "type" | "basics" | "cover" | "schedule" | "preview";

export interface CreateEventDraft {
  step: CreateEventStep;
  selectedType: EventType;
  title: string;
  date: string;
  location: string;
  description: string;
  dressCode: string;
  notice: string;
  coverImage: string | null;
  scheduleItems: EditableScheduleItem[];
}
