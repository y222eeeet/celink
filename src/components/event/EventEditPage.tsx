"use client";

import Image from "next/image";
import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { EVENT_TYPE_LABEL } from "@/lib/constants/event";
import { useCreatedEvents, useEventDetail } from "@/lib/stores/app-store";
import type { EditableScheduleItem, EventType } from "@/lib/types";
import { toLocalISOString, toFiveMinuteInterval } from "@/lib/utils/date-rounding";
import { PrimaryButton } from "@/components/ui/PrimaryButton";
import { BackLink } from "@/components/ui/BackLink";

export function EventEditPage({ eventId }: { eventId: string }) {
  const router = useRouter();
  const detail = useEventDetail(eventId);
  const { updateEvent, isOwned } = useCreatedEvents();

  const [title, setTitle] = useState("");
  const [date, setDate] = useState("");
  const [location, setLocation] = useState("");
  const [description, setDescription] = useState("");
  const [dressCode, setDressCode] = useState("");
  const [notice, setNotice] = useState("");
  const [coverImage, setCoverImage] = useState("");
  const [selectedType, setSelectedType] = useState<EventType>("wedding");
  const [scheduleItems, setScheduleItems] = useState<EditableScheduleItem[]>([]);

  useEffect(() => {
    if (!detail) return;
    setTitle(detail.summary.title);
    setDate(detail.summary.date);
    setLocation(detail.summary.location);
    setDescription(detail.description);
    setDressCode(detail.dressCode ?? "");
    setNotice(detail.notice ?? "");
    setCoverImage(detail.summary.coverImage);
    setSelectedType(detail.summary.type);
    setScheduleItems(
      detail.schedule.map((s) => ({
        id: s.id,
        time: s.time,
        title: s.title,
        note: s.note ?? "",
      }))
    );
  }, [detail]);

  if (!detail) {
    return <p className="p-5 text-ink-muted">이벤트를 찾을 수 없습니다</p>;
  }

  if (!isOwned(eventId)) {
    return <p className="p-5 text-ink-muted">수정 권한이 없습니다</p>;
  }

  const save = () => {
    updateEvent(eventId, {
      type: selectedType,
      title: title.trim(),
      date,
      location: location.trim(),
      description: description.trim(),
      dressCode: dressCode.trim() || null,
      notice: notice.trim() || null,
      coverImage,
      scheduleItems,
    });
    router.push(`/events/${eventId}`);
  };

  return (
    <div className="space-y-4 px-5 pb-8 pt-4">
      <BackLink href={`/events/${eventId}`} />
      <h1 className="font-serif text-2xl text-ink">이벤트 수정</h1>

      <div className="relative aspect-[4/3] overflow-hidden rounded-2xl">
        <Image src={coverImage} alt="" fill className="object-cover" sizes="400px" />
      </div>

      <Field label="제목" value={title} onChange={setTitle} />
      <label className="block space-y-1">
        <span className="text-sm font-medium">날짜·시간</span>
        <input
          type="datetime-local"
          value={date.slice(0, 16)}
          onChange={(e) =>
            setDate(toLocalISOString(toFiveMinuteInterval(new Date(e.target.value))))
          }
          className="w-full rounded-xl border border-blush px-3 py-2 text-sm"
        />
      </label>
      <Field label="장소" value={location} onChange={setLocation} />
      <Field label="설명" value={description} onChange={setDescription} multiline />
      <Field label="드레스코드" value={dressCode} onChange={setDressCode} />
      <Field label="안내" value={notice} onChange={setNotice} />

      <p className="text-xs text-ink-muted">{EVENT_TYPE_LABEL[selectedType]}</p>

      <PrimaryButton
        title="저장하기"
        disabled={!title.trim() || !location.trim()}
        onClick={save}
      />
    </div>
  );
}

function Field({
  label,
  value,
  onChange,
  multiline,
}: {
  label: string;
  value: string;
  onChange: (v: string) => void;
  multiline?: boolean;
}) {
  const cls = "w-full rounded-xl border border-blush px-3 py-2 text-sm";
  return (
    <label className="block space-y-1">
      <span className="text-sm font-medium">{label}</span>
      {multiline ? (
        <textarea value={value} onChange={(e) => onChange(e.target.value)} rows={3} className={cls} />
      ) : (
        <input value={value} onChange={(e) => onChange(e.target.value)} className={cls} />
      )}
    </label>
  );
}
