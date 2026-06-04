"use client";

import { useMemo } from "react";
import { EventCard } from "@/components/home/EventCard";
import { HomeHeader } from "@/components/home/HomeHeader";
import { InvitedEventsSection } from "@/components/home/InvitedEventsSection";
import { RecentParticipationSection } from "@/components/home/RecentParticipationSection";
import { RecentPhotos } from "@/components/home/RecentPhotos";
import { ReminderList } from "@/components/home/ReminderList";
import { UpcomingSection } from "@/components/home/UpcomingSection";
import { SectionHeader } from "@/components/ui/SectionHeader";
import {
  MOCK_INVITED_EVENTS,
  MOCK_RECENT_PHOTOS,
  MOCK_REMINDERS,
} from "@/lib/mock/events";
import { useCreatedEvents, useInteractionStore } from "@/lib/stores/app-store";
import type { EventSummary } from "@/lib/types";
import { filterActiveReminders } from "@/lib/utils/reminders";

export function HomeContent() {
  const { ownedSummaries } = useCreatedEvents();
  const interaction = useInteractionStore();

  const resolveRSVP = (event: EventSummary): EventSummary => ({
    ...event,
    rsvpStatus: interaction.rsvpStatus(event.id, event.rsvpStatus),
    lastParticipatedAt: interaction.lastParticipatedAt(
      event.id,
      event.lastParticipatedAt
    ),
  });

  const invitedEvents = MOCK_INVITED_EVENTS.map(resolveRSVP);
  const createdEvents = ownedSummaries.map(resolveRSVP);

  const upcoming = [...createdEvents, ...invitedEvents]
    .filter((e) => e.isUpcoming)
    .sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());

  const defaultRsvpByEventId = useMemo(
    () =>
      Object.fromEntries(
        MOCK_INVITED_EVENTS.map((e) => [e.id, e.rsvpStatus])
      ),
    []
  );

  const reminders = useMemo(
    () =>
      filterActiveReminders(MOCK_REMINDERS, (eventId) =>
        interaction.rsvpStatus(
          eventId,
          defaultRsvpByEventId[eventId] ?? "yes"
        )
      ),
    [interaction, defaultRsvpByEventId]
  );

  return (
    <>
      <HomeHeader />
      <div className="space-y-10 pb-6">
        {createdEvents.length > 0 ? (
          <section className="space-y-3">
            <SectionHeader
              title="내가 만든 이벤트"
              trailing={`${createdEvents.length}개`}
            />
            <div className="space-y-3">
              {createdEvents.map((event) => (
                <EventCard key={event.id} event={event} variant="default" />
              ))}
            </div>
          </section>
        ) : null}

        <ReminderList reminders={reminders} />
        <UpcomingSection events={upcoming} />
        <RecentPhotos photos={MOCK_RECENT_PHOTOS} />
        <RecentParticipationSection events={invitedEvents} />
        <InvitedEventsSection events={invitedEvents} />
      </div>
    </>
  );
}
