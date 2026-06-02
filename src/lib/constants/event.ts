import type { EventType, RelationType, RSVPStatus } from "@/lib/types";

/** 커버 이미지 (public/images/covers) */
export const BIRTHDAY_COVER_IMAGE = "/images/covers/birthday-party.png";
export const EXHIBITION_COVER_IMAGE = "/images/covers/exhibition-cover.png";
export const PERFORMANCE_COVER_IMAGE = "/images/covers/performance-cover.png";
export const DOL_COVER_IMAGE = "/images/covers/dol-cover.png";

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
  exhibition: EXHIBITION_COVER_IMAGE,
  performance: PERFORMANCE_COVER_IMAGE,
  dol: DOL_COVER_IMAGE,
};
