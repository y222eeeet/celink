import Foundation
import Observation
import UIKit

@Observable
final class EventInteractionStore {
    static let shared = EventInteractionStore()

    private var rsvpOverrides: [String: RSVPStatus] = [:]
    private var addedGuestbook: [String: [GuestbookEntry]] = [:]
    private var addedPhotos: [String: [URL]] = [:]
    private var photoSocialState: [String: PhotoSocialState] = [:]
    private var lateArrivalTimes: [String: Date] = [:]
    private var ledgerByEvent: [String: [CelebrationLedgerEntry]] = [:]
    private var participantsByEvent: [String: [InvitedParticipantEntry]] = [:]
    private var privatePhotoKeysByEvent: [String: Set<String>] = [:]
    private var deletedPhotoKeysByEvent: [String: Set<String>] = [:]
    private var sentGiftEntries: [SentGiftEntry] = []
    private var withdrawnAmount: Int = 0

    private init() {
        seedSentGiftEntries()
    }

    // MARK: - Event access

    func eventDetail(id: String) -> EventDetail? {
        CreatedEventsStore.shared.detail(id: id) ?? MockData.eventDetail(id: id)
    }

    func ledgerEntries(for eventId: String) -> [CelebrationLedgerEntry] {
        if let existing = ledgerByEvent[eventId] {
            return existing
        }

        if eventId == "owned-birthday-1" {
            let seeded: [CelebrationLedgerEntry] = [
                .init(id: "ld-1", senderName: "엄마", relation: .family, amount: 100_000),
                .init(id: "ld-2", senderName: "민지", relation: .bestFriend, amount: 50_000),
                .init(id: "ld-3", senderName: "태훈", relation: .friend, amount: 30_000),
                .init(id: "ld-4", senderName: "수현 대리", relation: .coworker, amount: 50_000),
                .init(id: "ld-5", senderName: "건우", relation: .acquaintance, amount: 30_000),
                .init(id: "ld-6", senderName: "익명", relation: .etc, amount: 10_000),
            ]
            ledgerByEvent[eventId] = seeded
            return seeded
        }

        return []
    }

    func participantEntries(for eventId: String) -> [InvitedParticipantEntry] {
        if let existing = participantsByEvent[eventId] {
            return existing
        }

        if eventId == "owned-birthday-1" {
            let seeded: [InvitedParticipantEntry] = [
                .init(id: "pt-1", name: "엄마", relation: .family, rsvpStatus: .yes),
                .init(id: "pt-2", name: "아빠", relation: .family, rsvpStatus: .yes),
                .init(id: "pt-3", name: "민지", relation: .bestFriend, rsvpStatus: .yes),
                .init(id: "pt-4", name: "지은", relation: .bestFriend, rsvpStatus: .maybe),
                .init(id: "pt-5", name: "태훈", relation: .friend, rsvpStatus: .yes),
                .init(id: "pt-6", name: "승호", relation: .friend, rsvpStatus: .no),
                .init(id: "pt-7", name: "수현 대리", relation: .coworker, rsvpStatus: .pending),
                .init(id: "pt-8", name: "민석 과장", relation: .coworker, rsvpStatus: .yes),
                .init(id: "pt-9", name: "건우", relation: .acquaintance, rsvpStatus: .maybe),
                .init(id: "pt-10", name: "하늘", relation: .etc, rsvpStatus: .pending),
            ]
            participantsByEvent[eventId] = seeded
            return seeded
        }

        return []
    }

    func totalReceivedAmountForOwnedEvents() -> Int {
        CreatedEventsStore.shared.summaries
            .map(\.id)
            .flatMap { ledgerEntries(for: $0) }
            .reduce(0) { $0 + $1.amount }
    }

    func totalSentAmount() -> Int {
        sentGiftEntries.reduce(0) { $0 + $1.amount }
    }

    /// 받은 축하금 총액 - 보낸 축하금 총액
    func netLedgerAmountBeforeWithdraw() -> Int {
        totalReceivedAmountForOwnedEvents() - totalSentAmount()
    }

    /// 현재 장부 금액(출금 반영): (받은 - 보낸) - 누적 출금
    func currentLedgerAmount() -> Int {
        max(0, netLedgerAmountBeforeWithdraw() - withdrawnAmount)
    }

