import {
  BIRTHDAY_COVER_IMAGE,
  DOL_COVER_IMAGE,
  EXHIBITION_COVER_IMAGE,
  PERFORMANCE_COVER_IMAGE,
} from "@/lib/constants/event";
import type {
  EventDetail,
  EventSummary,
  RecentPhoto,
  Reminder,
} from "@/lib/types";

export const MOCK_USER = { name: "서지우" };

export const MOCK_EVENT_DETAILS: EventDetail[] = [
  {
    summary: {
      id: "evt-1",
      type: "wedding",
      title: "민수 ♥ 지연 결혼식",
      date: "2026-06-14T10:30:00",
      location: "서울 신라호텔",
      coverImage:
        "https://images.unsplash.com/photo-1519741497674-611481863552?w=800&q=80",
      hostName: "김민수",
      rsvpStatus: "yes",
      lastParticipatedAt: "2026-05-10T14:30:00",
      isUpcoming: true,
    },
    description:
      "두 사람의 새로운 시작을 함께 축복해 주세요. 따뜻한 마음으로 참석해 주시면 감사하겠습니다.",
    dressCode: "포멀 · 남색·베이지 계열 권장",
    notice: "화환은 정중히 사양합니다. 식사 RSVP에 동반 인원을 꼭 적어 주세요.",
    schedule: [
      { id: "s1-1", time: "2026-06-14T10:30:00", title: "하객 입장" },
      { id: "s1-2", time: "2026-06-14T11:00:00", title: "본식 시작" },
      { id: "s1-3", time: "2026-06-14T11:10:00", title: "신랑 입장" },
      { id: "s1-4", time: "2026-06-14T11:20:00", title: "신부 입장" },
      { id: "s1-5", time: "2026-06-14T11:30:00", title: "신랑신부 행진" },
      { id: "s1-6", time: "2026-06-14T11:40:00", title: "하객사진 촬영" },
    ],
    guestbook: [
      {
        id: "g1-1",
        authorName: "박지훈",
        content: "결혼 진심으로 축하해! 행복만 가득하길.",
        isPrivate: false,
        createdAt: "2026-05-10T14:30:00",
      },
      {
        id: "g1-2",
        authorName: "이수민",
        content: "두 분 앞날에 항상 웃음이 가득하길 바라요.",
        isPrivate: false,
        createdAt: "2026-05-09T11:00:00",
      },
      {
        id: "g1-3",
        authorName: "익명",
        content: "멀리서 응원합니다. 꼭 참석할게요!",
        isPrivate: true,
        createdAt: "2026-05-08T20:00:00",
      },
    ],
    photoURLs: [
      "https://images.unsplash.com/photo-1465495976277-812eacf5aee6?w=400&q=80",
      "https://images.unsplash.com/photo-1519741497674-611481863552?w=400&q=80",
      "https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=400&q=80",
    ],
  },
  {
    summary: {
      id: "evt-2",
      type: "exhibition",
      title: "졸업 전시 — 빛의 결",
      date: "2026-05-25T12:00:00",
      location: "홍익대학교 현대미술관",
      coverImage: EXHIBITION_COVER_IMAGE,
      hostName: "이하은",
      rsvpStatus: "maybe",
      lastParticipatedAt: "2026-05-12T18:00:00",
      isUpcoming: true,
    },
    description:
      "4년간의 작업을 모은 졸업 전시입니다. 빛과 그림자의 경계를 탐구한 설치·회화 작품을 만나보세요.",
    notice: "전시장 내 플래시 촬영은 삼가 주세요.",
    schedule: [
      {
        id: "s2-1",
        time: "2026-05-25T12:10:00",
        title: "오프닝 이벤트",
        note: "1층 로비",
      },
      {
        id: "s2-2",
        time: "2026-05-25T12:20:00",
        title: "작가 토크",
        note: "세미나실",
      },
      {
        id: "s2-3",
        time: "2026-05-25T13:00:00",
        title: "자유 관람",
        note: "2층 전시실",
      },
    ],
    guestbook: [
      {
        id: "g2-1",
        authorName: "교수님",
        content: "졸업 축하한다. 전시 너무 기대돼.",
        isPrivate: false,
        createdAt: "2026-05-12T18:00:00",
      },
      {
        id: "g2-2",
        authorName: "동기 민지",
        content: "오프닝날 꼭 갈게! 고생 많았어.",
        isPrivate: false,
        createdAt: "2026-05-11T09:30:00",
      },
    ],
    photoURLs: [
      "https://images.unsplash.com/photo-1578301978693-85fa9c0320f9?w=400&q=80",
      "https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=400&q=80",
    ],
  },
  {
    summary: {
      id: "evt-3",
      type: "dol",
      title: "도윤이 첫 번째 생일",
      date: "2026-03-08T11:30:00",
      location: "판교 파티룸",
      coverImage: DOL_COVER_IMAGE,
      hostName: "박서연",
      rsvpStatus: "yes",
      lastParticipatedAt: "2026-03-08T16:45:00",
      isUpcoming: false,
    },
    description: "우리 도윤이 첫 돌을 가족과 지인분들과 함께 나누고 싶습니다.",
    dressCode: "캐주얼",
    schedule: [
      { id: "s3-1", time: "2026-03-08T11:30:00", title: "입장 · 포토존" },
      { id: "s3-2", time: "2026-03-08T12:00:00", title: "돌잡이" },
      { id: "s3-3", time: "2026-03-08T12:20:00", title: "케이크 커팅" },
    ],
    guestbook: [
      {
        id: "g3-1",
        authorName: "이모",
        content: "도윤아 생일 축하해! 건강하게 자라렴.",
        isPrivate: false,
        createdAt: "2026-03-08T16:45:00",
      },
    ],
    photoURLs: [
      "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80",
    ],
  },
  {
    summary: {
      id: "evt-4",
      type: "performance",
      title: "봄밤 재즈 콘서트",
      date: "2026-07-20T20:00:00",
      location: "블루스퀘어",
      coverImage: PERFORMANCE_COVER_IMAGE,
      hostName: "최예린",
      rsvpStatus: "pending",
      lastParticipatedAt: null,
      isUpcoming: true,
    },
    description:
      "여름밤 재즈 라이브에 초대합니다. 밴드 'Moonlight Quartet'의 특별 공연입니다.",
    dressCode: "스마트 캐주얼",
    notice: "공연 시작 30분 전 착석을 권장합니다.",
    schedule: [
      { id: "s4-1", time: "2026-07-20T19:40:00", title: "입장 시작" },
      { id: "s4-2", time: "2026-07-20T20:00:00", title: "공연 1부 시작" },
      { id: "s4-3", time: "2026-07-20T20:40:00", title: "공연 2부 시작" },
    ],
    guestbook: [],
    photoURLs: [],
  },
];

