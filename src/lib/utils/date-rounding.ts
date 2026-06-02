const FIVE_MINUTES_MS = 5 * 60 * 1000;

export function toFiveMinuteInterval(date: Date): Date {
  const rounded = new Date(date);
  const ms = rounded.getTime();
  rounded.setTime(Math.round(ms / FIVE_MINUTES_MS) * FIVE_MINUTES_MS);
  rounded.setSeconds(0, 0);
  return rounded;
}

export function mergeDateAndTime(day: Date, time: Date): Date {
  const merged = new Date(day);
  merged.setHours(time.getHours(), time.getMinutes(), 0, 0);
  return toFiveMinuteInterval(merged);
}

export function toLocalISOString(date: Date): string {
  const pad = (n: number) => String(n).padStart(2, "0");
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}T${pad(date.getHours())}:${pad(date.getMinutes())}:00`;
}
