"use client";

import { EventSubpageHeader } from "@/components/ui/EventSubpageHeader";
import { BackLink } from "@/components/ui/BackLink";
import { RELATION_LABEL } from "@/lib/constants/event";
import { useEventDetail, useInteractionStore } from "@/lib/stores/app-store";
import { formatAmount } from "@/lib/utils/currency";

export function EventLedgerPage({ eventId }: { eventId: string }) {
  const detail = useEventDetail(eventId);
  const interaction = useInteractionStore();

  if (!detail) return <p className="p-5 text-ink-muted">이벤트를 찾을 수 없습니다</p>;

  const entries = interaction.ledgerEntries(eventId);
  const total = entries.reduce((s, e) => s + e.amount, 0);

  return (
    <div className="space-y-6 px-5 pb-8 pt-4">
      <BackLink href={`/events/${eventId}`} />
      <EventSubpageHeader
        title="장부"
        eventTitle={detail.summary.title}
        subtitle="받은 축하금 내역"
      />

      <div className="rounded-xl border border-blush bg-surface p-4">
        <p className="text-xs text-ink-muted">총 수령액</p>
        <p className="text-2xl font-semibold text-primary-deep">{formatAmount(total)}</p>
      </div>

      <div className="space-y-2">
        {entries.length === 0 ? (
          <p className="text-sm text-ink-muted">아직 수령 내역이 없어요</p>
        ) : (
          entries.map((entry) => (
            <div key={entry.id} className="flex items-center justify-between rounded-xl border border-blush bg-surface p-3">
              <div>
                <p className="text-sm font-medium text-ink">{entry.senderName}</p>
                <p className="text-xs text-ink-muted">{RELATION_LABEL[entry.relation]}</p>
              </div>
              <p className="text-sm font-semibold text-primary-deep">
                {formatAmount(entry.amount)}
              </p>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
