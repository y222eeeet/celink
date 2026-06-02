"use client";

import { useRouter } from "next/navigation";
import { useState } from "react";
import { EventSubpageHeader } from "@/components/ui/EventSubpageHeader";
import { PrimaryButton } from "@/components/ui/PrimaryButton";
import { BackLink } from "@/components/ui/BackLink";
import { MOCK_USER } from "@/lib/mock/events";
import {
  useCreatedEvents,
  useInteractionStore,
} from "@/lib/stores/app-store";
import { formatAmount } from "@/lib/utils/currency";
import { SectionHeader } from "@/components/ui/SectionHeader";

export function ProfileLedgerPage() {
  const { ownedSummaries } = useCreatedEvents();
  const interaction = useInteractionStore();

  const received = interaction.receivedOverviewByOwnedEvent(ownedSummaries);
  const sent = interaction.sentGiftOverview();
  const totalReceived = interaction.totalReceivedAmount();
  const totalSent = interaction.totalSentAmount();
  const current = interaction.currentLedgerAmount();

  return (
    <div className="space-y-6 pb-8 pt-4">
      <BackLink href="/profile" label="← 프로필" />
      <EventSubpageHeader
        title="장부 상세"
        eventTitle={`${MOCK_USER.name}님의 축하금 현황`}
        subtitle="이벤트별 수령 금액과 내가 보낸 금액을 확인해요"
      />

      <div className="rounded-xl border border-blush bg-surface p-4 space-y-3">
        <Row label="총 받은 축하금" value={formatAmount(totalReceived)} highlight />
        <Row label="총 보낸 축하금" value={formatAmount(totalSent)} />
        <hr className="border-blush" />
        <Row label="현재 장부 금액" value={formatAmount(current)} large />
      </div>

      <section className="space-y-2">
        <SectionHeader title="내가 주최한 이벤트 수령 금액" trailing={`${received.length}개`} />
        {received.map((item) => (
          <AmountRow key={item.id} title={item.eventTitle} amount={item.amount} />
        ))}
      </section>

      <section className="space-y-2">
        <SectionHeader title="내가 보낸 축하금" trailing={`${sent.length}건`} />
        {sent.map((item) => (
          <AmountRow key={item.id} title={item.eventTitle} amount={item.amount} />
        ))}
      </section>
    </div>
  );
}

function Row({
  label,
  value,
  highlight,
  large,
}: {
  label: string;
  value: string;
  highlight?: boolean;
  large?: boolean;
}) {
  return (
    <div className="flex items-center justify-between">
      <span className={`${large ? "text-sm font-semibold" : "text-xs"} text-ink-muted`}>
        {label}
      </span>
      <span
        className={`font-semibold ${
          large ? "text-xl text-primary-deep" : highlight ? "text-primary-deep" : "text-ink"
        }`}
      >
        {value}
      </span>
    </div>
  );
}

function AmountRow({ title, amount }: { title: string; amount: number }) {
  return (
    <div className="flex items-center justify-between rounded-xl border border-blush bg-surface p-3">
      <p className="text-sm text-ink">{title}</p>
      <p className="text-sm font-semibold text-primary-deep">{formatAmount(amount)}</p>
    </div>
  );
}

type FlowState = "input" | "pg" | "success";

export function ProfileWithdrawPage() {
  const router = useRouter();
  const interaction = useInteractionStore();
  const [amountText, setAmountText] = useState("");
  const [flow, setFlow] = useState<FlowState>("input");

  const available = interaction.currentLedgerAmount();
  const requested = parseInt(amountText.replace(/\D/g, ""), 10) || 0;
  const finalAmount = Math.min(requested, available);

  const startWithdraw = () => {
    const accepted = interaction.withdrawFromLedger(finalAmount);
    if (accepted <= 0) return;
    setFlow("pg");
    setTimeout(() => setFlow("success"), 3000);
    setTimeout(() => router.push("/profile"), 5000);
  };

  if (flow === "pg" || flow === "success") {
    return (
      <div className="flex min-h-[70dvh] items-center justify-center">
        <p className="text-xl font-semibold text-ink">
          {flow === "pg" ? "PG사 연동화면" : "송금완료"}
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-6 pb-8 pt-4">
      <BackLink href="/profile" label="← 프로필" />
      <EventSubpageHeader
        title="장부 출금"
        eventTitle="프로필"
        subtitle="원하는 금액을 입력해 출금할 수 있어요"
      />

      <div className="rounded-xl border border-blush bg-surface p-4">
        <p className="text-xs text-ink-muted">출금 가능 금액</p>
        <p className="text-xl font-semibold text-primary-deep">{formatAmount(available)}</p>
      </div>

      <div className="space-y-2">
        <div className="flex items-center justify-between">
          <p className="text-sm font-semibold text-ink">출금 금액</p>
          <button
            type="button"
            onClick={() => setAmountText(String(available))}
            className="text-xs font-semibold text-primary-deep"
          >
            전체
          </button>
        </div>
        <input
          value={amountText}
          onChange={(e) => setAmountText(e.target.value.replace(/\D/g, ""))}
          placeholder="예: 50000"
          inputMode="numeric"
          className="w-full rounded-xl border border-blush bg-surface px-3 py-3 text-sm"
        />
      </div>

      {requested > 0 ? (
        <p className="text-sm text-primary-deep">
          출금 예정 금액: {formatAmount(finalAmount)}
        </p>
      ) : null}

      <PrimaryButton
        title="출금하기"
        disabled={finalAmount <= 0}
        onClick={startWithdraw}
      />
    </div>
  );
}
