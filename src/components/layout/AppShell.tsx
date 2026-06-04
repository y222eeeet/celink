import { BottomNav } from "@/components/layout/BottomNav";
import { TopBar } from "@/components/layout/TopBar";

export function AppShell({ children }: { children: React.ReactNode }) {
  return (
    <div className="mx-auto min-h-dvh max-w-lg overflow-x-hidden bg-cream">
      <TopBar />
      <main className="min-w-0 px-5 pb-24">{children}</main>
      <BottomNav />
    </div>
  );
}
