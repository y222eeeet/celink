import { EventGuestbookPage } from "@/components/event/EventGuestbookPage";

export const dynamic = "force-dynamic";

interface Props {
  params: Promise<{ eventId: string }>;
}

export default async function EventGuestbookRoute({ params }: Props) {
  const { eventId } = await params;
  return <EventGuestbookPage eventId={eventId} />;
}
