export function SectionHeader({
  title,
  trailing,
}: {
  title: string;
  trailing?: string;
}) {
  return (
    <div className="flex items-end justify-between">
      <h2 className="text-xs font-semibold uppercase tracking-widest text-primary-deep">
        {title}
      </h2>
      {trailing ? (
        <span className="text-xs text-ink-muted">{trailing}</span>
      ) : null}
    </div>
  );
}
