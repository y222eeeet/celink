import { EventAlbumPage } from "@/components/event/EventAlbumPage";

interface Props {
  params: Promise<{ eventId: string }>;
}

export default async function EventAlbumRoute({ params }: Props) {
  const { eventId } = await params;
  return <EventAlbumPage eventId={eventId} />;
}