    func availableLedgerAmount() -> Int {
        currentLedgerAmount()
    }

    @discardableResult
    func withdrawFromLedger(_ amount: Int) -> Int {
        let validAmount = max(0, amount)
        let accepted = min(validAmount, availableLedgerAmount())
        withdrawnAmount += accepted
        return accepted
    }

    func receivedOverviewByOwnedEvent() -> [EventLedgerOverview] {
        CreatedEventsStore.shared.summaries.map { summary in
            let total = ledgerEntries(for: summary.id).reduce(0) { $0 + $1.amount }
            return EventLedgerOverview(
                id: summary.id,
                eventTitle: summary.title,
                amount: total
            )
        }
    }

    func sentGiftOverview() -> [SentGiftEntry] {
        sentGiftEntries
    }

    // MARK: - RSVP

    func rsvpStatus(for eventId: String, default defaultStatus: RSVPStatus) -> RSVPStatus {
        if let override = rsvpOverrides[eventId] {
            return override
        }
        return defaultStatus
    }

    func lateArrivalTime(for eventId: String) -> Date? {
        lateArrivalTimes[eventId]
    }

    func saveRSVP(eventId: String, status: RSVPStatus, lateArrivalTime: Date?) {
        rsvpOverrides[eventId] = status
        if status == .maybe, let lateArrivalTime {
            let rounded = DateRounding.toFiveMinuteInterval(lateArrivalTime)
            if let eventStart = eventDetail(id: eventId)?.summary.date {
                lateArrivalTimes[eventId] = max(rounded, DateRounding.toFiveMinuteInterval(eventStart))
            } else {
                lateArrivalTimes[eventId] = rounded
            }
        } else {
            lateArrivalTimes.removeValue(forKey: eventId)
        }
        CreatedEventsStore.shared.updateRSVP(eventId: eventId, status: status)
    }

    // MARK: - Guestbook

    func guestbookEntries(for eventId: String) -> [GuestbookEntry] {
        let base = eventDetail(id: eventId)?.guestbook ?? []
        let extra = addedGuestbook[eventId] ?? []
        return (extra + base).sorted { $0.createdAt > $1.createdAt }
    }

    @discardableResult
    func addGuestbookEntry(
        eventId: String,
        authorName: String,
        content: String,
        isPrivate: Bool
    ) -> GuestbookEntry? {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let name = authorName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? MockData.userName
            : authorName.trimmingCharacters(in: .whitespacesAndNewlines)

        let entry = GuestbookEntry(
            id: "gb-\(UUID().uuidString.prefix(8))",
            authorName: name,
            content: trimmed,
            isPrivate: isPrivate,
            createdAt: Date()
        )

        if CreatedEventsStore.shared.addGuestbookEntry(eventId: eventId, entry: entry) {
            return entry
        }

        addedGuestbook[eventId, default: []].insert(entry, at: 0)
        return entry
    }

    // MARK: - Photos

    func photoURLs(for eventId: String, includePrivate: Bool = true) -> [URL] {
        let base = eventDetail(id: eventId)?.photoURLs ?? []
        let extra = addedPhotos[eventId] ?? []
        let combined = extra + base

        let deleted = deletedPhotoKeysByEvent[eventId] ?? []
        let privateSet = privatePhotoKeysByEvent[eventId] ?? []

        return combined.filter { url in
            let key = photoKey(url)
            if deleted.contains(key) { return false }
            if !includePrivate && privateSet.contains(key) { return false }
            return true
        }
    }

    func isPhotoPrivate(eventId: String, photoURL: URL) -> Bool {
        (privatePhotoKeysByEvent[eventId] ?? []).contains(photoKey(photoURL))
    }

    func togglePhotoPrivacy(eventId: String, photoURL: URL) {
        let key = photoKey(photoURL)
        var set = privatePhotoKeysByEvent[eventId] ?? []
        if set.contains(key) {
            set.remove(key)
        } else {
            set.insert(key)
        }
        privatePhotoKeysByEvent[eventId] = set
    }

    @discardableResult
    func deletePhoto(eventId: String, photoURL: URL) -> Bool {
        if CreatedEventsStore.shared.removePhoto(eventId: eventId, url: photoURL) {
            return true
        }
        var deleted = deletedPhotoKeysByEvent[eventId] ?? []
        deleted.insert(photoKey(photoURL))
        deletedPhotoKeysByEvent[eventId] = deleted
        return true
    }

