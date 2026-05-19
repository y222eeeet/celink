import type { EventType, RSVPStatus } from "@/lib/types";

export const EVENT_TYPE_LABEL: Record<EventType, string> = {
  wedding: "결혼식",
  exhibition: "전시",
  performance: "공연",
  dol: "돌잔치",
};

export const RSVP_STATUS_LABEL: Record<RSVPStatus, string> = {
  pending: "미응답",
  yes: "참석",
  no: "불참",
  maybe: "미정",
};

export const RSVP_STATUS_STYLE: Record<
  RSVPStatus,
  { bg: string; text: string }
> = {
  pending: { bg: "bg-stone-100", text: "text-stone-600" },
  yes: { bg: "bg-emerald-50", text: "text-emerald-700" },
  no: { bg: "bg-stone-100", text: "text-stone-500" },
  maybe: { bg: "bg-amber-50", text: "text-amber-700" },
};
