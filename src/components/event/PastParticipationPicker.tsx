"use client";

import { PAST_PARTICIPATION_LABEL } from "@/lib/constants/event";
import { useInteractionStore } from "@/lib/stores/app-store";
import type { RSVPStatus } from "@/lib/types";

export function PastParticipationPicker({
  eventId,
  defaultStatus,
}: {
  eventId: string;
  defaultStatus: RSVPStatus;
}) {
  const interaction = useInteractionStore();
  const status = interaction.rsvpStatus(eventId, defaultStatus);
  const attended = status === "yes";
  const declined = status === "no";

  const select = (participated: boolean) => {
    interaction.savePastParticipation(eventId, participated);
  };

  return (
    <div className="rounded-xl border border-blush bg-surface p-4">
      <p className="text-sm font-semibold text-ink">나는 이 이벤트에</p>
      <div className="mt-3 grid grid-cols-2 gap-2">
        <button
          type="button"
          onClick={() => select(true)}
          className={`rounded-xl py-3 text-sm font-semibold transition ${
            attended
              ? "bg-primary-deep text-white"
              : "border border-blush bg-cream-dark text-ink"
          }`}
        >
          {PAST_PARTICIPATION_LABEL.yes}
        </button>
        <button
          type="button"
          onClick={() => select(false)}
          className={`rounded-xl py-3 text-sm font-semibold transition ${
            declined
              ? "bg-primary-deep text-white"
              : "border border-blush bg-cream-dark text-ink"
          }`}
        >
          {PAST_PARTICIPATION_LABEL.no}
        </button>
      </div>
    </div>
  );
}
