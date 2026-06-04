"use client";

import Image from "next/image";
import { useRouter } from "next/navigation";
import { useMemo, useState } from "react";
import {
  DEFAULT_COVER_BY_TYPE,
  EVENT_TYPE_LABEL,
} from "@/lib/constants/event";
import { useCreatedEvents } from "@/lib/stores/app-store";
import { useNavigationGuard } from "@/lib/stores/navigation-guard";
import type { CreateEventStep, EditableScheduleItem, EventType } from "@/lib/types";
import { toLocalISOString, toFiveMinuteInterval } from "@/lib/utils/date-rounding";
import { formatEventDate } from "@/lib/utils/date";
import { PrimaryButton } from "@/components/ui/PrimaryButton";
import { ScheduleList } from "@/components/ui/ScheduleList";

const STEPS: CreateEventStep[] = ["type", "basics", "cover", "schedule", "preview"];

const STEP_LABEL: Record<CreateEventStep, string> = {
  type: "타입",
  basics: "기본정보",
  cover: "커버",
  schedule: "식순",
  preview: "미리보기",
};

function defaultSchedule(): EditableScheduleItem[] {
  const now = toFiveMinuteInterval(new Date());
  return [
    {
      id: `sch-${Date.now()}`,
      time: toLocalISOString(now),
      title: "웰컴",
      note: "",
    },
  ];
}

