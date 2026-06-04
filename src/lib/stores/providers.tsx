"use client";

import { AppStoreProvider } from "@/lib/stores/app-store";
import { NavigationGuardProvider } from "@/lib/stores/navigation-guard";

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <AppStoreProvider>
      <NavigationGuardProvider>{children}</NavigationGuardProvider>
    </AppStoreProvider>
  );
}