    func likeCount(for photoURL: URL) -> Int {
        socialState(for: photoURL).likeCount
    }

    func isLiked(for photoURL: URL) -> Bool {
        socialState(for: photoURL).isLiked
    }

    func comments(for photoURL: URL) -> [PhotoComment] {
        socialState(for: photoURL).comments
    }

    func toggleLike(for photoURL: URL) {
        let key = socialKey(for: photoURL)
        var state = socialState(for: photoURL)
        if state.isLiked {
            state.isLiked = false
            state.likeCount = max(0, state.likeCount - 1)
        } else {
            state.isLiked = true
            state.likeCount += 1
        }
        photoSocialState[key] = state
    }

    func addComment(photoURL: URL, content: String) {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let key = socialKey(for: photoURL)
        var state = socialState(for: photoURL)
        let comment = PhotoComment(
            id: "pc-\(UUID().uuidString.prefix(8))",
            authorName: MockData.userName,
            content: trimmed,
            createdAt: Date()
        )
        state.comments.insert(comment, at: 0)
        photoSocialState[key] = state
    }

    @discardableResult
    func addPhoto(eventId: String, imageData: Data) -> URL? {
        guard let url = saveAlbumImage(data: imageData, eventId: eventId) else { return nil }

        if CreatedEventsStore.shared.addPhoto(eventId: eventId, url: url) {
            return url
        }

        addedPhotos[eventId, default: []].insert(url, at: 0)
        return url
    }

    private func saveAlbumImage(data: Data, eventId: String) -> URL? {
        guard let image = UIImage(data: data) else { return nil }

        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("albums/\(eventId)", isDirectory: true)

        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let fileURL = directory.appendingPathComponent("\(UUID().uuidString.prefix(8)).jpg")
        guard let jpeg = image.jpegData(compressionQuality: 0.85) else { return nil }

        do {
            try jpeg.write(to: fileURL, options: .atomic)
            return fileURL
        } catch {
            return nil
        }
    }

    private func socialKey(for photoURL: URL) -> String {
        photoURL.absoluteString
    }

    private func photoKey(_ url: URL) -> String {
        url.absoluteString
    }

    private func socialState(for photoURL: URL) -> PhotoSocialState {
        let key = socialKey(for: photoURL)
        if let state = photoSocialState[key] {
            return state
        }
        let initial = PhotoSocialState(likeCount: 0, isLiked: false, comments: [])
        photoSocialState[key] = initial
        return initial
    }

    private func seedSentGiftEntries() {
        guard sentGiftEntries.isEmpty else { return }
        sentGiftEntries = [
            SentGiftEntry(id: "sg-1", eventId: "evt-2", eventTitle: "졸업 전시 — 빛의 결", amount: 30_000),
            SentGiftEntry(id: "sg-2", eventId: "evt-1", eventTitle: "민수 ♥ 지연 결혼식", amount: 50_000),
            SentGiftEntry(id: "sg-3", eventId: "evt-4", eventTitle: "봄밤 재즈 콘서트", amount: 10_000),
        ]
    }
}

struct PhotoComment: Identifiable, Hashable {
    let id: String
    let authorName: String
    let content: String
    let createdAt: Date
}

private struct PhotoSocialState {
    var likeCount: Int
    var isLiked: Bool
    var comments: [PhotoComment]
}

enum RelationType: String, CaseIterable, Hashable {
    case family = "가족"
    case bestFriend = "절친"
    case friend = "친구"
    case coworker = "회사동료"
    case acquaintance = "지인"
    case etc = "기타"
}

struct CelebrationLedgerEntry: Identifiable, Hashable {
    let id: String
    let senderName: String
    let relation: RelationType
    let amount: Int
}

struct InvitedParticipantEntry: Identifiable, Hashable {
    let id: String
    let name: String
    let relation: RelationType
    let rsvpStatus: RSVPStatus
}

struct EventLedgerOverview: Identifiable, Hashable {
    let id: String
    let eventTitle: String
    let amount: Int
}

struct SentGiftEntry: Identifiable, Hashable {
    let id: String
    let eventId: String
    let eventTitle: String
    let amount: Int
}
