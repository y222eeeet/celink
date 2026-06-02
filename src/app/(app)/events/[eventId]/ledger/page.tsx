import { EventLedgerPage } from "@/components/event/EventLedgerPage";

interface Props {
  params: Promise<{ eventId: string }>;
}

export default async function EventLedgerRoute({ params }: Props) {
  const { eventId } = await params;
  return <EventLedgerPage eventId={eventId} />;
}
