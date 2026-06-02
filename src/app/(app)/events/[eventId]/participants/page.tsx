import { EventParticipantsPage } from "@/components/event/EventParticipantsPage";

export const dynamic = "force-dynamic";

interface Props {
  params: Promise<{ eventId: string }>;
}

export default async function EventParticipantsRoute({ params }: Props) {
  const { eventId } = await params;
  return <EventParticipantsPage eventId={eventId} />;
}
