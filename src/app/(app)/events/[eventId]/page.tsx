import { EventDetailPage } from "@/components/event/EventDetailPage";

export const dynamic = "force-dynamic";

interface Props {
  params: Promise<{ eventId: string }>;
}

export default async function EventPage({ params }: Props) {
  const { eventId } = await params;
  return <EventDetailPage eventId={eventId} />;
}
