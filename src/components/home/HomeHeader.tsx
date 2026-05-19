import { MOCK_USER } from "@/lib/mock/events";

function getGreeting(): string {
  const hour = new Date().getHours();
  if (hour < 12) return "좋은 아침이에요";
  if (hour < 18) return "좋은 오후예요";
  return "좋은 저녁이에요";
}

export function HomeHeader() {
  return (
    <header className="px-5 pt-12 pb-6">
      <p className="text-sm text-ink-muted">{getGreeting()}</p>
      <h1 className="font-serif text-3xl font-medium tracking-tight text-ink">
        {MOCK_USER.name}님
      </h1>
      <p className="mt-2 text-sm leading-relaxed text-ink-muted">
        소중한 순간에 초대받은 이벤트를 모아봤어요
      </p>
    </header>
  );
}
