import { formatTime } from "@/lib/utils/date";
import { SectionHeader } from "@/components/ui/SectionHeader";

export interface ScheduleListItem {
  id: string;
  time: string;
  title: string;
  note?: string | null;
}

interface ScheduleListProps {
  items: ScheduleListItem[];
  title?: string;
  showHeader?: boolean;
}

export function ScheduleTimeBadge({ time }: { time: string }) {
  return (
    <span className="inline-flex h-8 min-w-14 shrink-0 items-center justify-center rounded-lg bg-primary/15 px-2.5 text-xs font-semibold tabular-nums leading-none whitespace-nowrap text-primary-deep">
      {formatTime(time)}
    </span>
  );
}

export function ScheduleItemRow({
  time,
  title,
  note,
}: Pick<ScheduleListItem, "time" | "title" | "note">) {
  const hasNote = Boolean(note?.trim());

  return (
    <div
      className={`flex gap-3 rounded-xl border border-blush bg-surface p-3 ${
        hasNote ? "items-start" : "items-center"
      }`}
    >
      <ScheduleTimeBadge time={time} />
      <div className={`min-w-0 flex-1 ${hasNote ? "" : "flex items-center"}`}>
        <p className="text-sm font-medium leading-snug text-ink">{title}</p>
        {hasNote ? (
          <p className="mt-0.5 text-xs leading-relaxed text-ink-muted">{note}</p>
        ) : null}
      </div>
    </div>
  );
}

export function ScheduleList({
  items,
  title = "식순",
  showHeader = true,
}: ScheduleListProps) {
  if (items.length === 0) return null;

  return (
    <section className="space-y-3">
      {showHeader ? (
        <SectionHeader title={title} trailing={`${items.length}개`} />
      ) : null}
      <div className="space-y-2">
        {items.map((item) => (
          <ScheduleItemRow key={item.id} {...item} />
        ))}
      </div>
    </section>
  );
}
