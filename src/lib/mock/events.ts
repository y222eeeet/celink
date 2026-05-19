import type { EventSummary, RecentPhoto, Reminder } from "@/lib/types";

export const MOCK_USER = {
  name: "서지우",
};

export const MOCK_INVITED_EVENTS: EventSummary[] = [
  {
    id: "evt-1",
    type: "wedding",
    title: "민수 ♥ 지연 결혼식",
    date: "2026-06-14T11:00:00",
    location: "서울 신라호텔",
    coverImage:
      "https://images.unsplash.com/photo-1519741497674-611481863552?w=800&q=80",
    hostName: "김민수",
    rsvpStatus: "yes",
    invitedAt: "2026-04-01T10:00:00",
    lastParticipatedAt: "2026-05-10T14:30:00",
    isUpcoming: true,
  },
  {
    id: "evt-2",
    type: "exhibition",
    title: "졸업 전시 — 빛의 결",
    date: "2026-05-25T14:00:00",
    location: "홍익대학교 현대미술관",
    coverImage:
      "https://images.unsplash.com/photo-1460661414737-f969d6ae3b70?w=800&q=80",
    hostName: "이하은",
    rsvpStatus: "maybe",
    invitedAt: "2026-05-01T09:00:00",
    lastParticipatedAt: "2026-05-12T18:00:00",
    isUpcoming: true,
  },
  {
    id: "evt-3",
    type: "dol",
    title: "도윤이 첫 번째 생일",
    date: "2026-03-08T12:00:00",
    location: "판교 파티룸",
    coverImage:
      "https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=800&q=80",
    hostName: "박서연",
    rsvpStatus: "yes",
    invitedAt: "2026-02-15T11:00:00",
    lastParticipatedAt: "2026-03-08T16:45:00",
    isUpcoming: false,
  },
  {
    id: "evt-4",
    type: "performance",
    title: "봄밤 재즈 콘서트",
    date: "2026-07-20T19:30:00",
    location: "블루스퀘어",
    coverImage:
      "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&q=80",
    hostName: "최예린",
    rsvpStatus: "pending",
    invitedAt: "2026-05-15T08:00:00",
    lastParticipatedAt: null,
    isUpcoming: true,
  },
];

export const MOCK_RECENT_PHOTOS: RecentPhoto[] = [
  {
    id: "ph-1",
    eventId: "evt-2",
    eventTitle: "졸업 전시 — 빛의 결",
    imageUrl:
      "https://images.unsplash.com/photo-1578301978693-85fa9c0320f9?w=400&q=80",
    uploadedAt: "2026-05-12T17:55:00",
  },
  {
    id: "ph-2",
    eventId: "evt-1",
    eventTitle: "민수 ♥ 지연 결혼식",
    imageUrl:
      "https://images.unsplash.com/photo-1465495976277-812eacf5aee6?w=400&q=80",
    uploadedAt: "2026-05-10T14:20:00",
  },
  {
    id: "ph-3",
    eventId: "evt-2",
    eventTitle: "졸업 전시 — 빛의 결",
    imageUrl:
      "https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=400&q=80",
    uploadedAt: "2026-05-12T16:10:00",
  },
  {
    id: "ph-4",
    eventId: "evt-3",
    eventTitle: "도윤이 첫 번째 생일",
    imageUrl:
      "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80",
    uploadedAt: "2026-03-08T15:30:00",
  },
];

export const MOCK_REMINDERS: Reminder[] = [
  {
    id: "rem-1",
    eventId: "evt-2",
    eventTitle: "졸업 전시 — 빛의 결",
    message: "전시 오픈 D-3 · RSVP를 아직 확정하지 않았어요",
    dueDate: "2026-05-22T09:00:00",
  },
  {
    id: "rem-2",
    eventId: "evt-4",
    eventTitle: "봄밤 재즈 콘서트",
    message: "참석 여부를 알려주세요",
    dueDate: "2026-05-25T09:00:00",
  },
];
