"use client";

import { AppStoreProvider } from "@/lib/stores/app-store";

export function Providers({ children }: { children: React.ReactNode }) {
  return <AppStoreProvider>{children}</AppStoreProvider>;
}
