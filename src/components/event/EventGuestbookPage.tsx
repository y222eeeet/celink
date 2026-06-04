"use client";

import { useState } from "react";
import { EventSubpageHeader } from "@/components/ui/EventSubpageHeader";
import { PrimaryButton } from "@/components/ui/PrimaryButton";
import { BackLink } from "@/components/ui/BackLink";
import { GuestbookEntryCard } from "@/components/event/GuestbookEntryCard";
import { MOCK_USER } from "@/lib/mock/events";
import {
  useCreatedEvents,
  useEventDetail,
  useInteractionStore,
} from "@/lib/stores/app-store";
import { useNavigationGuard } from "@/lib/stores/navigation-guard";

export function EventGuestbookPage({ eventId }: { eventId: string }) {
  const detail = useEventDetail(eventId);
  const { isOwned } = useCreatedEvents();
  const interaction = useInteractionStore();
  const owned = isOwned(eventId);

  const [authorName, setAuthorName] = useState(MOCK_USER.name);
  const [content, setContent] = useState("");
  const [isPrivate, setIsPrivate] = useState(false);

  useNavigationGuard(`guestbook-${eventId}`, content.trim().length > 0);

  if (!detail) return <p className="p-5 text-ink-muted">이벤트를 찾을 수 없습니다</p>;

  const entries = interaction.guestbookEntries(eventId, detail.guestbook);

  const submit = () => {
    interaction.addGuestbookEntry(
      eventId,
      authorName,
      content,
      isPrivate,
      owned
    );
    setContent("");
  };

  return (
    <div className="space-y-6 pb-8 pt-4">
      <BackLink href={`/events/${eventId}`} />
      <EventSubpageHeader
        title={owned ? "방명록 관리" : "방명록"}
        eventTitle={detail.summary.title}
        subtitle={`${entries.length}개의 메시지`}
      />

      <div className="space-y-3">
        {entries.length === 0 ? (
          <p className="text-sm text-ink-muted">아직 메시지가 없어요</p>
        ) : (
          entries.map((entry) => (
            <GuestbookEntryCard
              key={entry.id}
              entry={entry}
              viewerName={MOCK_USER.name}
              isOwner={owned}
            />
          ))
        )}
      </div>

      <div className="space-y-3 rounded-xl border border-blush bg-surface p-4">
        <input
          value={authorName}
          onChange={(e) => setAuthorName(e.target.value)}
          placeholder="이름"
          className="w-full rounded-lg border border-blush px-3 py-2 text-sm"
        />
        <textarea
          value={content}
          onChange={(e) => setContent(e.target.value)}
          placeholder="축하 메시지를 남겨주세요"
          rows={3}
          className="w-full rounded-lg border border-blush px-3 py-2 text-sm"
        />
        <label className="flex items-center gap-2 text-sm text-ink">
          <input
            type="checkbox"
            checked={isPrivate}
            onChange={(e) => setIsPrivate(e.target.checked)}
          />
          비공개로 남기기
        </label>
        <PrimaryButton
          title="등록하기"
          disabled={!content.trim()}
          onClick={submit}
        />
      </div>
    </div>
  );
}
