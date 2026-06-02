import { EventEditPage } from "@/components/event/EventEditPage";

export const dynamic = "force-dynamic";

interface Props {
  params: Promise<{ eventId: string }>;
}

export default async function EventEditRoute({ params }: Props) {
  const { eventId } = await params;
  return <EventEditPage eventId={eventId} />;
}
