"use client";

import Image from "next/image";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { useNavigationGuardContext } from "@/lib/stores/navigation-guard";

export function TopBar() {
  const router = useRouter();
  const { isDirty } = useNavigationGuardContext();
  const [showConfirm, setShowConfirm] = useState(false);

  const goHome = () => {
    setShowConfirm(false);
    router.push("/");
  };

  const handleLogoClick = () => {
    if (isDirty) {
      setShowConfirm(true);
      return;
    }
    goHome();
  };

  return (
    <>
      <header className="sticky top-0 z-40 border-b border-blush/80 bg-cream/95 backdrop-blur-md">
        <div className="mx-auto flex h-14 max-w-lg items-center px-5">
          <button
            type="button"
            onClick={handleLogoClick}
            className="relative h-8 w-[100px] shrink-0"
            aria-label="Celink 홈으로"
          >
            <Image
              src="/images/celink-text-logo.png"
              alt="Celink"
              fill
              className="object-contain object-left"
              sizes="108px"
              priority
            />
          </button>
        </div>
      </header>

      {showConfirm ? (
        <div
          className="fixed inset-0 z-[70] flex items-center justify-center bg-black/40 px-5"
          role="dialog"
          aria-modal="true"
          aria-labelledby="leave-dialog-title"
        >
          <div className="w-full max-w-sm rounded-2xl border border-blush bg-surface p-5 shadow-lg">
            <p id="leave-dialog-title" className="text-base font-semibold text-ink">
              지금 나가면 저장되지 않습니다
            </p>
            <p className="mt-2 text-sm text-ink-muted">
              작성 중인 내용이 사라질 수 있어요. 그래도 홈으로 나갈까요?
            </p>
            <div className="mt-5 flex gap-2.5">
              <button
                type="button"
                onClick={() => setShowConfirm(false)}
                className="flex-1 rounded-xl border border-blush py-3 text-sm font-semibold text-ink"
              >
                취소
              </button>
              <button
                type="button"
                onClick={goHome}
                className="flex-1 rounded-xl bg-primary-deep py-3 text-sm font-semibold text-white"
              >
                나가기
              </button>
            </div>
          </div>
        </div>
      ) : null}
    </>
  );
}
