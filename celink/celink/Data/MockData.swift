import Foundation

enum MockData {
    static let userName = "서지우"

    private static let formatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    /// "2026-05-25T12:00:00" 같이 timezone 없는 더미 문자열 파싱용
    private static let localFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.timeZone = TimeZone.current
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return f
    }()

    private static func date(_ string: String) -> Date {
        if let isoDate = formatter.date(from: string) {
            return isoDate
        }
        if let localDate = localFormatter.date(from: string) {
            return localDate
        }
        return Date()
    }

    private static func url(_ string: String) -> URL {
        URL(string: string)!
    }

    static let invitedEvents: [EventSummary] = eventDetails.map(\.summary)

    static let eventDetails: [EventDetail] = [
        EventDetail(
            summary: EventSummary(
                id: "evt-1",
                type: .wedding,
                title: "민수 ♥ 지연 결혼식",
                date: date("2026-06-14T10:30:00"),
                location: "서울 신라호텔",
                coverImageURL: url("https://images.unsplash.com/photo-1519741497674-611481863552?w=800&q=80"),
                hostName: "김민수",
                rsvpStatus: .yes,
                lastParticipatedAt: date("2026-05-10T14:30:00"),
                isUpcoming: true
            ),
            description: "두 사람의 새로운 시작을 함께 축복해 주세요. 따뜻한 마음으로 참석해 주시면 감사하겠습니다.",
            dressCode: "포멀 · 남색·베이지 계열 권장",
            notice: "화환은 정중히 사양합니다. 식사 RSVP에 동반 인원을 꼭 적어 주세요.",
            schedule: [
                ScheduleItem(id: "s1-1", time: date("2026-06-14T10:30:00"), title: "하객 입장", note: nil),
                ScheduleItem(id: "s1-2", time: date("2026-06-14T11:00:00"), title: "본식 시작", note: nil),
                ScheduleItem(id: "s1-3", time: date("2026-06-14T11:10:00"), title: "신랑 입장", note: nil),
                ScheduleItem(id: "s1-4", time: date("2026-06-14T11:20:00"), title: "신부 입장", note: nil),
                ScheduleItem(id: "s1-5", time: date("2026-06-14T11:30:00"), title: "신랑신부 행진", note: nil),
                ScheduleItem(id: "s1-6", time: date("2026-06-14T11:40:00"), title: "하객사진 촬영", note: nil),
            ],
            guestbook: [
                GuestbookEntry(id: "g1-1", authorName: "박지훈", content: "결혼 진심으로 축하해! 행복만 가득하길.", isPrivate: false, createdAt: date("2026-05-10T14:30:00")),
                GuestbookEntry(id: "g1-2", authorName: "이수민", content: "두 분 앞날에 항상 웃음이 가득하길 바라요.", isPrivate: false, createdAt: date("2026-05-09T11:00:00")),
                GuestbookEntry(id: "g1-3", authorName: "익명", content: "멀리서 응원합니다. 꼭 참석할게요!", isPrivate: true, createdAt: date("2026-05-08T20:00:00")),
            ],
            photoURLs: [
                url("https://images.unsplash.com/photo-1465495976277-812eacf5aee6?w=400&q=80"),
                url("https://images.unsplash.com/photo-1519741497674-611481863552?w=400&q=80"),
                url("https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=400&q=80"),
            ]
        ),
        EventDetail(
            summary: EventSummary(
                id: "evt-2",
                type: .exhibition,
                title: "졸업 전시 — 빛의 결",
                date: date("2026-05-25T12:00:00"),
                location: "홍익대학교 현대미술관",
                coverImageURL: url("https://images.unsplash.com/photo-1460661414737-f969d6ae3b70?w=800&q=80"),
                hostName: "이하은",
                rsvpStatus: .maybe,
                lastParticipatedAt: date("2026-05-12T18:00:00"),
                isUpcoming: true
            ),
            description: "4년간의 작업을 모은 졸업 전시입니다. 빛과 그림자의 경계를 탐구한 설치·회화 작품을 만나보세요.",
            dressCode: nil,
            notice: "전시장 내 플래시 촬영은 삼가 주세요.",
            schedule: [
                ScheduleItem(id: "s2-1", time: date("2026-05-25T12:10:00"), title: "오프닝 이벤트", note: "1층 로비"),
                ScheduleItem(id: "s2-2", time: date("2026-05-25T12:20:00"), title: "작가 토크", note: "세미나실"),
                ScheduleItem(id: "s2-3", time: date("2026-05-25T13:00:00"), title: "자유 관람", note: "2층 전시실"),
            ],
            guestbook: [
                GuestbookEntry(id: "g2-1", authorName: "교수님", content: "졸업 축하한다. 전시 너무 기대돼.", isPrivate: false, createdAt: date("2026-05-12T18:00:00")),
                GuestbookEntry(id: "g2-2", authorName: "동기 민지", content: "오프닝날 꼭 갈게! 고생 많았어.", isPrivate: false, createdAt: date("2026-05-11T09:30:00")),
            ],
            photoURLs: [
                url("https://images.unsplash.com/photo-1578301978693-85fa9c0320f9?w=400&q=80"),
                url("https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=400&q=80"),
            ]
        ),
        EventDetail(
            summary: EventSummary(
                id: "evt-3",
                type: .dol,
                title: "도윤이 첫 번째 생일",
                date: date("2026-03-08T11:30:00"),
                location: "판교 파티룸",
                coverImageURL: url("https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=800&q=80"),
                hostName: "박서연",
                rsvpStatus: .yes,
                lastParticipatedAt: date("2026-03-08T16:45:00"),
                isUpcoming: false
            ),
            description: "우리 도윤이 첫 돌을 가족과 지인분들과 함께 나누고 싶습니다.",
            dressCode: "캐주얼",
            notice: nil,
            schedule: [
                ScheduleItem(id: "s3-1", time: date("2026-03-08T11:30:00"), title: "입장 · 포토존", note: nil),
                ScheduleItem(id: "s3-2", time: date("2026-03-08T12:00:00"), title: "돌잡이", note: nil),
                ScheduleItem(id: "s3-3", time: date("2026-03-08T12:20:00"), title: "케이크 커팅", note: nil),
            ],
            guestbook: [
                GuestbookEntry(id: "g3-1", authorName: "이모", content: "도윤아 생일 축하해! 건강하게 자라렴.", isPrivate: false, createdAt: date("2026-03-08T16:45:00")),
            ],
            photoURLs: [
                url("https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80"),
            ]
        ),
        EventDetail(
            summary: EventSummary(
                id: "evt-4",
                type: .performance,
                title: "봄밤 재즈 콘서트",
                date: date("2026-07-20T20:00:00"),
                location: "블루스퀘어",
                coverImageURL: url("https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&q=80"),
                hostName: "최예린",
                rsvpStatus: .pending,
                lastParticipatedAt: nil,
                isUpcoming: true
            ),
            description: "여름밤 재즈 라이브에 초대합니다. 밴드 'Moonlight Quartet'의 특별 공연입니다.",
            dressCode: "스마트 캐주얼",
            notice: "공연 시작 30분 전 착석을 권장합니다.",
            schedule: [
                ScheduleItem(id: "s4-1", time: date("2026-07-20T19:40:00"), title: "입장 시작", note: nil),
                ScheduleItem(id: "s4-2", time: date("2026-07-20T20:00:00"), title: "공연 1부 시작", note: nil),
                ScheduleItem(id: "s4-3", time: date("2026-07-20T20:40:00"), title: "공연 2부 시작", note: nil),
            ],
            guestbook: [],
            photoURLs: []
        ),
    ]

    static func eventDetail(id: String) -> EventDetail? {
        CreatedEventsStore.shared.detail(id: id)
            ?? eventDetails.first { $0.id == id }
    }

    static let recentPhotos: [RecentPhoto] = [
        RecentPhoto(
            id: "ph-1",
            eventId: "evt-2",
            eventTitle: "졸업 전시 — 빛의 결",
            imageURL: url("https://images.unsplash.com/photo-1578301978693-85fa9c0320f9?w=400&q=80"),
            uploadedAt: date("2026-05-12T17:55:00")
        ),
        RecentPhoto(
            id: "ph-2",
            eventId: "evt-1",
            eventTitle: "민수 ♥ 지연 결혼식",
            imageURL: url("https://images.unsplash.com/photo-1465495976277-812eacf5aee6?w=400&q=80"),
            uploadedAt: date("2026-05-10T14:20:00")
        ),
        RecentPhoto(
            id: "ph-3",
            eventId: "evt-2",
            eventTitle: "졸업 전시 — 빛의 결",
            imageURL: url("https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=400&q=80"),
            uploadedAt: date("2026-05-12T16:10:00")
        ),
        RecentPhoto(
            id: "ph-4",
            eventId: "evt-3",
            eventTitle: "도윤이 첫 번째 생일",
            imageURL: url("https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80"),
            uploadedAt: date("2026-03-08T15:30:00")
        ),
    ]

    static let reminders: [Reminder] = [
        Reminder(
            id: "rem-1",
            eventId: "evt-2",
            eventTitle: "졸업 전시 — 빛의 결",
            message: "전시 오픈 D-3 · RSVP를 아직 확정하지 않았어요"
        ),
        Reminder(
            id: "rem-2",
            eventId: "evt-4",
            eventTitle: "봄밤 재즈 콘서트",
            message: "참석 여부를 알려주세요"
        ),
    ]
}
