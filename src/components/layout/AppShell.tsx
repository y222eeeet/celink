import { BottomNav } from "@/components/layout/BottomNav";

export function AppShell({ children }: { children: React.ReactNode }) {
  return (
    <div className="mx-auto min-h-dvh max-w-lg overflow-x-hidden bg-cream">
      <main className="min-w-0 px-5 pb-24">{children}</main>
      <BottomNav />
    </div>
  );
}
