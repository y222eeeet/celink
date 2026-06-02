"use client";

import {
  createContext,
  useCallback,
  useContext,
  useMemo,
  useState,
  type ReactNode,
} from "react";
import { DEFAULT_COVER_BY_TYPE } from "@/lib/constants/event";
import { MOCK_USER, SEED_OWNED_EVENT, getMockEventDetail } from "@/lib/mock/events";
import type {
  CelebrationLedgerEntry,
  EditableScheduleItem,
  EventDetail,
  EventSummary,
  EventType,
  GuestbookEntry,
  InvitedParticipantEntry,
  PhotoComment,
  PhotoSocialState,
  RSVPStatus,
  SentGiftEntry,
} from "@/lib/types";
import { toLocalISOString } from "@/lib/utils/date-rounding";

const SEED_LEDGER: Record<string, CelebrationLedgerEntry[]> = {
  "owned-birthday-1": [
    { id: "ld-1", senderName: "엄마", relation: "family", amount: 100_000 },
    { id: "ld-2", senderName: "민지", relation: "bestFriend", amount: 50_000 },
    { id: "ld-3", senderName: "태훈", relation: "friend", amount: 30_000 },
    { id: "ld-4", senderName: "수현 대리", relation: "coworker", amount: 50_000 },
    { id: "ld-5", senderName: "건우", relation: "acquaintance", amount: 30_000 },
    { id: "ld-6", senderName: "익명", relation: "etc", amount: 10_000 },
  ],
};

const SEED_PARTICIPANTS: Record<string, InvitedParticipantEntry[]> = {
  "owned-birthday-1": [
    { id: "pt-1", name: "엄마", relation: "family", rsvpStatus: "yes" },
    { id: "pt-2", name: "아빠", relation: "family", rsvpStatus: "yes" },
    { id: "pt-3", name: "민지", relation: "bestFriend", rsvpStatus: "yes" },
    { id: "pt-4", name: "지은", relation: "bestFriend", rsvpStatus: "maybe" },
    { id: "pt-5", name: "태훈", relation: "friend", rsvpStatus: "yes" },
    { id: "pt-6", name: "승호", relation: "friend", rsvpStatus: "no" },
    { id: "pt-7", name: "수현 대리", relation: "coworker", rsvpStatus: "pending" },
    { id: "pt-8", name: "민석 과장", relation: "coworker", rsvpStatus: "yes" },
    { id: "pt-9", name: "건우", relation: "acquaintance", rsvpStatus: "maybe" },
    { id: "pt-10", name: "하늘", relation: "etc", rsvpStatus: "pending" },
  ],
};

function getLedgerEntries(
  eventId: string,
  cache: Record<string, CelebrationLedgerEntry[]>
): CelebrationLedgerEntry[] {
  return cache[eventId] ?? SEED_LEDGER[eventId] ?? [];
}

function getParticipantEntries(
  eventId: string,
  cache: Record<string, InvitedParticipantEntry[]>
): InvitedParticipantEntry[] {
  return cache[eventId] ?? SEED_PARTICIPANTS[eventId] ?? [];
}

function uid(prefix: string) {
  return `${prefix}-${Math.random().toString(36).slice(2, 10)}`;
}
  return `${prefix}-${Math.random().toString(36).slice(2, 10)}`;
}

interface CreatedEventsContextValue {
  ownedEvents: EventDetail[];
  ownedSummaries: EventSummary[];
  isOwned: (eventId: string) => boolean;
  getOwnedDetail: (eventId: string) => EventDetail | undefined;
  publishEvent: (input: PublishEventInput) => EventDetail;
  updateEvent: (eventId: string, input: PublishEventInput) => EventDetail | undefined;
  updateOwnedRSVP: (eventId: string, status: RSVPStatus) => void;
  addOwnedGuestbook: (eventId: string, entry: GuestbookEntry) => void;
  addOwnedPhoto: (eventId: string, url: string) => void;
  removeOwnedPhoto: (eventId: string, url: string) => void;
  invitePath: (eventId: string) => string;
}

export interface PublishEventInput {
  type: EventType;
  title: string;
  date: string;
  location: string;
  description: string;
  dressCode?: string | null;
  notice?: string | null;
  coverImage: string;
  scheduleItems: EditableScheduleItem[];
}

