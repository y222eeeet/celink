import { EventRSVPPage } from "@/components/event/EventRSVPPage";

interface Props {
  params: Promise<{ eventId: string }>;
}

export default async function EventRSVPRoute({ params }: Props) {
  const { eventId } = await params;
  return <EventRSVPPage eventId={eventId} />;
}
