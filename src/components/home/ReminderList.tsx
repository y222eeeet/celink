import Link from "next/link";
import type { Reminder } from "@/lib/types";

interface ReminderListProps {
  reminders: Reminder[];
}

export function ReminderList({ reminders }: ReminderListProps) {
  if (reminders.length === 0) return null;

  return (
    <section className="px-5" aria-labelledby="reminders-heading">
      <h2
        id="reminders-heading"
        className="mb-3 text-xs font-semibold uppercase tracking-widest text-rose-deep"
      >
        리마인더
      </h2>
      <ul className="space-y-2">
        {reminders.map((item) => (
          <li key={item.id}>
            <Link
              href={`/events/${item.eventId}`}
              className="flex items-start gap-3 rounded-xl border border-amber-200/80 bg-amber-50/50 px-4 py-3 transition hover:bg-amber-50"
            >
              <span
                className="mt-0.5 flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-amber-100 text-amber-700"
                aria-hidden
              >
                <svg
                  className="h-4 w-4"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                  strokeWidth={2}
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    d="M12 6v6h4.5m4.5 0a9 9 0 11-18 0 9 9 0 0118 0z"
                  />
                </svg>
              </span>
              <div className="min-w-0">
                <p className="text-sm font-medium text-ink">
                  {item.eventTitle}
                </p>
                <p className="mt-0.5 text-xs leading-relaxed text-ink-muted">
                  {item.message}
                </p>
              </div>
            </Link>
          </li>
        ))}
      </ul>
    </section>
  );
}
