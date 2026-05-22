import SwiftUI

struct EventRSVPView: View {
    let eventId: String
    @Environment(\.dismiss) private var dismiss
    @Bindable private var interactionStore = EventInteractionStore.shared

    @State private var selectedStatus: RSVPStatus = .pending
    @State private var guestCount = 1
    @State private var note = ""
    @State private var didLoad = false
    @State private var showSavedToast = false

    private var detail: EventDetail? {
        interactionStore.eventDetail(id: eventId)
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
                    title: "참석 여부",
                    eventTitle: event.title,
                    subtitle: isOwnedEvent
                        ? "게스트들의 응답은 추후 집계됩니다"
                        : "\(event.hostName)님께 참석 여부를 알려주세요"
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
                    Text("응답 선택")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(CelinkTheme.ink)

                    VStack(spacing: 10) {
                        rsvpOption(.yes)
                        rsvpOption(.maybe)
                        rsvpOption(.no)
                    }
                }

                if selectedStatus == .yes {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("동반 인원 (본인 포함)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(CelinkTheme.ink)

                        HStack {
                            Button {
                                if guestCount > 1 { guestCount -= 1 }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(guestCount > 1 ? CelinkTheme.primaryDeep : CelinkTheme.border)
                            }
                            .disabled(guestCount <= 1)

                            Text("\(guestCount)명")
                                .font(.title3.weight(.medium))
                                .foregroundStyle(CelinkTheme.ink)
                                .frame(minWidth: 64)

                            Button {
                                if guestCount < 10 { guestCount += 1 }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(guestCount < 10 ? CelinkTheme.primaryDeep : CelinkTheme.border)
                            }
                            .disabled(guestCount >= 10)

                            Spacer()
                        }
                        .padding(16)
                        .background(CelinkTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(CelinkTheme.border, lineWidth: 1)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("호스트에게 메시지 (선택)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(CelinkTheme.ink)

                    TextField("전달할 메시지를 입력해 주세요", text: $note, axis: .vertical)
                        .lineLimit(3...5)
                        .font(.body)
                        .foregroundStyle(CelinkTheme.ink)
                        .padding(14)
                        .background(CelinkTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(CelinkTheme.border, lineWidth: 1)
                        }
                }

                CelinkPrimaryButton(
                    title: "응답 저장",
                    disabled: selectedStatus == .pending
                ) {
                    saveRSVP()
                }
            }
            .padding(.horizontal, CelinkLayout.horizontalPadding)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
    }

    private var isOwnedEvent: Bool {
        CreatedEventsStore.shared.isOwned(eventId: eventId)
    }

    private func loadIfNeeded(from detail: EventDetail?) {
        guard !didLoad, let detail else { return }
        let resolved = interactionStore.rsvpStatus(
            for: eventId,
            default: detail.summary.rsvpStatus
        )
        selectedStatus = resolved
        guestCount = interactionStore.guestCount(for: eventId)
        note = interactionStore.rsvpNote(for: eventId)
        didLoad = true
    }

    private func rsvpOption(_ status: RSVPStatus) -> some View {
        let colors = EventLabels.rsvpColors(status)
        let isSelected = selectedStatus == status

        return Button {
            selectedStatus = status
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
        interactionStore.saveRSVP(
            eventId: eventId,
            status: selectedStatus,
            guestCount: guestCount,
            note: note
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
