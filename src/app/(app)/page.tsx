import { HomeHeader } from "@/components/home/HomeHeader";
import { InvitedEventsSection } from "@/components/home/InvitedEventsSection";
import { RecentParticipationSection } from "@/components/home/RecentParticipationSection";
import { RecentPhotos } from "@/components/home/RecentPhotos";
import { ReminderList } from "@/components/home/ReminderList";
import { UpcomingSection } from "@/components/home/UpcomingSection";
import {
  MOCK_INVITED_EVENTS,
  MOCK_RECENT_PHOTOS,
  MOCK_REMINDERS,
} from "@/lib/mock/events";

export default function HomePage() {
  return (
    <>
      <HomeHeader />
      <div className="space-y-10 pb-6">
        <ReminderList reminders={MOCK_REMINDERS} />
        <UpcomingSection events={MOCK_INVITED_EVENTS} />
        <RecentPhotos photos={MOCK_RECENT_PHOTOS} />
        <RecentParticipationSection events={MOCK_INVITED_EVENTS} />
        <InvitedEventsSection events={MOCK_INVITED_EVENTS} />
      </div>
    </>
  );
}
