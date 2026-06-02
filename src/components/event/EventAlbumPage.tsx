"use client";

import { useState } from "react";
import { EventSubpageHeader } from "@/components/ui/EventSubpageHeader";
import { BackLink } from "@/components/ui/BackLink";
import {
  useCreatedEvents,
  useEventDetail,
  useInteractionStore,
} from "@/lib/stores/app-store";
import { formatRelative } from "@/lib/utils/date";

export function EventAlbumPage({ eventId }: { eventId: string }) {
  const detail = useEventDetail(eventId);
  const { isOwned } = useCreatedEvents();
  const interaction = useInteractionStore();
  const owned = isOwned(eventId);

  const [selectedUrl, setSelectedUrl] = useState<string | null>(null);
  const [commentText, setCommentText] = useState("");

  if (!detail) return <p className="p-5 text-ink-muted">이벤트를 찾을 수 없습니다</p>;

  const photos = interaction.photoURLs(eventId, detail.photoURLs, owned);

  const upload = (file: File) => {
    const reader = new FileReader();
    reader.onload = () => {
      const url = String(reader.result);
      interaction.addPhoto(eventId, url, owned);
    };
    reader.readAsDataURL(file);
  };

  return (
    <div className="space-y-6 pb-8 pt-4">
      <div className="flex items-center justify-between">
        <BackLink href={`/events/${eventId}`} />
        <label className="cursor-pointer rounded-full bg-primary-deep px-3 py-1.5 text-xs font-semibold text-white">
          + 추가
          <input
            type="file"
            accept="image/*"
            className="hidden"
            onChange={(e) => {
              const file = e.target.files?.[0];
              if (file) upload(file);
            }}
          />
        </label>
      </div>

      <EventSubpageHeader
        title={owned ? "공유앨범 관리" : "사진 앨범"}
        eventTitle={detail.summary.title}
        subtitle={`${photos.length}장의 사진`}
      />

      {photos.length === 0 ? (
        <p className="text-center text-sm text-ink-muted py-12">아직 공유된 사진이 없어요</p>
      ) : (
        <div className="grid grid-cols-3 gap-1.5">
          {photos.map((url) => (
            <button
              key={url}
              type="button"
              onClick={() => setSelectedUrl(url)}
              className="relative aspect-square overflow-hidden rounded-lg bg-cream-dark"
            >
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img src={url} alt="" className="h-full w-full object-cover" />
              {owned && interaction.isPhotoPrivate(eventId, url) ? (
                <span className="absolute right-1 top-1 rounded bg-black/60 px-1.5 py-0.5 text-[10px] text-white">
                  비공개
                </span>
              ) : null}
            </button>
          ))}
        </div>
      )}

      {selectedUrl ? (
        <div className="fixed inset-0 z-50 flex flex-col bg-cream">
          <div className="flex items-center justify-between px-5 py-4">
            <button type="button" onClick={() => setSelectedUrl(null)} className="text-sm text-primary-deep">
              닫기
            </button>
          </div>
          <div className="flex-1 overflow-y-auto">
            <div className="px-5 pt-2">
              <div className="relative mx-auto w-full max-w-[calc(100%-0px)] overflow-hidden rounded-xl">
                {/* eslint-disable-next-line @next/next/no-img-element */}
                <img
                  src={selectedUrl}
                  alt=""
                  className="h-auto w-full rounded-xl object-contain"
                />
              </div>
            </div>
            <div className="mt-3 flex gap-4 px-5 py-3">
              <button
                type="button"
                onClick={() => interaction.toggleLike(selectedUrl)}
                className="text-sm font-semibold text-ink"
              >
                {interaction.isLiked(selectedUrl) ? "♥" : "♡"}{" "}
                {interaction.likeCount(selectedUrl)}
              </button>
              <span className="text-sm font-semibold text-ink">
                💬 {interaction.comments(selectedUrl).length}
              </span>
            </div>
            {owned ? (
              <div className="flex gap-2 px-5 pb-2">
                <button
                  type="button"
                  onClick={() => interaction.togglePhotoPrivacy(eventId, selectedUrl)}
                  className="rounded-full bg-cream-dark px-3 py-1.5 text-xs font-semibold text-primary-deep"
                >
                  {interaction.isPhotoPrivate(eventId, selectedUrl)
                    ? "공개로 전환"
                    : "비공개 처리"}
                </button>
                <button
                  type="button"
                  onClick={() => {
                    interaction.deletePhoto(eventId, selectedUrl, owned);
                    setSelectedUrl(null);
                  }}
                  className="rounded-full bg-red-500/85 px-3 py-1.5 text-xs font-semibold text-white"
                >
                  사진 삭제
                </button>
              </div>
            ) : null}
            <div className="space-y-2 px-5 pb-4">
              <p className="text-sm font-semibold text-ink">댓글</p>
              {interaction.comments(selectedUrl).map((c) => (
                <div key={c.id} className="rounded-lg bg-cream-dark/55 p-3">
                  <div className="flex justify-between text-xs">
                    <span className="font-semibold text-ink">{c.authorName}</span>
                    <span className="text-ink-muted">{formatRelative(c.createdAt)}</span>
                  </div>
                  <p className="mt-1 text-sm text-ink">{c.content}</p>
                </div>
              ))}
            </div>
          </div>
          <div className="flex gap-2 border-t border-blush px-5 py-3">
            <input
              value={commentText}
              onChange={(e) => setCommentText(e.target.value)}
              placeholder="댓글을 입력해 주세요"
              className="flex-1 rounded-lg border border-blush bg-surface px-3 py-2 text-sm"
            />
            <button
              type="button"
              onClick={() => {
                interaction.addComment(selectedUrl, commentText);
                setCommentText("");
              }}
              disabled={!commentText.trim()}
              className="rounded-lg bg-primary-deep px-4 py-2 text-sm font-semibold text-white disabled:opacity-40"
            >
              등록
            </button>
          </div>
        </div>
      ) : null}
    </div>
  );
}
