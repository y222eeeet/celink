import { BottomNav } from "@/components/layout/BottomNav";

export function AppShell({ children }: { children: React.ReactNode }) {
  return (
    <div className="mx-auto min-h-dvh max-w-lg bg-cream">
      <main className="pb-24">{children}</main>
      <BottomNav />
    </div>
  );
}
