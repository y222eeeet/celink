"use client";

import Link from "next/link";
import { EventCard } from "@/components/home/EventCard";
import { SectionHeader } from "@/components/ui/SectionHeader";
import { MOCK_INVITED_EVENTS } from "@/lib/mock/events";
import { useCreatedEvents, useInteractionStore } from "@/lib/stores/app-store";
import { formatAmount } from "@/lib/utils/currency";
import type { EventSummary } from "@/lib/types";
import { MOCK_USER } from "@/lib/mock/events";

export function ProfileContent() {
  const { ownedSummaries, isOwned } = useCreatedEvents();
  const interaction = useInteractionStore();

  const resolveRSVP = (event: EventSummary): EventSummary => ({
    ...event,
    rsvpStatus: interaction.rsvpStatus(event.id, event.rsvpStatus),
  });

  const joinedEvents = MOCK_INVITED_EVENTS.filter(
    (e) => !isOwned(e.id)
  ).map(resolveRSVP);

  const ledgerAmount = interaction.currentLedgerAmount();

  return (
    <div className="px-5 pb-6">
      <header className="pb-6 pt-2">
        <h1 className="font-serif text-3xl font-medium text-ink">프로필</h1>
        <p className="mt-1 text-sm text-ink-muted">{MOCK_USER.name}님의 이벤트</p>
      </header>

      <div className="rounded-[20px] border border-primary/35 bg-gradient-to-br from-surface to-cream-dark/90 p-3.5">
        <div className="rounded-2xl border border-blush bg-surface px-[18px] py-5">
          <p className="text-sm text-ink-muted">장부 금액</p>
          <p className="mt-2 text-[38px] font-semibold leading-none text-primary-deep">
            {formatAmount(ledgerAmount)}
          </p>
        </div>
        <div className="mt-4 flex gap-2.5 px-1 pb-1">
          <Link
            href="/profile/ledger"
            className="flex-1 rounded-xl bg-primary-deep py-3.5 text-center text-sm font-semibold text-white"
          >
            장부 열기
          </Link>
          <Link
            href="/profile/withdraw"
            className="flex-1 rounded-xl border border-blush bg-cream-dark py-3.5 text-center text-sm font-semibold text-primary-deep"
          >
            출금하기
          </Link>
        </div>
      </div>

      {ownedSummaries.length > 0 ? (
        <section className="mt-8 space-y-3">
          <SectionHeader
            title="내가 만든 이벤트"
            trailing={`${ownedSummaries.length}개`}
          />
          <div className="space-y-3">
            {ownedSummaries.map((event) => (
              <EventCard key={event.id} event={event} variant="default" />
            ))}
          </div>
        </section>
      ) : null}

      {joinedEvents.length > 0 ? (
        <section className="mt-8 space-y-3">
          <SectionHeader
            title="내가 참여한 이벤트"
            trailing={`${joinedEvents.length}개`}
          />
          <div className="space-y-3">
            {joinedEvents.map((event) => (
              <EventCard key={event.id} event={event} variant="default" />
            ))}
          </div>
        </section>
      ) : null}
    </div>
  );
}
