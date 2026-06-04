"use client";

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from "react";

interface NavigationGuardContextValue {
  isDirty: boolean;
  setDirty: (key: string, dirty: boolean) => void;
}

const NavigationGuardContext = createContext<NavigationGuardContextValue | null>(
  null
);

export function NavigationGuardProvider({ children }: { children: ReactNode }) {
  const [dirtyKeys, setDirtyKeys] = useState<Set<string>>(() => new Set());

  const setDirty = useCallback((key: string, dirty: boolean) => {
    setDirtyKeys((prev) => {
      const next = new Set(prev);
      if (dirty) next.add(key);
      else next.delete(key);
      if (next.size === prev.size && [...next].every((k) => prev.has(k))) {
        return prev;
      }
      return next;
    });
  }, []);

  const value = useMemo(
    () => ({
      isDirty: dirtyKeys.size > 0,
      setDirty,
    }),
    [dirtyKeys, setDirty]
  );

  return (
    <NavigationGuardContext.Provider value={value}>
      {children}
    </NavigationGuardContext.Provider>
  );
}

export function useNavigationGuardContext() {
  const ctx = useContext(NavigationGuardContext);
  if (!ctx) {
    throw new Error("useNavigationGuardContext must be used within NavigationGuardProvider");
  }
  return ctx;
}

export function useNavigationGuard(key: string, dirty: boolean) {
  const { setDirty } = useNavigationGuardContext();

  useEffect(() => {
    setDirty(key, dirty);
    return () => setDirty(key, false);
  }, [key, dirty, setDirty]);
}
