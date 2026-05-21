import Foundation
import Observation

enum EventFormMode {
    case create
    case edit(eventId: String)
}

@Observable
final class EventFormViewModel {
    let mode: EventFormMode

    var step: CreateEventStep = .type
    var selectedType: EventType?
    var title = ""
    var date = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
    var location = ""
    var description = ""
    var dressCode = ""
    var notice = ""
    var coverImageData: Data?
    var existingCoverURL: URL?
    var coverImageChanged = false
    var scheduleItems: [EditableScheduleItem] = []

    var publishedEventId: String?
    var showSuccessSheet = false
    var lastInvitePath = ""
    /// 생성 완료 후 만들기 탭 재진입 시 폼을 비울지 여부
    var pendingResetOnNextAppear = false

    var isEditMode: Bool {
        if case .edit = mode { return true }
        return false
    }

    var editingEventId: String? {
        if case .edit(let id) = mode { return id }
        return nil
    }

    var stepIndex: Int { step.rawValue }
    var totalSteps: Int { CreateEventStep.allCases.count }

    var screenTitle: String {
        isEditMode ? "이벤트 수정" : "이벤트 만들기"
    }

    var screenSubtitle: String {
        isEditMode
            ? "변경 내용은 초대 페이지에 바로 반영돼요"
            : "초대 링크 하나로 축하와 추억을 모아보세요"
    }

    var previewFootnote: String {
        isEditMode ? "저장하면 참여자에게도 업데이트돼요" : "발행 후 초대 링크를 공유할 수 있어요"
    }

    var successTitle: String {
        isEditMode ? "변경 사항이 저장됐어요" : "이벤트가 발행됐어요"
    }

    var canGoNext: Bool {
        switch step {
        case .type:
            selectedType != nil
        case .basics:
            !trimmed(title).isEmpty && !trimmed(location).isEmpty
        case .cover, .schedule, .preview:
            true
        }
    }

    var nextButtonTitle: String {
        switch step {
        case .preview:
            isEditMode ? "저장하기" : "이벤트 발행하기"
        default:
            "다음"
        }
    }

    init(mode: EventFormMode = .create) {
        self.mode = mode
        if case .edit(let eventId) = mode {
            loadForEdit(eventId: eventId)
        }
    }

    func selectType(_ type: EventType) {
        selectedType = type
    }

    func goNext() {
        guard canGoNext else { return }

        if step == .preview {
            submit()
            return
        }

        if let next = CreateEventStep(rawValue: step.rawValue + 1) {
            if next == .schedule, scheduleItems.isEmpty, let selectedType {
                scheduleItems = [EditableScheduleItem(time: date, title: defaultScheduleTitle(for: selectedType))]
            }
            step = next
        }
    }

    func goBack() {
        guard let previous = CreateEventStep(rawValue: step.rawValue - 1) else { return }
        step = previous
    }

    func addScheduleItem() {
        scheduleItems.append(EditableScheduleItem(time: date))
    }

    func removeScheduleItem(id: String) {
        scheduleItems.removeAll { $0.id == id }
    }

    func markCoverChanged(data: Data?) {
        coverImageData = data
        coverImageChanged = true
    }

    func resetCoverToDefault() {
        coverImageData = nil
        existingCoverURL = nil
        coverImageChanged = true
    }

    func reset() {
        step = .type
        selectedType = nil
        title = ""
        date = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        location = ""
        description = ""
        dressCode = ""
        notice = ""
        coverImageData = nil
        existingCoverURL = nil
        coverImageChanged = false
        scheduleItems = []
        publishedEventId = nil
        showSuccessSheet = false
        lastInvitePath = ""
        pendingResetOnNextAppear = false
    }

    /// 만들기 탭에 다시 들어왔을 때 호출. 초기화가 필요하면 `true` 반환.
    @discardableResult
    func consumePendingReset() -> Bool {
        guard pendingResetOnNextAppear else { return false }
        reset()
        return true
    }

    private func loadForEdit(eventId: String) {
        guard let detail = CreatedEventsStore.shared.detail(id: eventId) else { return }

        let event = detail.summary
        selectedType = event.type
        title = event.title
        date = event.date
        location = event.location
        description = detail.description
        dressCode = detail.dressCode ?? ""
        notice = detail.notice ?? ""
        existingCoverURL = event.coverImageURL
        coverImageData = nil
        coverImageChanged = false
        scheduleItems = detail.schedule.map {
            EditableScheduleItem(
                id: $0.id,
                time: $0.time,
                title: $0.title,
                note: $0.note ?? ""
            )
        }
        step = .basics
    }

    private func submit() {
        guard let selectedType else { return }

        switch mode {
        case .create:
            let detail = CreatedEventsStore.shared.publish(
                type: selectedType,
                title: title,
                date: date,
                location: location,
                description: description,
                dressCode: dressCode.isEmpty ? nil : dressCode,
                notice: notice.isEmpty ? nil : notice,
                coverImageData: coverImageData,
                coverImageChanged: coverImageChanged,
                existingCoverURL: nil,
                scheduleItems: scheduleItems
            )
            publishedEventId = detail.id
            lastInvitePath = CreatedEventsStore.shared.invitePath(for: detail.id)
            pendingResetOnNextAppear = true
            showSuccessSheet = true

        case .edit(let eventId):
            guard CreatedEventsStore.shared.update(
                eventId: eventId,
                type: selectedType,
                title: title,
                date: date,
                location: location,
                description: description,
                dressCode: dressCode.isEmpty ? nil : dressCode,
                notice: notice.isEmpty ? nil : notice,
                coverImageData: coverImageData,
                coverImageChanged: coverImageChanged,
                scheduleItems: scheduleItems
            ) != nil else { return }

            publishedEventId = eventId
            lastInvitePath = CreatedEventsStore.shared.invitePath(for: eventId)
            showSuccessSheet = true
        }
    }

    private func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func defaultScheduleTitle(for type: EventType) -> String {
        switch type {
        case .wedding: "예식"
        case .exhibition: "전시 오픈"
        case .performance: "공연 시작"
        case .dol: "돌잔치 식순"
        }
    }
}
