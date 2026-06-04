"use client";

import Link from "next/link";
import { useMemo } from "react";
import { EventCoverHero } from "@/components/ui/EventCoverImage";
import {
  EVENT_TYPE_LABEL,
  RSVP_STATUS_LABEL,
  RSVP_STATUS_STYLE,
} from "@/lib/constants/event";
import {
  useCreatedEvents,
  useEventDetail,
  useInteractionStore,
} from "@/lib/stores/app-store";
import { formatDDay, formatEventDate } from "@/lib/utils/date";
import { ScheduleList } from "@/components/ui/ScheduleList";
import { SectionHeader } from "@/components/ui/SectionHeader";
import { GuestbookEntryCard } from "@/components/event/GuestbookEntryCard";
import { MOCK_USER } from "@/lib/mock/events";

export function EventDetailPage({ eventId }: { eventId: string }) {
  const detail = useEventDetail(eventId);
  const { isOwned } = useCreatedEvents();
  const interaction = useInteractionStore();

  const owned = isOwned(eventId);

  const resolved = useMemo(() => {
    if (!detail) return null;
    const summary = {
      ...detail.summary,
      rsvpStatus: interaction.rsvpStatus(
        eventId,
        detail.summary.rsvpStatus
      ),
    };
    const guestbook = interaction.guestbookEntries(eventId, detail.guestbook);
    const photos = interaction.photoURLs(eventId, detail.photoURLs, owned);
    return { ...detail, summary, guestbook, photos };
  }, [detail, eventId, interaction, owned]);

  if (!resolved) {
    return (
      <div className="flex min-h-[50dvh] items-center justify-center text-ink-muted">
        이벤트를 찾을 수 없습니다
      </div>
    );
  }

  const { summary } = resolved;
  const rsvpStyle = RSVP_STATUS_STYLE[summary.rsvpStatus];
  const dDay = formatDDay(summary.date);
  const showDDay = summary.isUpcoming && dDay !== "종료";
  const pendingHighlight = !owned && summary.rsvpStatus === "pending";

  return (
    <div className="relative pb-36">
      <div className="relative -mx-5">
        <EventCoverHero
          src={summary.coverImage}
          priority
          className="h-[min(52vw,300px)] min-h-[200px] w-full"
        />
        <div className="pointer-events-none absolute inset-0 bg-gradient-to-t from-black/70 via-black/20 to-transparent" />
        <div className="absolute left-5 top-12">
          <Link href="/" className="rounded-full bg-white/90 px-3 py-1.5 text-sm font-medium text-primary-deep">
            ←
          </Link>
        </div>
        {owned ? (
          <Link
            href={`/events/${eventId}/edit`}
            className="absolute right-5 top-12 rounded-full bg-white/90 px-3 py-1.5 text-sm font-medium text-primary-deep"
          >
            수정
          </Link>
        ) : null}
        <div className="absolute bottom-5 left-5 right-5 text-white">
          {showDDay ? (
            <span className="mb-2 inline-block rounded-full bg-white/20 px-2.5 py-0.5 text-xs backdrop-blur-sm">
              {dDay}
            </span>
          ) : null}
          <p className="text-xs text-white/80">{EVENT_TYPE_LABEL[summary.type]}</p>
          <h1 className="font-serif text-2xl font-medium">{summary.title}</h1>
        </div>
      </div>

      <div className="space-y-8 pt-6">
        <div className="rounded-2xl border border-blush bg-surface p-4 space-y-3">
          <div className="flex items-center justify-between">
            <span className={`rounded-md px-2 py-0.5 text-xs font-medium ${rsvpStyle.bg} ${rsvpStyle.text}`}>
              {RSVP_STATUS_LABEL[summary.rsvpStatus]}
            </span>
            <span className="text-xs text-ink-muted">
              {owned ? "내가 주최" : `${summary.hostName}님의 초대`}
            </span>
          </div>
          <p className="text-sm leading-relaxed text-ink">{resolved.description}</p>
          <InfoRow label="일시" value={formatEventDate(summary.date)} />
          <InfoRow label="장소" value={summary.location} />
          {resolved.dressCode ? <InfoRow label="드레스코드" value={resolved.dressCode} /> : null}
          {resolved.notice ? <InfoRow label="안내" value={resolved.notice} /> : null}
        </div>

        <div className="space-y-3">
          {owned ? (
            <>
              <ActionLink href={`/events/${eventId}/guestbook`} title="방명록 관리" subtitle="메시지 확인·관리" />
              <div className="grid grid-cols-2 gap-2.5">
                <ActionLink href={`/events/${eventId}/album`} title="공유앨범 관리" subtitle="사진 관리" small />
                <ActionLink href={`/events/${eventId}/ledger`} title="장부" subtitle="축하금" small />
              </div>
            </>
          ) : (
            <>
              <Link
                href={`/events/${eventId}/rsvp`}
                className={`block rounded-xl border p-4 ${
                  pendingHighlight
                    ? "border-red-300 bg-gradient-to-r from-red-50 to-primary/10"
                    : "border-blush bg-surface"
                }`}
              >
                <p className="text-sm font-semibold text-ink">RSVP</p>
                <p className="text-xs text-ink-muted">참여 여부를 알려주세요</p>
              </Link>
              <div className="grid grid-cols-2 gap-2.5">
                <ActionLink href={`/events/${eventId}/guestbook`} title="방명록" subtitle="축하 메시지" small />
                <ActionLink href={`/events/${eventId}/album`} title="공유 앨범" subtitle="사진 보기" small />
              </div>
            </>
          )}
        </div>

        {resolved.schedule.length > 0 ? (
          <ScheduleList items={resolved.schedule} />
        ) : null}

        {resolved.guestbook.length > 0 ? (
          <section className="space-y-3">
            <div className="flex items-end justify-between">
              <SectionHeader title="방명록" />
              <Link href={`/events/${eventId}/guestbook`} className="text-xs text-primary-deep">
                전체 보기
              </Link>
            </div>
            {resolved.guestbook.slice(0, 3).map((entry) => (
              <GuestbookEntryCard
                key={entry.id}
                entry={entry}
                viewerName={MOCK_USER.name}
                isOwner={owned}
                compact
              />
            ))}
          </section>
        ) : null}

        {resolved.photos.length > 0 ? (
          <section className="space-y-3">
            <div className="flex items-end justify-between">
              <SectionHeader title="공유 앨범" />
              <Link href={`/events/${eventId}/album`} className="text-xs text-primary-deep">
                전체 보기
              </Link>
            </div>
            <div className="grid grid-cols-3 gap-1.5">
              {resolved.photos.slice(0, 6).map((url) => (
                <div key={url} className="relative aspect-square overflow-hidden rounded-lg bg-cream-dark">
                  {/* eslint-disable-next-line @next/next/no-img-element */}
                  <img src={url} alt="" className="h-full w-full object-cover" />
                </div>
              ))}
            </div>
          </section>
        ) : null}
      </div>

      <div className="fixed bottom-16 left-0 right-0 z-40 border-t border-blush/60 bg-cream">
        <div className="mx-auto flex max-w-lg gap-2.5 px-5 py-2">
          {owned ? (
            <>
              <CtaLink href={`/events/${eventId}/ledger`} label="장부 확인하기" primary />
              <CtaLink href={`/events/${eventId}/participants`} label="참여자 관리하기" />
            </>
          ) : (
            <>
              <CtaLink href={`/events/${eventId}/rsvp`} label="참여여부 회신" primary />
              <CtaLink href={`/events/${eventId}/gift`} label="축하하기" />
            </>
          )}
        </div>
      </div>
    </div>
  );
}

function InfoRow({ label, value }: { label: string; value: string }) {
  return (
    <div>
      <p className="text-xs text-ink-muted">{label}</p>
      <p className="text-sm text-ink">{value}</p>
    </div>
  );
}

function ActionLink({
  href,
  title,
  subtitle,
  small,
}: {
  href: string;
  title: string;
  subtitle: string;
  small?: boolean;
}) {
  return (
    <Link
      href={href}
      className={`block rounded-xl border border-blush bg-surface ${small ? "p-3" : "p-4"}`}
    >
      <p className="text-sm font-semibold text-ink">{title}</p>
      <p className="text-xs text-ink-muted">{subtitle}</p>
    </Link>
  );
}

function CtaLink({
  href,
  label,
  primary,
}: {
  href: string;
  label: string;
  primary?: boolean;
}) {
  return (
    <Link
      href={href}
      className={`flex-1 rounded-xl py-3 text-center text-sm font-semibold ${
        primary
          ? "bg-primary-deep text-white"
          : "border border-blush bg-cream-dark text-primary-deep"
      }`}
    >
      {label}
    </Link>
  );
}
