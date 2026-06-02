export function PrimaryButton({
  title,
  disabled,
  onClick,
  type = "button",
}: {
  title: string;
  disabled?: boolean;
  onClick?: () => void;
  type?: "button" | "submit";
}) {
  return (
    <button
      type={type}
      disabled={disabled}
      onClick={onClick}
      className="w-full rounded-xl bg-primary-deep py-3.5 text-sm font-semibold text-white transition disabled:cursor-not-allowed disabled:opacity-40"
    >
      {title}
    </button>
  );
}
