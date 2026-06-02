import { EventEditPage } from "@/components/event/EventEditPage";

interface Props {
  params: Promise<{ eventId: string }>;
}

export default async function EventEditRoute({ params }: Props) {
  const { eventId } = await params;
  return <EventEditPage eventId={eventId} />;
}
