import Foundation
import Observation
import UIKit

@Observable
final class CreatedEventsStore {
    static let shared = CreatedEventsStore()

    private(set) var events: [EventDetail] = []

    var summaries: [EventSummary] {
        events.map(\.summary).sorted { $0.date < $1.date }
    }

    private init() {}

    func isOwned(eventId: String) -> Bool {
        events.contains { $0.id == eventId }
    }

    func detail(id: String) -> EventDetail? {
        events.first { $0.id == id }
    }

    @discardableResult
    func publish(
        type: EventType,
        title: String,
        date: Date,
        location: String,
        description: String,
        dressCode: String?,
        notice: String?,
        coverImageData: Data?,
        coverImageChanged: Bool = true,
        existingCoverURL: URL? = nil,
        scheduleItems: [EditableScheduleItem]
    ) -> EventDetail {
        let eventId = "evt-\(UUID().uuidString.prefix(8))"
        let coverURL = resolveCoverURL(
            eventId: eventId,
            type: type,
            coverImageData: coverImageData,
            coverImageChanged: coverImageChanged,
            existingCoverURL: existingCoverURL
        )

        let detail = buildDetail(
            eventId: eventId,
            type: type,
            title: title,
            date: date,
            location: location,
            description: description,
            dressCode: dressCode,
            notice: notice,
            coverURL: coverURL,
            scheduleItems: scheduleItems,
            guestbook: [],
            photoURLs: []
        )

        events.insert(detail, at: 0)
        return detail
    }

    @discardableResult
    func update(
        eventId: String,
        type: EventType,
        title: String,
        date: Date,
        location: String,
        description: String,
        dressCode: String?,
        notice: String?,
        coverImageData: Data?,
        coverImageChanged: Bool,
        scheduleItems: [EditableScheduleItem]
    ) -> EventDetail? {
        guard let index = events.firstIndex(where: { $0.id == eventId }) else { return nil }

        let existing = events[index]
        let coverURL = resolveCoverURL(
            eventId: eventId,
            type: type,
            coverImageData: coverImageData,
            coverImageChanged: coverImageChanged,
            existingCoverURL: existing.summary.coverImageURL
        )

        let updated = buildDetail(
            eventId: eventId,
            type: type,
            title: title,
            date: date,
            location: location,
            description: description,
            dressCode: dressCode,
            notice: notice,
            coverURL: coverURL,
            scheduleItems: scheduleItems,
            guestbook: existing.guestbook,
            photoURLs: existing.photoURLs
        )

        events[index] = updated
        return updated
    }

    func invitePath(for eventId: String) -> String {
        "/i/\(eventId)"
    }

    func updateRSVP(eventId: String, status: RSVPStatus) {
        guard let index = events.firstIndex(where: { $0.id == eventId }) else { return }
        let existing = events[index]
        let summary = EventSummary(
            id: existing.summary.id,
            type: existing.summary.type,
            title: existing.summary.title,
            date: existing.summary.date,
            location: existing.summary.location,
            coverImageURL: existing.summary.coverImageURL,
            hostName: existing.summary.hostName,
            rsvpStatus: status,
            lastParticipatedAt: existing.summary.lastParticipatedAt,
            isUpcoming: existing.summary.isUpcoming
        )
        events[index] = EventDetail(
            summary: summary,
            description: existing.description,
            dressCode: existing.dressCode,
            notice: existing.notice,
            schedule: existing.schedule,
            guestbook: existing.guestbook,
            photoURLs: existing.photoURLs
        )
    }

    @discardableResult
    func addGuestbookEntry(eventId: String, entry: GuestbookEntry) -> Bool {
        guard let index = events.firstIndex(where: { $0.id == eventId }) else { return false }
        let existing = events[index]
        var guestbook = existing.guestbook
        guestbook.insert(entry, at: 0)
        events[index] = EventDetail(
            summary: existing.summary,
            description: existing.description,
            dressCode: existing.dressCode,
            notice: existing.notice,
            schedule: existing.schedule,
            guestbook: guestbook,
            photoURLs: existing.photoURLs
        )
        return true
    }

    @discardableResult
    func addPhoto(eventId: String, url: URL) -> Bool {
        guard let index = events.firstIndex(where: { $0.id == eventId }) else { return false }
        let existing = events[index]
        var photos = existing.photoURLs
        photos.insert(url, at: 0)
        events[index] = EventDetail(
            summary: existing.summary,
            description: existing.description,
            dressCode: existing.dressCode,
            notice: existing.notice,
            schedule: existing.schedule,
            guestbook: existing.guestbook,
            photoURLs: photos
        )
        return true
    }

    private func buildDetail(
        eventId: String,
        type: EventType,
        title: String,
        date: Date,
        location: String,
        description: String,
        dressCode: String?,
        notice: String?,
        coverURL: URL,
        scheduleItems: [EditableScheduleItem],
        guestbook: [GuestbookEntry],
        photoURLs: [URL]
    ) -> EventDetail {
        let schedule = scheduleItems
            .filter { !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .map {
                ScheduleItem(
                    id: $0.id,
                    time: $0.time,
                    title: $0.title.trimmingCharacters(in: .whitespacesAndNewlines),
                    note: $0.note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        ? nil
                        : $0.note.trimmingCharacters(in: .whitespacesAndNewlines)
                )
            }

        let summary = EventSummary(
            id: eventId,
            type: type,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            date: date,
            location: location.trimmingCharacters(in: .whitespacesAndNewlines),
            coverImageURL: coverURL,
            hostName: MockData.userName,
            rsvpStatus: .yes,
            lastParticipatedAt: nil,
            isUpcoming: date >= Calendar.current.startOfDay(for: Date())
        )

        return EventDetail(
            summary: summary,
            description: description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? "\(EventLabels.typeName(type))에 초대합니다."
                : description.trimmingCharacters(in: .whitespacesAndNewlines),
            dressCode: dressCode?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
                ? dressCode?.trimmingCharacters(in: .whitespacesAndNewlines)
                : nil,
            notice: notice?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
                ? notice?.trimmingCharacters(in: .whitespacesAndNewlines)
                : nil,
            schedule: schedule,
            guestbook: guestbook,
            photoURLs: photoURLs
        )
    }

    private func resolveCoverURL(
        eventId: String,
        type: EventType,
        coverImageData: Data?,
        coverImageChanged: Bool,
        existingCoverURL: URL?
    ) -> URL {
        if let coverImageData,
           let saved = saveCoverImage(data: coverImageData, eventId: eventId) {
            return saved
        }

        if coverImageChanged {
            return CreateEventDraft.defaultCoverURL(for: type)
        }

        if let existingCoverURL {
            return existingCoverURL
        }

        return CreateEventDraft.defaultCoverURL(for: type)
    }

    private func saveCoverImage(data: Data, eventId: String) -> URL? {
        guard let image = UIImage(data: data) else { return nil }

        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("covers", isDirectory: true)

        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let fileURL = directory.appendingPathComponent("\(eventId).jpg")
        guard let jpeg = image.jpegData(compressionQuality: 0.85) else { return nil }

        do {
            try jpeg.write(to: fileURL, options: .atomic)
            return fileURL
        } catch {
            return nil
        }
    }
}
