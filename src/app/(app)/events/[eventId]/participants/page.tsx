import { EventParticipantsPage } from "@/components/event/EventParticipantsPage";

interface Props {
  params: Promise<{ eventId: string }>;
}

export default async function EventParticipantsRoute({ params }: Props) {
  const { eventId } = await params;
  return <EventParticipantsPage eventId={eventId} />;
}
