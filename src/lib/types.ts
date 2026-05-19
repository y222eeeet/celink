export type EventType = "wedding" | "exhibition" | "performance" | "dol";

export type RSVPStatus = "pending" | "yes" | "no" | "maybe";

export interface EventSummary {
  id: string;
  type: EventType;
  title: string;
  date: string;
  location: string;
  coverImage: string;
  hostName: string;
  rsvpStatus: RSVPStatus;
  /** 초대받은 시각 ISO */
  invitedAt: string;
  /** 마지막 참여(방명록·사진 등) 시각 ISO, 없으면 null */
  lastParticipatedAt: string | null;
  /** 다가오는 이벤트 D-day용 */
  isUpcoming: boolean;
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
  dueDate: string;
}
