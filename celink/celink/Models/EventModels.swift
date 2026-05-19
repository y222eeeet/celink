import Foundation

enum EventType: String, CaseIterable, Hashable {
    case wedding, exhibition, performance, dol
}

enum RSVPStatus: String, Hashable {
    case pending, yes, no, maybe
}

struct EventSummary: Identifiable, Hashable {
    let id: String
    let type: EventType
    let title: String
    let date: Date
    let location: String
    let coverImageURL: URL
    let hostName: String
    let rsvpStatus: RSVPStatus
    let lastParticipatedAt: Date?
    let isUpcoming: Bool

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: EventSummary, rhs: EventSummary) -> Bool {
        lhs.id == rhs.id
    }
}

struct ScheduleItem: Identifiable, Hashable {
    let id: String
    let time: Date
    let title: String
    let note: String?
}

struct GuestbookEntry: Identifiable, Hashable {
    let id: String
    let authorName: String
    let content: String
    let isPrivate: Bool
    let createdAt: Date
}

struct EventDetail: Identifiable {
    var id: String { summary.id }
    let summary: EventSummary
    let description: String
    let dressCode: String?
    let notice: String?
    let schedule: [ScheduleItem]
    let guestbook: [GuestbookEntry]
    let photoURLs: [URL]
}

struct RecentPhoto: Identifiable {
    let id: String
    let eventId: String
    let eventTitle: String
    let imageURL: URL
    let uploadedAt: Date
}

struct Reminder: Identifiable {
    let id: String
    let eventId: String
    let eventTitle: String
    let message: String
}
