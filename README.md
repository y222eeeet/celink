# Celink

관계 기반 이벤트 초대 및 아카이빙 플랫폼 (MVP)

## iOS (Xcode) — 권장

1. `celink/celink.xcodeproj` 를 Xcode로 엽니다.
2. 시뮬레이터 또는 기기에서 **Run** (⌘R).

Home 화면·하단 탭(홈·만들기·프로필)이 SwiftUI로 구현되어 있습니다.

## Web (Next.js)

```bash
npm install
npm run dev
```

[http://localhost:3000](http://localhost:3000) 에서 확인합니다.

## 현재 구현

- **Home** — 리마인더, 다가오는 이벤트, 최근 업로드, 최근 참여, 초대받은 이벤트 목록
- 하단 탭: 홈 · 만들기 · 프로필 (만들기/프로필은 플레이스홀더)
- 이벤트 카드 탭 시 상세 플레이스홀더 (`/events/[id]`)

## 스택

- Next.js 15 (App Router)
- TypeScript
- Tailwind CSS v4