interface InteractionContextValue {
  rsvpStatus: (eventId: string, defaultStatus: RSVPStatus) => RSVPStatus;
  lateArrivalTime: (eventId: string) => string | undefined;
  saveRSVP: (
    eventId: string,
    status: RSVPStatus,
    lateArrivalTime?: string | null
  ) => void;
  guestbookEntries: (eventId: string, base: GuestbookEntry[]) => GuestbookEntry[];
  addGuestbookEntry: (
    eventId: string,
    authorName: string,
    content: string,
    isPrivate: boolean,
    isOwned: boolean
  ) => GuestbookEntry | null;
  photoURLs: (
    eventId: string,
    base: string[],
    includePrivate: boolean
  ) => string[];
  isPhotoPrivate: (eventId: string, url: string) => boolean;
  togglePhotoPrivacy: (eventId: string, url: string) => void;
  deletePhoto: (eventId: string, url: string, isOwned: boolean) => void;
  addPhoto: (eventId: string, url: string, isOwned: boolean) => void;
  likeCount: (url: string) => number;
  isLiked: (url: string) => boolean;
  comments: (url: string) => PhotoComment[];
  toggleLike: (url: string) => void;
  addComment: (url: string, content: string) => void;
  ledgerEntries: (eventId: string) => CelebrationLedgerEntry[];
  participantEntries: (eventId: string) => InvitedParticipantEntry[];
  totalReceivedAmount: () => number;
  totalSentAmount: () => number;
  currentLedgerAmount: () => number;
  receivedOverviewByOwnedEvent: (owned: EventSummary[]) => {
    id: string;
    eventTitle: string;
    amount: number;
  }[];
  sentGiftOverview: () => SentGiftEntry[];
  withdrawFromLedger: (amount: number) => number;
}

const CreatedEventsContext = createContext<CreatedEventsContextValue | null>(
  null
);
const InteractionContext = createContext<InteractionContextValue | null>(null);

function buildDetail(
  eventId: string,
  input: PublishEventInput,
  guestbook: GuestbookEntry[],
  photoURLs: string[]
): EventDetail {
  const schedule = input.scheduleItems.map((item) => ({
    id: item.id,
    time: item.time,
    title: item.title,
    note: item.note || null,
  }));

  return {
    summary: {
      id: eventId,
      type: input.type,
      title: input.title,
      date: input.date,
      location: input.location,
      coverImage: input.coverImage,
      hostName: MOCK_USER.name,
      rsvpStatus: "yes",
      lastParticipatedAt: null,
      isUpcoming: new Date(input.date) >= new Date(),
    },
    description: input.description,
    dressCode: input.dressCode || null,
    notice: input.notice || null,
    schedule,
    guestbook,
    photoURLs,
  };
}

