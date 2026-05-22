import Foundation
import Observation
import UIKit

@Observable
final class EventInteractionStore {
    static let shared = EventInteractionStore()

    private var rsvpOverrides: [String: RSVPStatus] = [:]
    private var addedGuestbook: [String: [GuestbookEntry]] = [:]
    private var addedPhotos: [String: [URL]] = [:]
    private var rsvpNotes: [String: String] = [:]
    private var guestCounts: [String: Int] = [:]

    private init() {}

    // MARK: - Event access

    func eventDetail(id: String) -> EventDetail? {
        CreatedEventsStore.shared.detail(id: id) ?? MockData.eventDetail(id: id)
    }

    // MARK: - RSVP

    func rsvpStatus(for eventId: String, default defaultStatus: RSVPStatus) -> RSVPStatus {
        if let override = rsvpOverrides[eventId] {
            return override
        }
        return defaultStatus
    }

    func rsvpNote(for eventId: String) -> String {
        rsvpNotes[eventId] ?? ""
    }

    func guestCount(for eventId: String) -> Int {
        let count = guestCounts[eventId] ?? 1
        return max(1, min(count, 10))
    }

    func saveRSVP(eventId: String, status: RSVPStatus, guestCount: Int, note: String) {
        rsvpOverrides[eventId] = status
        guestCounts[eventId] = max(1, min(guestCount, 10))
        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            rsvpNotes.removeValue(forKey: eventId)
        } else {
            rsvpNotes[eventId] = trimmed
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

    func photoURLs(for eventId: String) -> [URL] {
        let base = eventDetail(id: eventId)?.photoURLs ?? []
        let extra = addedPhotos[eventId] ?? []
        return extra + base
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
}
