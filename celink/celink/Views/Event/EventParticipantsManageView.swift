import SwiftUI

struct EventParticipantsManageView: View {
    let eventId: String
    @Bindable private var interactionStore = EventInteractionStore.shared
    @State private var selectedRelation: RelationFilter = .all
    @State private var selectedRSVPStatus: RSVPStatus?

    private var detail: EventDetail? {
        interactionStore.eventDetail(id: eventId)
    }

    private var entries: [InvitedParticipantEntry] {
        interactionStore.participantEntries(for: eventId)
    }

    private var filteredEntries: [InvitedParticipantEntry] {
        let relationFiltered: [InvitedParticipantEntry] = switch selectedRelation {
        case .all:
            entries
        case .relation(let relation):
            entries.filter { $0.relation == relation }
        }

        guard let selectedRSVPStatus else { return relationFiltered }
        return relationFiltered.filter { $0.rsvpStatus == selectedRSVPStatus }
    }

    private var yesCount: Int {
        entries.filter { $0.rsvpStatus == .yes }.count
    }

    private var noCount: Int {
        entries.filter { $0.rsvpStatus == .no }.count
    }

    private var maybeCount: Int {
        entries.filter { $0.rsvpStatus == .maybe }.count
    }

    private var pendingCount: Int {
        entries.filter { $0.rsvpStatus == .pending }.count
    }

    var body: some View {
        Group {
            if let detail {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        EventSubpageHeader(
                            title: "참여자 관리",
                            eventTitle: detail.summary.title,
                            subtitle: "초대한 사람들의 RSVP 현황을 확인해요"
                        )

                        summaryCard

                        if let selectedRSVPStatus {
                            activeRSVPFilterChip(selectedRSVPStatus)
                        }

                        relationFilterChips

                        VStack(spacing: 10) {
                            ForEach(filteredEntries) { entry in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(entry.name)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(CelinkTheme.ink)
                                        Text(entry.relation.rawValue)
                                            .font(.caption)
                                            .foregroundStyle(CelinkTheme.inkMuted)
                                    }
                                    Spacer()

                                    Text(EventLabels.rsvpName(entry.rsvpStatus))
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(EventLabels.rsvpColors(entry.rsvpStatus).foreground)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(EventLabels.rsvpColors(entry.rsvpStatus).background)
                                        .clipShape(Capsule())
                                }
                                .padding(14)
                                .background(CelinkTheme.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(CelinkTheme.border, lineWidth: 1)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, CelinkLayout.horizontalPadding)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
            } else {
                Text("이벤트를 찾을 수 없습니다")
                    .foregroundStyle(CelinkTheme.inkMuted)
            }
        }
        .background(CelinkTheme.background)
        .navigationTitle("참여자 관리하기")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(CelinkTheme.background, for: .navigationBar)
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("총 참여자 \(entries.count)명")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(CelinkTheme.ink)

            HStack(spacing: 8) {
                countPill(title: "참여", count: yesCount, status: .yes, selected: selectedRSVPStatus == .yes)
                countPill(title: "미참여", count: noCount, status: .no, selected: selectedRSVPStatus == .no)
                countPill(title: "늦게 참여", count: maybeCount, status: .maybe, selected: selectedRSVPStatus == .maybe)
                countPill(title: "미정", count: pendingCount, status: .pending, selected: selectedRSVPStatus == .pending)
            }
        }
        .padding(14)
        .background(CelinkTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(CelinkTheme.border, lineWidth: 1)
        }
    }

    private func activeRSVPFilterChip(_ status: RSVPStatus) -> some View {
        HStack(spacing: 8) {
            Text("상태 필터: \(EventLabels.rsvpName(status))")
                .font(.caption.weight(.semibold))
                .foregroundStyle(CelinkTheme.primaryDeep)

            Button {
                selectedRSVPStatus = nil
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(CelinkTheme.primaryDeep)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(CelinkTheme.backgroundSecondary)
        .clipShape(Capsule())
    }

    private var relationFilterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(RelationFilter.allCases, id: \.id) { filter in
                    let isSelected = selectedRelation == filter
                    Button {
                        selectedRelation = filter
                    } label: {
                        Text(filter.title)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(isSelected ? .white : CelinkTheme.primaryDeep)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(isSelected ? CelinkTheme.primaryDeep : CelinkTheme.backgroundSecondary)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func countPill(title: String, count: Int, status: RSVPStatus, selected: Bool) -> some View {
        let colors = EventLabels.rsvpColors(status)
        return Button {
            selectedRSVPStatus = selected ? nil : status
        } label: {
            VStack(spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(colors.foreground)
                Text("\(count)명")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(colors.foreground)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(colors.background)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(selected ? CelinkTheme.primaryDeep : Color.clear, lineWidth: 2)
            }
        }
        .buttonStyle(.plain)
    }
}

private enum RelationFilter: Hashable, CaseIterable {
    case all
    case relation(RelationType)

    static var allCases: [RelationFilter] {
        [.all] + RelationType.allCases.map { .relation($0) }
    }

    var id: String {
        switch self {
        case .all:
            "all"
        case .relation(let relation):
            relation.rawValue
        }
    }

    var title: String {
        switch self {
        case .all:
            "전체"
        case .relation(let relation):
            relation.rawValue
        }
    }
}

#Preview {
    NavigationStack {
        EventParticipantsManageView(eventId: "owned-birthday-1")
    }
}
