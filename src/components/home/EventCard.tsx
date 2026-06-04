import Link from "next/link";
import {
  EventCoverCardSide,
  EventCoverFeatured,
} from "@/components/ui/EventCoverImage";
import {
  EVENT_TYPE_LABEL,
  RSVP_STATUS_LABEL,
  RSVP_STATUS_STYLE,
} from "@/lib/constants/event";
import type { EventSummary } from "@/lib/types";
import { formatDDay, formatEventDate } from "@/lib/utils/date";

interface EventCardProps {
  event: EventSummary;
  variant?: "default" | "featured";
}

export function EventCard({ event, variant = "default" }: EventCardProps) {
  const rsvpStyle = RSVP_STATUS_STYLE[event.rsvpStatus];
  const dDay = formatDDay(event.date);
  const showDDay = event.isUpcoming && dDay !== "종료";

  if (variant === "featured") {
    return (
      <Link
        href={`/events/${event.id}`}
        className="group relative block overflow-hidden rounded-2xl bg-stone-900 shadow-lg shadow-stone-900/10"
      >
        <EventCoverFeatured src={event.coverImage} alt={event.title} priority />
        <div className="absolute inset-0 bg-gradient-to-t from-stone-900/90 via-stone-900/30 to-transparent" />
        <div className="absolute inset-x-0 bottom-0 p-5 text-white">
          {showDDay && (
            <span className="mb-2 inline-block rounded-full bg-white/20 px-2.5 py-0.5 text-xs font-medium backdrop-blur-sm">
              {dDay}
            </span>
          )}
          <p className="text-xs text-white/70">
            {EVENT_TYPE_LABEL[event.type]}
          </p>
          <h3 className="mt-0.5 font-serif text-xl font-medium leading-snug">
            {event.title}
          </h3>
          <p className="mt-2 text-sm text-white/80">
            {formatEventDate(event.date)}
          </p>
          <p className="text-sm text-white/60">{event.location}</p>
        </div>
      </Link>
    );
  }

  return (
    <Link
      href={`/events/${event.id}`}
      className="flex items-stretch overflow-hidden rounded-2xl border border-blush/60 bg-white shadow-sm transition hover:shadow-md"
    >
      <div className="relative flex w-28 shrink-0 self-stretch">
        <EventCoverCardSide src={event.coverImage} sizes="112px" />
        {showDDay ? (
          <span className="absolute left-2 top-2 rounded-md bg-cream/95 px-1.5 py-0.5 text-[10px] font-semibold text-rose-deep backdrop-blur-sm">
            {dDay}
          </span>
        ) : null}
      </div>
      <div className="flex min-w-0 flex-1 flex-col justify-center px-4 py-3">
        <p className="text-[11px] font-medium uppercase tracking-wider text-rose">
          {EVENT_TYPE_LABEL[event.type]}
        </p>
        <h3 className="mt-0.5 truncate font-medium text-ink">{event.title}</h3>
        <p className="mt-1 text-xs text-ink-muted">
          {formatEventDate(event.date)} · {event.location}
        </p>
        <div className="mt-2 flex items-center gap-2">
          <span
            className={`rounded-md px-2 py-0.5 text-[10px] font-medium ${rsvpStyle.bg} ${rsvpStyle.text}`}
          >
            {RSVP_STATUS_LABEL[event.rsvpStatus]}
          </span>
          <span className="text-[10px] text-ink-muted">
            {event.hostName}님의 초대
          </span>
        </div>
      </div>
    </Link>
  );
}
