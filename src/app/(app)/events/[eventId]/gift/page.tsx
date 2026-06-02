import { EventGiftPage } from "@/components/event/EventGiftPage";

export const dynamic = "force-dynamic";

interface Props {
  params: Promise<{ eventId: string }>;
}

export default async function EventGiftRoute({ params }: Props) {
  const { eventId } = await params;
  return <EventGiftPage eventId={eventId} />;
}