export function AppStoreProvider({ children }: { children: ReactNode }) {
  const [ownedEvents, setOwnedEvents] = useState<EventDetail[]>([
    SEED_OWNED_EVENT,
  ]);

  const [rsvpOverrides, setRsvpOverrides] = useState<
    Record<string, RSVPStatus>
  >({});
  const [lateArrivalTimes, setLateArrivalTimes] = useState<
    Record<string, string>
  >({});
  const [addedGuestbook, setAddedGuestbook] = useState<
    Record<string, GuestbookEntry[]>
  >({});
  const [addedPhotos, setAddedPhotos] = useState<Record<string, string[]>>({});
  const [photoSocialState, setPhotoSocialState] = useState<
    Record<string, PhotoSocialState>
  >({});
  const [privatePhotoKeys, setPrivatePhotoKeys] = useState<
    Record<string, Set<string>>
  >({});
  const [deletedPhotoKeys, setDeletedPhotoKeys] = useState<
    Record<string, Set<string>>
  >({});
  const [ledgerByEvent, setLedgerByEvent] = useState<
    Record<string, CelebrationLedgerEntry[]>
  >({});
  const [participantsByEvent, setParticipantsByEvent] = useState<
    Record<string, InvitedParticipantEntry[]>
  >({});
  const [sentGiftEntries] = useState<SentGiftEntry[]>([
    {
      id: "sg-1",
      eventId: "evt-2",
      eventTitle: "졸업 전시 — 빛의 결",
      amount: 30_000,
    },
    {
      id: "sg-2",
      eventId: "evt-1",
      eventTitle: "민수 ♥ 지연 결혼식",
      amount: 50_000,
    },
    {
      id: "sg-3",
      eventId: "evt-4",
      eventTitle: "봄밤 재즈 콘서트",
      amount: 10_000,
    },
  ]);
  const [withdrawnAmount, setWithdrawnAmount] = useState(0);

  const ownedSummaries = useMemo(
    () =>
      [...ownedEvents.map((e) => e.summary)].sort(
        (a, b) => new Date(a.date).getTime() - new Date(b.date).getTime()
      ),
    [ownedEvents]
  );

  const createdValue = useMemo<CreatedEventsContextValue>(
    () => ({
      ownedEvents,
      ownedSummaries,
      isOwned: (eventId) => ownedEvents.some((e) => e.summary.id === eventId),
      getOwnedDetail: (eventId) =>
        ownedEvents.find((e) => e.summary.id === eventId),
      publishEvent: (input) => {
        const eventId = uid("evt");
        const cover =
          input.coverImage || DEFAULT_COVER_BY_TYPE[input.type];
        const detail = buildDetail(eventId, { ...input, coverImage: cover }, [], []);
        setOwnedEvents((prev) => [detail, ...prev]);
        return detail;
      },
      updateEvent: (eventId, input) => {
        let updated: EventDetail | undefined;
        setOwnedEvents((prev) =>
          prev.map((event) => {
            if (event.summary.id !== eventId) return event;
            updated = buildDetail(
              eventId,
              {
                ...input,
                coverImage:
                  input.coverImage ||
                  event.summary.coverImage,
              },
              event.guestbook,
              event.photoURLs
            );
            return updated;
          })
        );
        return updated;
      },
      updateOwnedRSVP: (eventId, status) => {
        setOwnedEvents((prev) =>
          prev.map((event) =>
            event.summary.id === eventId
              ? {
                  ...event,
                  summary: { ...event.summary, rsvpStatus: status },
                }
              : event
          )
        );
      },
      addOwnedGuestbook: (eventId, entry) => {
        setOwnedEvents((prev) =>
          prev.map((event) =>
            event.summary.id === eventId
              ? { ...event, guestbook: [entry, ...event.guestbook] }
              : event
          )
        );
      },
      addOwnedPhoto: (eventId, url) => {
        setOwnedEvents((prev) =>
          prev.map((event) =>
            event.summary.id === eventId
              ? { ...event, photoURLs: [url, ...event.photoURLs] }
              : event
          )
        );
      },
      removeOwnedPhoto: (eventId, url) => {
        setOwnedEvents((prev) =>
          prev.map((event) =>
            event.summary.id === eventId
              ? {
                  ...event,
                  photoURLs: event.photoURLs.filter((p) => p !== url),
                }
              : event
          )
        );
      },
      invitePath: (eventId) => `/i/${eventId}`,
    }),
    [ownedEvents, ownedSummaries]
  );

  const computeReceivedTotal = useCallback(() => {
    return ownedSummaries.reduce((sum, summary) => {
      const entries = getLedgerEntries(summary.id, ledgerByEvent);
      return sum + entries.reduce((s, e) => s + e.amount, 0);
    }, 0);
  }, [ownedSummaries, ledgerByEvent]);

  const computeCurrentLedger = useCallback(() => {
    const received = computeReceivedTotal();
    const sent = sentGiftEntries.reduce((sum, e) => sum + e.amount, 0);
    return Math.max(0, received - sent - withdrawnAmount);
  }, [computeReceivedTotal, sentGiftEntries, withdrawnAmount]);

  const interactionValue = useMemo<InteractionContextValue>(
    () => ({
      rsvpStatus: (eventId, defaultStatus) =>
        rsvpOverrides[eventId] ?? defaultStatus,
      lateArrivalTime: (eventId) => lateArrivalTimes[eventId],
      saveRSVP: (eventId, status, lateArrivalTime) => {
        setRsvpOverrides((prev) => ({ ...prev, [eventId]: status }));
        if (status === "maybe" && lateArrivalTime) {
          setLateArrivalTimes((prev) => ({
            ...prev,
            [eventId]: lateArrivalTime,
          }));
        } else {
          setLateArrivalTimes((prev) => {
            const next = { ...prev };
            delete next[eventId];
            return next;
          });
        }
      },
      guestbookEntries: (eventId, base) => {
        const extra = addedGuestbook[eventId] ?? [];
        return [...extra, ...base].sort(
          (a, b) =>
            new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
        );
      },
      addGuestbookEntry: (eventId, authorName, content, isPrivate, isOwned) => {
        const trimmed = content.trim();
        if (!trimmed) return null;
        const entry: GuestbookEntry = {
          id: uid("gb"),
          authorName: authorName.trim() || MOCK_USER.name,
          content: trimmed,
          isPrivate,
          createdAt: toLocalISOString(new Date()),
        };
        if (isOwned) {
          createdValue.addOwnedGuestbook(eventId, entry);
        } else {
          setAddedGuestbook((prev) => ({
            ...prev,
            [eventId]: [entry, ...(prev[eventId] ?? [])],
          }));
        }
        return entry;
      },
      photoURLs: (eventId, base, includePrivate) => {
        const extra = addedPhotos[eventId] ?? [];
        const combined = [...extra, ...base];
        const deleted = deletedPhotoKeys[eventId] ?? new Set<string>();
        const priv = privatePhotoKeys[eventId] ?? new Set<string>();
        return combined.filter((url) => {
          if (deleted.has(url)) return false;
          if (!includePrivate && priv.has(url)) return false;
          return true;
        });
      },
      isPhotoPrivate: (eventId, url) =>
        (privatePhotoKeys[eventId] ?? new Set()).has(url),
      togglePhotoPrivacy: (eventId, url) => {
        setPrivatePhotoKeys((prev) => {
          const set = new Set(prev[eventId] ?? []);
          if (set.has(url)) set.delete(url);
          else set.add(url);
          return { ...prev, [eventId]: set };
        });
      },
      deletePhoto: (eventId, url, isOwned) => {
        if (isOwned) {
          createdValue.removeOwnedPhoto(eventId, url);
        } else {
          setDeletedPhotoKeys((prev) => {
            const set = new Set(prev[eventId] ?? []);
            set.add(url);
            return { ...prev, [eventId]: set };
          });
        }
      },
      addPhoto: (eventId, url, isOwned) => {
        if (isOwned) {
          createdValue.addOwnedPhoto(eventId, url);
        } else {
          setAddedPhotos((prev) => ({
            ...prev,
            [eventId]: [url, ...(prev[eventId] ?? [])],
          }));
        }
      },
      likeCount: (url) => photoSocialState[url]?.likeCount ?? 0,
      isLiked: (url) => photoSocialState[url]?.isLiked ?? false,
      comments: (url) => photoSocialState[url]?.comments ?? [],
      toggleLike: (url) => {
        setPhotoSocialState((prev) => {
          const state = prev[url] ?? {
            likeCount: 0,
            isLiked: false,
            comments: [],
          };
          if (state.isLiked) {
            return {
              ...prev,
              [url]: {
                ...state,
                isLiked: false,
                likeCount: Math.max(0, state.likeCount - 1),
              },
            };
          }
          return {
            ...prev,
            [url]: { ...state, isLiked: true, likeCount: state.likeCount + 1 },
          };
        });
      },
      addComment: (url, content) => {
        const trimmed = content.trim();
        if (!trimmed) return;
        setPhotoSocialState((prev) => {
          const state = prev[url] ?? {
            likeCount: 0,
            isLiked: false,
            comments: [],
          };
          const comment: PhotoComment = {
            id: uid("pc"),
            authorName: MOCK_USER.name,
            content: trimmed,
            createdAt: toLocalISOString(new Date()),
          };
          return {
            ...prev,
            [url]: { ...state, comments: [comment, ...state.comments] },
          };
        });
      },
      ledgerEntries: (eventId) => getLedgerEntries(eventId, ledgerByEvent),
      participantEntries: (eventId) =>
        getParticipantEntries(eventId, participantsByEvent),
      totalReceivedAmount: () => computeReceivedTotal(),
      totalSentAmount: () =>
        sentGiftEntries.reduce((sum, e) => sum + e.amount, 0),
      currentLedgerAmount: () => computeCurrentLedger(),
      receivedOverviewByOwnedEvent: (owned) =>
        owned.map((summary) => {
          const entries = getLedgerEntries(summary.id, ledgerByEvent);
          return {
            id: summary.id,
            eventTitle: summary.title,
            amount: entries.reduce((s, e) => s + e.amount, 0),
          };
        }),
      sentGiftOverview: () => sentGiftEntries,
      withdrawFromLedger: (amount) => {
        const available = computeCurrentLedger();
        const accepted = Math.min(Math.max(0, amount), available);
        setWithdrawnAmount((prev) => prev + accepted);
        return accepted;
      },
    }),
    [
      rsvpOverrides,
      lateArrivalTimes,
      addedGuestbook,
      addedPhotos,
      photoSocialState,
      privatePhotoKeys,
      deletedPhotoKeys,
      ledgerByEvent,
      participantsByEvent,
      sentGiftEntries,
      withdrawnAmount,
      ownedSummaries,
      createdValue,
      computeReceivedTotal,
      computeCurrentLedger,
    ]
  );

  return (
    <CreatedEventsContext.Provider value={createdValue}>
      <InteractionContext.Provider value={interactionValue}>
        {children}
      </InteractionContext.Provider>
    </CreatedEventsContext.Provider>
  );
}

export function useCreatedEvents() {
  const ctx = useContext(CreatedEventsContext);
  if (!ctx) throw new Error("useCreatedEvents must be used within AppStoreProvider");
  return ctx;
}

export function useInteractionStore() {
  const ctx = useContext(InteractionContext);
  if (!ctx)
    throw new Error("useInteractionStore must be used within AppStoreProvider");
  return ctx;
}

export function useEventDetail(eventId: string): EventDetail | undefined {
  const { getOwnedDetail } = useCreatedEvents();
  return getOwnedDetail(eventId) ?? getMockEventDetail(eventId);
}
