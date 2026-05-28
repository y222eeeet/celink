import SwiftUI

struct EventRSVPView: View {
    let eventId: String
    @Environment(\.dismiss) private var dismiss
    @Bindable private var interactionStore = EventInteractionStore.shared

    @State private var selectedStatus: RSVPStatus = .pending
    @State private var lateArrival = Date()
    @State private var didLoad = false
    @State private var showSavedToast = false

    private var detail: EventDetail? {
        interactionStore.eventDetail(id: eventId)
    }

    private func eventStartTime(for detail: EventDetail) -> Date {
        DateRounding.toFiveMinuteInterval(detail.summary.date)
    }

    private var lateArrivalBinding: Binding<Date> {
        Binding(
            get: { lateArrival },
            set: { newValue in
                guard let detail else {
                    lateArrival = DateRounding.toFiveMinuteInterval(newValue)
                    return
                }
                let eventStart = eventStartTime(for: detail)
                let merged = DateRounding.mergeTime(from: newValue, keepingDayFrom: eventStart)
                lateArrival = max(DateRounding.toFiveMinuteInterval(merged), eventStart)
            }
        )
    }

    var body: some View {
        Group {
            if let detail {
                content(detail)
            } else {
                Text("이벤트를 찾을 수 없습니다")
                    .foregroundStyle(CelinkTheme.inkMuted)
            }
        }
        .background(CelinkTheme.background)
        .navigationTitle("RSVP")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(CelinkTheme.background, for: .navigationBar)
        .onAppear { loadIfNeeded(from: detail) }
        .onChange(of: detail?.summary.rsvpStatus) { _, _ in
            loadIfNeeded(from: detail)
        }
        .overlay(alignment: .top) {
            if showSavedToast {
                Text("응답이 저장되었어요")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(CelinkTheme.primaryDeep)
                    .clipShape(Capsule())
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showSavedToast)
    }

    private func content(_ detail: EventDetail) -> some View {
        let event = detail.summary

        return ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                EventSubpageHeader(
                    title: "참여여부 회신",
                    eventTitle: event.title,
                    subtitle: "\(event.hostName)님께 참여 여부를 알려주세요"
                )

                EventInfoMiniCard(
                    dateText: EventFormatting.eventDate(event.date),
                    location: event.location
                )

                if let notice = detail.notice {
                    Text(notice)
                        .font(.caption)
                        .foregroundStyle(CelinkTheme.inkMuted)
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(CelinkTheme.backgroundSecondary.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("회신 선택")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(CelinkTheme.ink)

                    VStack(spacing: 10) {
                        rsvpOption(.yes)
                        rsvpOption(.no)
                        rsvpOption(.maybe)
                        rsvpOption(.pending)
                    }
                }

                if selectedStatus == .maybe {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("몇 시에 참여 가능한가요?")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(CelinkTheme.ink)

                        Text("이벤트 시작 시간 이후로 5분 단위 선택")
                            .font(.caption)
                            .foregroundStyle(CelinkTheme.inkMuted)

                        FiveMinuteTimeWheelPicker(
                            date: lateArrivalBinding,
                            minimumDate: eventStartTime(for: detail)
                        )
                        .frame(maxWidth: .infinity)
                            .frame(height: 180)
                            .padding(.horizontal, 6)
                            .padding(.top, 6)
                            .padding(.bottom, 2)
                            .background(CelinkTheme.backgroundSecondary.opacity(0.45))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        Text("선택된 참여 시각: \(EventFormatting.eventDate(lateArrival))")
                            .font(.caption)
                            .foregroundStyle(CelinkTheme.primaryDeep)
                            .padding(.horizontal, 4)
                    }
                    .padding(14)
                    .background(CelinkTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(CelinkTheme.border, lineWidth: 1)
                    }
                }

                CelinkPrimaryButton(
                    title: "회신 저장",
                    disabled: false
                ) {
                    saveRSVP()
                }
            }
            .padding(.horizontal, CelinkLayout.horizontalPadding)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
    }

    private func loadIfNeeded(from detail: EventDetail?) {
        guard !didLoad, let detail else { return }
        let resolved = interactionStore.rsvpStatus(
            for: eventId,
            default: detail.summary.rsvpStatus
        )
        selectedStatus = resolved
        let eventStart = eventStartTime(for: detail)
        if let savedLate = interactionStore.lateArrivalTime(for: eventId) {
            lateArrival = max(DateRounding.toFiveMinuteInterval(savedLate), eventStart)
        } else {
            lateArrival = eventStart
        }
        didLoad = true
    }

    private func rsvpOption(_ status: RSVPStatus) -> some View {
        let colors = EventLabels.rsvpColors(status)
        let isSelected = selectedStatus == status

        return Button {
            selectedStatus = status
            if status == .maybe, let detail {
                lateArrival = eventStartTime(for: detail)
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: EventLabels.rsvpIcon(status))
                    .font(.title2)
                    .foregroundStyle(colors.foreground)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(EventLabels.rsvpName(status))
                        .font(.body.weight(.semibold))
                        .foregroundStyle(CelinkTheme.ink)

                    Text(EventLabels.rsvpSubtitle(status))
                        .font(.caption)
                        .foregroundStyle(CelinkTheme.inkMuted)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(CelinkTheme.primaryDeep)
                }
            }
            .padding(16)
            .background(isSelected ? colors.background : CelinkTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? CelinkTheme.primary : CelinkTheme.border, lineWidth: isSelected ? 2 : 1)
            }
        }
        .buttonStyle(.plain)
    }

    private func saveRSVP() {
        let lateTime: Date? = {
            guard selectedStatus == .maybe, let detail else { return nil }
            return max(lateArrival, eventStartTime(for: detail))
        }()
        interactionStore.saveRSVP(
            eventId: eventId,
            status: selectedStatus,
            lateArrivalTime: lateTime
        )
        showSavedToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            showSavedToast = false
            dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        EventRSVPView(eventId: "evt-1")
    }
}