export const MOCK_INVITED_EVENTS: EventSummary[] = MOCK_EVENT_DETAILS.map(
  (d) => d.summary
);

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
  },
  {
    id: "rem-2",
    eventId: "evt-4",
    eventTitle: "봄밤 재즈 콘서트",
    message: "참석 여부를 알려주세요",
  },
];

export const SEED_OWNED_EVENT: EventDetail = {
  summary: {
    id: "owned-birthday-1",
    type: "dol",
    title: "지우의 생일파티",
    date: "2026-08-16T19:00:00",
    location: "성수 루프탑 라운지",
    coverImage: BIRTHDAY_COVER_IMAGE,
    hostName: MOCK_USER.name,
    rsvpStatus: "yes",
    lastParticipatedAt: null,
    isUpcoming: true,
  },
  description:
    "소중한 사람들과 저녁 생일파티를 함께하고 싶어요. 편하게 와서 즐겨주세요!",
  dressCode: "캐주얼",
  notice: "주차는 건물 지하 유료주차장을 이용해 주세요.",
  schedule: [
    { id: "ob-1", time: "2026-08-16T19:00:00", title: "웰컴 & 인사" },
    { id: "ob-2", time: "2026-08-16T19:30:00", title: "케이크 커팅" },
    { id: "ob-3", time: "2026-08-16T19:50:00", title: "단체사진 촬영" },
  ],
  guestbook: [],
  photoURLs: [],
};

export function getMockEventDetail(id: string): EventDetail | undefined {
  return MOCK_EVENT_DETAILS.find((e) => e.summary.id === id);
}
