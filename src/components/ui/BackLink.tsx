import Link from "next/link";

export function BackLink({ href, label = "← 돌아가기" }: { href: string; label?: string }) {
  return (
    <Link href={href} className="text-sm font-medium text-primary-deep">
      {label}
    </Link>
  );
}
