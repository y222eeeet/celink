import type { Reminder, RSVPStatus } from "@/lib/types";

/** RSVP 미확정 상태일 때만 리마인더 표시 */
const RSVP_NEEDS_REMINDER: RSVPStatus[] = ["pending", "maybe"];

export function filterActiveReminders(
  reminders: Reminder[],
  resolveStatus: (eventId: string) => RSVPStatus
): Reminder[] {
  return reminders.filter((r) =>
    RSVP_NEEDS_REMINDER.includes(resolveStatus(r.eventId))
  );
}
