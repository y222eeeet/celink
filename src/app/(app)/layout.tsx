import { AppShell } from "@/components/layout/AppShell";
import { Providers } from "@/lib/stores/providers";

export default function AppLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <Providers>
      <AppShell>{children}</AppShell>
    </Providers>
  );
}
