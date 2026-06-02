import type { EventType, RelationType, RSVPStatus } from "@/lib/types";

/** 지우의 생일파티 등 돌잔치/생일 기본 커버 (public/) */
export const BIRTHDAY_COVER_IMAGE = "/images/covers/birthday-party.png";

export const EVENT_TYPE_LABEL: Record<EventType, string> = {
  wedding: "결혼식",
  exhibition: "전시",
  performance: "공연",
  dol: "돌잔치",
};

export const RSVP_STATUS_LABEL: Record<RSVPStatus, string> = {
  pending: "미정",
  yes: "참여",
  no: "미참여",
  maybe: "늦게 참여",
};

export const RSVP_STATUS_SUBTITLE: Record<RSVPStatus, string> = {
  pending: "아직 결정하지 못했어요",
  yes: "참석할 예정이에요",
  no: "참석하지 않을 예정이에요",
  maybe: "이벤트 시작 이후에 참여해요",
};

export const RSVP_STATUS_STYLE: Record<
  RSVPStatus,
  { bg: string; text: string }
> = {
  pending: { bg: "bg-cream-dark", text: "text-ink-muted" },
  yes: { bg: "bg-primary/15", text: "text-primary-deep" },
  no: { bg: "bg-cream-dark", text: "text-ink-muted" },
  maybe: { bg: "bg-primary/15", text: "text-primary-deep" },
};

export const RELATION_LABEL: Record<RelationType, string> = {
  family: "가족",
  bestFriend: "절친",
  friend: "친구",
  coworker: "회사동료",
  acquaintance: "지인",
  etc: "기타",
};

export const DEFAULT_COVER_BY_TYPE: Record<EventType, string> = {
  wedding:
    "https://images.unsplash.com/photo-1519741497674-611481863552?w=800&q=80",
  exhibition:
    "https://images.unsplash.com/photo-1460661414737-f969d6ae3b70?w=800&q=80",
  performance:
    "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&q=80",
  dol: BIRTHDAY_COVER_IMAGE,
};
