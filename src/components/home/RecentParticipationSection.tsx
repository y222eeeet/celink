import { EventCard } from "@/components/home/EventCard";
import type { EventSummary } from "@/lib/types";

interface RecentParticipationSectionProps {
  events: EventSummary[];
}

export function RecentParticipationSection({
  events,
}: RecentParticipationSectionProps) {
  const recent = events
    .filter((e) => e.lastParticipatedAt !== null)
    .sort(
      (a, b) =>
        new Date(b.lastParticipatedAt!).getTime() -
        new Date(a.lastParticipatedAt!).getTime()
    )
    .slice(0, 3);

  if (recent.length === 0) return null;

  return (
    <section className="mt-10 px-5" aria-labelledby="recent-heading">
      <h2
        id="recent-heading"
        className="mb-4 text-xs font-semibold uppercase tracking-widest text-rose-deep"
      >
        최근 참여
      </h2>
      <ul className="space-y-2">
        {recent.map((event) => (
          <li key={event.id}>
            <EventCard event={event} variant="compact" />
          </li>
        ))}
      </ul>
    </section>
  );
}
