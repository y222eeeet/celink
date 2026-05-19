import { EventCard } from "@/components/home/EventCard";
import type { EventSummary } from "@/lib/types";

interface InvitedEventsSectionProps {
  events: EventSummary[];
}

export function InvitedEventsSection({ events }: InvitedEventsSectionProps) {
  return (
    <section className="mt-10 px-5" aria-labelledby="invited-heading">
      <div className="mb-4 flex items-end justify-between">
        <h2
          id="invited-heading"
          className="text-xs font-semibold uppercase tracking-widest text-rose-deep"
        >
          초대받은 이벤트
        </h2>
        <span className="text-xs text-ink-muted">{events.length}개</span>
      </div>
      <ul className="space-y-3">
        {events.map((event) => (
          <li key={event.id}>
            <EventCard event={event} />
          </li>
        ))}
      </ul>
    </section>
  );
}
