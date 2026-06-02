"use client";

import { useRouter } from "next/navigation";
import { useMemo, useState } from "react";
import { EventSubpageHeader } from "@/components/ui/EventSubpageHeader";
import { PrimaryButton } from "@/components/ui/PrimaryButton";
import { BackLink } from "@/components/ui/BackLink";
import { useEventDetail } from "@/lib/stores/app-store";
import { formatAmount } from "@/lib/utils/currency";

const PRESETS = [10_000, 30_000, 50_000, 100_000];

export function EventGiftPage({ eventId }: { eventId: string }) {
  const router = useRouter();
  const detail = useEventDetail(eventId);
  const [selected, setSelected] = useState<number | null>(null);
  const [custom, setCustom] = useState("");

  const finalAmount = useMemo(() => {
    if (selected) return selected;
    const n = parseInt(custom.replace(/\D/g, ""), 10);
    return Number.isFinite(n) ? n : 0;
  }, [selected, custom]);

  if (!detail) return <p className="p-5 text-ink-muted">이벤트를 찾을 수 없습니다</p>;

  const pay = () => {
    alert(`${formatAmount(finalAmount)} 결제가 완료되었습니다.`);
    router.back();
  };

  return (
    <div className="space-y-6 pb-8 pt-4">
      <BackLink href={`/events/${eventId}`} />
      <EventSubpageHeader
        title="앱 내 결제"
        eventTitle={detail.summary.title}
        subtitle="축하금을 안전하게 전달할 수 있어요"
      />

      <div className="grid grid-cols-2 gap-2.5">
        {PRESETS.map((amount) => (
          <button
            key={amount}
            type="button"
            onClick={() => {
              setSelected(amount);
              setCustom("");
            }}
            className={`rounded-xl border py-3.5 text-sm font-semibold ${
              selected === amount
                ? "border-primary bg-primary/10 text-primary-deep"
                : "border-blush bg-surface text-ink"
            }`}
          >
            {formatAmount(amount)}
          </button>
        ))}
      </div>

      <div className="space-y-2">
        <p className="text-sm font-semibold text-ink">직접 입력</p>
        <input
          value={custom}
          onChange={(e) => {
            setCustom(e.target.value.replace(/\D/g, ""));
            setSelected(null);
          }}
          placeholder="예: 20000"
          inputMode="numeric"
          className="w-full rounded-xl border border-blush bg-surface px-3 py-3 text-sm"
        />
      </div>

      {finalAmount > 0 ? (
        <p className="text-sm font-medium text-primary-deep">
          결제 금액: {formatAmount(finalAmount)}
        </p>
      ) : null}

      <PrimaryButton title="결제하기" disabled={finalAmount <= 0} onClick={pay} />
    </div>
  );
}