export function CreateEventForm() {
  const router = useRouter();
  const { publishEvent, invitePath } = useCreatedEvents();

  const [step, setStep] = useState<CreateEventStep>("type");
  const [selectedType, setSelectedType] = useState<EventType>("wedding");
  const [title, setTitle] = useState("");
  const [date, setDate] = useState(() => toLocalISOString(toFiveMinuteInterval(new Date())));
  const [location, setLocation] = useState("");
  const [description, setDescription] = useState("");
  const [dressCode, setDressCode] = useState("");
  const [notice, setNotice] = useState("");
  const [coverImage, setCoverImage] = useState<string | null>(null);
  const [scheduleItems, setScheduleItems] = useState<EditableScheduleItem[]>(defaultSchedule);
  const [showSuccess, setShowSuccess] = useState(false);
  const [publishedId, setPublishedId] = useState<string | null>(null);

  const stepIndex = STEPS.indexOf(step);
  const cover = coverImage ?? DEFAULT_COVER_BY_TYPE[selectedType];

  const isDirty = useMemo(() => {
    if (showSuccess) return false;
    if (step !== "type") return true;
    return (
      title.trim().length > 0 ||
      location.trim().length > 0 ||
      description.trim().length > 0 ||
      dressCode.trim().length > 0 ||
      notice.trim().length > 0 ||
      coverImage !== null ||
      scheduleItems.length > 1 ||
      scheduleItems[0]?.title !== "웰컴"
    );
  }, [
    showSuccess,
    step,
    title,
    location,
    description,
    dressCode,
    notice,
    coverImage,
    scheduleItems,
  ]);

  useNavigationGuard("create-event", isDirty);

  const canNext = useMemo(() => {
    if (step === "basics") return title.trim().length > 0 && location.trim().length > 0;
    if (step === "schedule") return scheduleItems.every((s) => s.title.trim().length > 0);
    return true;
  }, [step, title, location, scheduleItems]);

  const goNext = () => {
    const idx = STEPS.indexOf(step);
    if (idx < STEPS.length - 1) setStep(STEPS[idx + 1]);
  };

  const goBack = () => {
    const idx = STEPS.indexOf(step);
    if (idx > 0) setStep(STEPS[idx - 1]);
  };

  const publish = () => {
    const detail = publishEvent({
      type: selectedType,
      title: title.trim(),
      date,
      location: location.trim(),
      description: description.trim(),
      dressCode: dressCode.trim() || null,
      notice: notice.trim() || null,
      coverImage: cover,
      scheduleItems,
    });
    setPublishedId(detail.summary.id);
    setShowSuccess(true);
  };

  if (showSuccess && publishedId) {
    return (
      <div className="flex min-h-[70dvh] flex-col items-center justify-center text-center">
        <p className="font-serif text-2xl text-ink">이벤트가 발행되었어요</p>
        <p className="mt-3 text-sm text-ink-muted">
          초대 링크: celink.app{invitePath(publishedId)}
        </p>
        <div className="mt-8 flex w-full max-w-sm flex-col gap-3">
          <PrimaryButton
            title="이벤트 보기"
            onClick={() => router.push(`/events/${publishedId}`)}
          />
          <button
            type="button"
            onClick={() => router.push("/")}
            className="text-sm text-primary-deep"
          >
            홈으로
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="pb-8 pt-4">
      <h1 className="font-serif text-2xl text-ink">이벤트 만들기</h1>
      <div className="mt-4 flex gap-2">
        {STEPS.map((s, i) => (
          <div
            key={s}
            className={`h-1 flex-1 rounded-full ${i <= stepIndex ? "bg-primary-deep" : "bg-blush"}`}
          />
        ))}
      </div>
      <p className="mt-2 text-xs text-ink-muted">{STEP_LABEL[step]}</p>

      <div className="mt-6 space-y-4">
        {step === "type" ? (
          <div className="grid grid-cols-2 gap-3">
            {(Object.keys(EVENT_TYPE_LABEL) as EventType[]).map((type) => (
              <button
                key={type}
                type="button"
                onClick={() => setSelectedType(type)}
                className={`rounded-xl border p-4 text-left text-sm font-semibold ${
                  selectedType === type
                    ? "border-primary bg-primary/10 text-primary-deep"
                    : "border-blush bg-surface text-ink"
                }`}
              >
                {EVENT_TYPE_LABEL[type]}
              </button>
            ))}
          </div>
        ) : null}

        {step === "basics" ? (
          <>
            <Field label="제목" value={title} onChange={setTitle} placeholder="이벤트 제목" />
            <label className="block space-y-1.5">
              <span className="text-sm font-medium text-ink">날짜·시간</span>
              <input
                type="datetime-local"
                value={date.slice(0, 16)}
                onChange={(e) => {
                  const d = toFiveMinuteInterval(new Date(e.target.value));
                  setDate(toLocalISOString(d));
                }}
                className="box-border w-full max-w-full min-w-0 rounded-xl border border-blush bg-surface px-3 py-3 text-sm"
              />
            </label>
            <Field label="장소" value={location} onChange={setLocation} placeholder="장소" />
            <Field label="설명" value={description} onChange={setDescription} placeholder="이벤트 설명" multiline />
            <Field label="드레스코드" value={dressCode} onChange={setDressCode} placeholder="선택" />
            <Field label="안내" value={notice} onChange={setNotice} placeholder="선택" />
          </>
        ) : null}

        {step === "cover" ? (
          <div className="space-y-3">
            <div className="relative aspect-[4/3] overflow-hidden rounded-2xl bg-cream-dark">
              <Image src={cover} alt="" fill className="object-cover object-center" sizes="400px" />
            </div>
            <label className="inline-block cursor-pointer rounded-xl border border-blush bg-surface px-4 py-2 text-sm font-medium text-primary-deep">
              사진 업로드
              <input
                type="file"
                accept="image/*"
                className="hidden"
                onChange={(e) => {
                  const file = e.target.files?.[0];
                  if (!file) return;
                  const reader = new FileReader();
                  reader.onload = () => setCoverImage(String(reader.result));
                  reader.readAsDataURL(file);
                }}
              />
            </label>
          </div>
        ) : null}

        {step === "schedule" ? (
          <div className="space-y-3">
            {scheduleItems.map((item, index) => (
              <div key={item.id} className="rounded-xl border border-blush bg-surface p-3 space-y-2">
                <input
                  type="datetime-local"
                  value={item.time.slice(0, 16)}
                  onChange={(e) => {
                    const next = [...scheduleItems];
                    next[index] = {
                      ...item,
                      time: toLocalISOString(toFiveMinuteInterval(new Date(e.target.value))),
                    };
                    setScheduleItems(next);
                  }}
                  className="box-border w-full max-w-full min-w-0 rounded-lg border border-blush px-2 py-2 text-sm"
                />
                <input
                  value={item.title}
                  onChange={(e) => {
                    const next = [...scheduleItems];
                    next[index] = { ...item, title: e.target.value };
                    setScheduleItems(next);
                  }}
                  placeholder="식순 제목"
                  className="box-border w-full max-w-full min-w-0 rounded-lg border border-blush px-2 py-2 text-sm"
                />
                {scheduleItems.length > 1 ? (
                  <button
                    type="button"
                    className="text-xs text-red-500"
                    onClick={() =>
                      setScheduleItems(scheduleItems.filter((_, i) => i !== index))
                    }
                  >
                    삭제
                  </button>
                ) : null}
              </div>
            ))}
            <button
              type="button"
              onClick={() =>
                setScheduleItems([
                  ...scheduleItems,
                  {
                    id: `sch-${Date.now()}`,
                    time: date,
                    title: "",
                    note: "",
                  },
                ])
              }
              className="text-sm font-medium text-primary-deep"
            >
              + 식순 추가
            </button>
          </div>
        ) : null}

        {step === "preview" ? (
          <div className="space-y-4">
            <div className="space-y-3 rounded-2xl border border-blush bg-surface p-4">
              <p className="text-xs text-primary">{EVENT_TYPE_LABEL[selectedType]}</p>
              <p className="font-serif text-xl text-ink">{title}</p>
              <p className="text-sm text-ink-muted">{formatEventDate(date)}</p>
              <p className="text-sm text-ink-muted">{location}</p>
              <p className="text-sm text-ink">{description || "설명 없음"}</p>
            </div>
            <ScheduleList items={scheduleItems} />
          </div>
        ) : null}
      </div>

      <div className="mt-8 flex gap-3">
        {stepIndex > 0 ? (
          <button
            type="button"
            onClick={goBack}
            className="flex-1 rounded-xl border border-blush py-3 text-sm font-semibold text-ink"
          >
            이전
          </button>
        ) : null}
        {step === "preview" ? (
          <PrimaryButton title="발행하기" onClick={publish} />
        ) : (
          <PrimaryButton title="다음" disabled={!canNext} onClick={goNext} />
        )}
      </div>
    </div>
  );
}

function Field({
  label,
  value,
  onChange,
  placeholder,
  multiline,
}: {
  label: string;
  value: string;
  onChange: (v: string) => void;
  placeholder: string;
  multiline?: boolean;
}) {
  const cls =
    "box-border w-full max-w-full min-w-0 rounded-xl border border-blush bg-surface px-3 py-3 text-sm";
  return (
    <label className="block space-y-1.5">
      <span className="text-sm font-medium text-ink">{label}</span>
      {multiline ? (
        <textarea value={value} onChange={(e) => onChange(e.target.value)} placeholder={placeholder} rows={3} className={cls} />
      ) : (
        <input value={value} onChange={(e) => onChange(e.target.value)} placeholder={placeholder} className={cls} />
      )}
    </label>
  );
}
