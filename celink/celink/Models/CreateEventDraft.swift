import Foundation

struct EditableScheduleItem: Identifiable, Hashable {
    let id: String
    var time: Date
    var title: String
    var note: String

    init(
        id: String = UUID().uuidString,
        time: Date = Date(),
        title: String = "",
        note: String = ""
    ) {
        self.id = id
        self.time = time
        self.title = title
        self.note = note
    }
}

enum CreateEventStep: Int, CaseIterable {
    case type
    case basics
    case cover
    case schedule
    case preview

    var title: String {
        switch self {
        case .type: "이벤트 타입"
        case .basics: "기본 정보"
        case .cover: "대표 이미지"
        case .schedule: "프로그램 식순"
        case .preview: "미리보기"
        }
    }
}

enum CreateEventDraft {
    static func defaultCoverURL(for type: EventType) -> URL {
        let string: String = switch type {
        case .wedding:
            "https://images.unsplash.com/photo-1519741497674-611481863552?w=800&q=80"
        case .exhibition:
            "https://images.unsplash.com/photo-1460661414737-f969d6ae3b70?w=800&q=80"
        case .performance:
            "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&q=80"
        case .dol:
            "https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=800&q=80"
        }
        return URL(string: string)!
    }
}
