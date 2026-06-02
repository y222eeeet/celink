export function EventSubpageHeader({
  title,
  eventTitle,
  subtitle,
}: {
  title: string;
  eventTitle: string;
  subtitle: string;
}) {
  return (
    <div className="space-y-1">
      <p className="text-xs font-semibold uppercase tracking-widest text-primary">
        {title}
      </p>
      <h1 className="font-serif text-2xl text-ink">{eventTitle}</h1>
      <p className="text-sm text-ink-muted">{subtitle}</p>
    </div>
  );
}
