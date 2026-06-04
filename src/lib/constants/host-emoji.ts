/** 주최자 AI 아바타 이모티콘 — 지우의 생일파티 전용 (MVP) */
export const HOST_EMOJI_EVENT_ID = "owned-birthday-1";

export interface HostEmojiSticker {
  id: string;
  label: string;
  imageUrl: string;
}

export const HOST_EMOJI_STICKERS: HostEmojiSticker[] = [
  {
    id: "cheer",
    label: "응원",
    imageUrl: "/images/emojis/owned-birthday-1/cheer.png",
  },
  {
    id: "laugh",
    label: "ㅋㅋ",
    imageUrl: "/images/emojis/owned-birthday-1/laugh.png",
  },
  {
    id: "crying",
    label: "눈물",
    imageUrl: "/images/emojis/owned-birthday-1/crying.png",
  },
  {
    id: "angry",
    label: "화남",
    imageUrl: "/images/emojis/owned-birthday-1/angry.png",
  },
  {
    id: "love",
    label: "하트",
    imageUrl: "/images/emojis/owned-birthday-1/love.png",
  },
];

export function isHostEmojiEvent(eventId: string): boolean {
  return eventId === HOST_EMOJI_EVENT_ID;
}

export function getHostEmojiSticker(stickerId: string): HostEmojiSticker | undefined {
  return HOST_EMOJI_STICKERS.find((s) => s.id === stickerId);
}
