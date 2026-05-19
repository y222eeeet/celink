import Link from "next/link";
import { EVENT_TYPE_LABEL } from "@/lib/constants/event";
import { MOCK_INVITED_EVENTS } from "@/lib/mock/events";
import { formatEventDate } from "@/lib/utils/date";

interface EventPageProps {
  params: Promise<{ eventId: string }>;
}

export default async function EventDetailPage({ params }: EventPageProps) {
  const { eventId } = await params;
  const event = MOCK_INVITED_EVENTS.find((e) => e.id === eventId);

  if (!event) {
    return (
      <div className="flex min-h-dvh flex-col items-center justify-center bg-cream px-5">
        <p className="text-ink-muted">이벤트를 찾을 수 없습니다</p>
        <Link href="/" className="mt-4 text-sm text-rose-deep underline">
          홈으로
        </Link>
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-lg bg-cream px-5 py-12">
      <Link href="/" className="text-sm text-ink-muted">
        ← 홈
      </Link>
      <p className="mt-6 text-xs uppercase tracking-widest text-rose">
        {EVENT_TYPE_LABEL[event.type]}
      </p>
      <h1 className="mt-1 font-serif text-3xl text-ink">{event.title}</h1>
      <p className="mt-4 text-sm text-ink-muted">
        {formatEventDate(event.date)}
      </p>
      <p className="text-sm text-ink-muted">{event.location}</p>
      <p className="mt-8 text-sm text-ink-muted">
        이벤트 상세 페이지는 다음 단계에서 구현됩니다
      </p>
    </div>
  );
}
