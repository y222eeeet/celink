import { EventDetailPage } from "@/components/event/EventDetailPage";

interface Props {
  params: Promise<{ eventId: string }>;
}

export default async function EventPage({ params }: Props) {
  const { eventId } = await params;
  return <EventDetailPage eventId={eventId} />;
}
