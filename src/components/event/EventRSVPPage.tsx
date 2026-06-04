"use client";

import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { EventSubpageHeader } from "@/components/ui/EventSubpageHeader";
import { PrimaryButton } from "@/components/ui/PrimaryButton";
import { BackLink } from "@/components/ui/BackLink";
import {
  RSVP_STATUS_LABEL,
  RSVP_STATUS_SUBTITLE,
} from "@/lib/constants/event";
import { useEventDetail, useInteractionStore } from "@/lib/stores/app-store";
import type { RSVPStatus } from "@/lib/types";
import { toLocalISOString, toFiveMinuteInterval } from "@/lib/utils/date-rounding";
import { formatTime } from "@/lib/utils/date";

const OPTIONS: RSVPStatus[] = ["yes", "no", "maybe", "pending"];

export function EventRSVPPage({ eventId }: { eventId: string }) {
  const router = useRouter();
  const detail = useEventDetail(eventId);
  const interaction = useInteractionStore();
  const [selected, setSelected] = useState<RSVPStatus>("pending");
  const [lateArrival, setLateArrival] = useState("");
  const [saved, setSaved] = useState(false);

  useEffect(() => {
    if (!detail) return;
    if (!detail.summary.isUpcoming) {
      router.replace(`/events/${eventId}`);
      return;
    }
    const status = interaction.rsvpStatus(eventId, detail.summary.rsvpStatus);
    setSelected(status);
    const existing = interaction.lateArrivalTime(eventId);
    setLateArrival(existing ?? detail.summary.date);
  }, [detail, eventId, interaction, router]);

  if (!detail) return <p className="py-5 text-ink-muted">이벤트를 찾을 수 없습니다</p>;

  if (!detail.summary.isUpcoming) {
    return (
      <p className="py-5 text-ink-muted">지난 이벤트는 상세 페이지에서 참여 여부를 선택해 주세요</p>
    );
  }

  const minTime = detail.summary.date;

  const save = () => {
    interaction.saveRSVP(
      eventId,
      selected,
      selected === "maybe" ? lateArrival : null
    );
    setSaved(true);
    setTimeout(() => router.back(), 1200);
  };

  return (
    <div className="space-y-6 pb-8 pt-4">
      <BackLink href={`/events/${eventId}`} />
      <EventSubpageHeader
        title="RSVP"
        eventTitle={detail.summary.title}
        subtitle="참여 여부를 선택해 주세요"
      />

      <div className="space-y-2.5">
        {OPTIONS.map((status) => (
          <button
            key={status}
            type="button"
            onClick={() => setSelected(status)}
            className={`w-full rounded-xl border p-4 text-left ${
              selected === status
                ? "border-primary bg-primary/10"
                : "border-blush bg-surface"
            }`}
          >
            <p className="text-sm font-semibold text-ink">
              {RSVP_STATUS_LABEL[status]}
            </p>
            <p className="text-xs text-ink-muted">
              {RSVP_STATUS_SUBTITLE[status]}
            </p>
          </button>
        ))}
      </div>

      {selected === "maybe" ? (
        <div className="space-y-2 rounded-xl border border-blush bg-surface p-4">
          <p className="text-sm font-semibold text-ink">몇 시에 참여 가능한가요?</p>
          <input
            type="datetime-local"
            value={lateArrival.slice(0, 16)}
            min={minTime.slice(0, 16)}
            onChange={(e) => {
              const d = toFiveMinuteInterval(new Date(e.target.value));
              const min = new Date(minTime);
              const clamped = d < min ? min : d;
              setLateArrival(toLocalISOString(clamped));
            }}
            className="w-full rounded-lg border border-blush px-3 py-2 text-sm"
          />
          <p className="text-xs text-ink-muted">
            선택: {formatTime(lateArrival)} (5분 단위)
          </p>
        </div>
      ) : null}

      {saved ? (
        <p className="text-center text-sm text-primary-deep">저장되었어요</p>
      ) : (
        <PrimaryButton title="저장하기" onClick={save} />
      )}
    </div>
  );
}
