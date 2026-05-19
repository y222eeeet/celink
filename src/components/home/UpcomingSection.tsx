import { EventCard } from "@/components/home/EventCard";
import type { EventSummary } from "@/lib/types";

interface UpcomingSectionProps {
  events: EventSummary[];
}

export function UpcomingSection({ events }: UpcomingSectionProps) {
  const upcoming = events
    .filter((e) => e.isUpcoming)
    .sort(
      (a, b) => new Date(a.date).getTime() - new Date(b.date).getTime()
    );

  if (upcoming.length === 0) return null;

  const [featured, ...rest] = upcoming;

  return (
    <section className="px-5" aria-labelledby="upcoming-heading">
      <h2
        id="upcoming-heading"
        className="mb-4 text-xs font-semibold uppercase tracking-widest text-rose-deep"
      >
        다가오는 이벤트
      </h2>
      <EventCard event={featured} variant="featured" />
      {rest.length > 0 && (
        <ul className="mt-3 space-y-2">
          {rest.slice(0, 2).map((event) => (
            <li key={event.id}>
              <EventCard event={event} variant="compact" />
            </li>
          ))}
        </ul>
      )}
    </section>
  );
}
