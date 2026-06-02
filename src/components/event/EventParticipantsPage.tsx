"use client";

import { useMemo, useState } from "react";
import { EventSubpageHeader } from "@/components/ui/EventSubpageHeader";
import { BackLink } from "@/components/ui/BackLink";
import {
  RELATION_LABEL,
  RSVP_STATUS_LABEL,
  RSVP_STATUS_STYLE,
} from "@/lib/constants/event";
import { useEventDetail, useInteractionStore } from "@/lib/stores/app-store";
import type { RelationType, RSVPStatus } from "@/lib/types";

type RelationFilter = "all" | RelationType;

export function EventParticipantsPage({ eventId }: { eventId: string }) {
  const detail = useEventDetail(eventId);
  const interaction = useInteractionStore();
  const [relationFilter, setRelationFilter] = useState<RelationFilter>("all");
  const [rsvpFilter, setRsvpFilter] = useState<RSVPStatus | null>(null);

  const entries = detail ? interaction.participantEntries(eventId) : [];

  const filtered = useMemo(() => {
    return entries.filter((e) => {
      if (relationFilter !== "all" && e.relation !== relationFilter) return false;
      if (rsvpFilter && e.rsvpStatus !== rsvpFilter) return false;
      return true;
    });
  }, [entries, relationFilter, rsvpFilter]);

  const counts = useMemo(() => ({
    yes: entries.filter((e) => e.rsvpStatus === "yes").length,
    no: entries.filter((e) => e.rsvpStatus === "no").length,
    maybe: entries.filter((e) => e.rsvpStatus === "maybe").length,
    pending: entries.filter((e) => e.rsvpStatus === "pending").length,
  }), [entries]);

  if (!detail) return <p className="p-5 text-ink-muted">이벤트를 찾을 수 없습니다</p>;

  const relations: RelationFilter[] = [
    "all",
    "family",
    "bestFriend",
    "friend",
    "coworker",
    "acquaintance",
    "etc",
  ];

  return (
    <div className="space-y-6 px-5 pb-8 pt-4">
      <BackLink href={`/events/${eventId}`} />
      <EventSubpageHeader
        title="참여자 관리"
        eventTitle={detail.summary.title}
        subtitle="초대한 사람들의 RSVP 현황"
      />

      <div className="rounded-xl border border-blush bg-surface p-4 space-y-3">
        <p className="text-sm font-semibold text-ink">총 {entries.length}명</p>
        <div className="flex flex-wrap gap-2">
          {(["yes", "no", "maybe", "pending"] as RSVPStatus[]).map((status) => (
            <button
              key={status}
              type="button"
              onClick={() =>
                setRsvpFilter(rsvpFilter === status ? null : status)
              }
              className={`rounded-full px-3 py-1 text-xs font-semibold ${
                rsvpFilter === status
                  ? "bg-primary-deep text-white"
                  : "bg-cream-dark text-ink"
              }`}
            >
              {RSVP_STATUS_LABEL[status]} {counts[status]}
            </button>
          ))}
        </div>
        {rsvpFilter ? (
          <button
            type="button"
            onClick={() => setRsvpFilter(null)}
            className="text-xs text-primary-deep"
          >
            RSVP 필터 해제 ×
          </button>
        ) : null}
      </div>

      <div className="flex flex-wrap gap-2">
        {relations.map((rel) => (
          <button
            key={rel}
            type="button"
            onClick={() => setRelationFilter(rel)}
            className={`rounded-full px-3 py-1 text-xs font-semibold ${
              relationFilter === rel
                ? "bg-primary-deep text-white"
                : "border border-blush bg-surface text-ink"
            }`}
          >
            {rel === "all" ? "전체" : RELATION_LABEL[rel]}
          </button>
        ))}
      </div>

      <div className="space-y-2">
        {filtered.map((entry) => {
          const style = RSVP_STATUS_STYLE[entry.rsvpStatus];
          return (
            <div key={entry.id} className="flex items-center justify-between rounded-xl border border-blush bg-surface p-3">
              <div>
                <p className="text-sm font-medium text-ink">{entry.name}</p>
                <p className="text-xs text-ink-muted">{RELATION_LABEL[entry.relation]}</p>
              </div>
              <span className={`rounded-md px-2 py-0.5 text-xs font-medium ${style.bg} ${style.text}`}>
                {RSVP_STATUS_LABEL[entry.rsvpStatus]}
              </span>
            </div>
          );
        })}
      </div>
    </div>
  );
}
