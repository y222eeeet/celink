import SwiftUI

struct ProfileView: View {
    @Bindable private var createdStore = CreatedEventsStore.shared
    @Bindable private var interactionStore = EventInteractionStore.shared

    private var joinedEvents: [EventSummary] {
        MockData.invitedEvents
            .filter { !createdStore.isOwned(eventId: $0.id) }
            .map { event in
                let resolvedStatus = interactionStore.rsvpStatus(for: event.id, default: event.rsvpStatus)
                return EventSummary(
                    id: event.id,
                    type: event.type,
                    title: event.title,
                    date: event.date,
                    location: event.location,
                    coverImageURL: event.coverImageURL,
                    hostName: event.hostName,
                    rsvpStatus: resolvedStatus,
                    lastParticipatedAt: event.lastParticipatedAt,
                    isUpcoming: event.isUpcoming
                )
            }
    }

    private var totalLedgerAmount: Int {
        interactionStore.currentLedgerAmount()
    }

    var body: some View {
        GeometryReader { geometry in
            let contentWidth = CelinkLayout.contentWidth(in: geometry.size.width)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    header
                    ledgerSummarySection

                    if !createdStore.summaries.isEmpty {
                        eventSection(
                            title: "내가 만든 이벤트",
                            count: createdStore.summaries.count,
                            events: createdStore.summaries,
                            contentWidth: contentWidth
                        )
                    }

                    if !joinedEvents.isEmpty {
                        eventSection(
                            title: "내가 참여한 이벤트",
                            count: joinedEvents.count,
                            events: joinedEvents,
                            contentWidth: contentWidth
                        )
                    }

                    if createdStore.summaries.isEmpty && joinedEvents.isEmpty {
                        emptyState
                    }
                }
                .padding(.bottom, CelinkLayout.scrollBottomInset)
            }
            .frame(width: geometry.size.width)
            .background(CelinkTheme.background)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CelinkTheme.background)
        .navigationDestination(for: String.self) { eventId in
            EventDetailView(eventId: eventId)
        }
        .navigationDestination(for: ProfileDestination.self) { destination in
            switch destination {
            case .ledgerOverview:
                ProfileLedgerOverviewView()
            case .withdraw:
                ProfileWithdrawView()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("프로필")
                .font(.system(size: 28, weight: .medium, design: .serif))
                .foregroundStyle(CelinkTheme.ink)

            Text("\(MockData.userName)님의 이벤트")
                .font(.subheadline)
                .foregroundStyle(CelinkTheme.inkMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, CelinkLayout.horizontalPadding)
        .padding(.top, 8)
        .padding(.bottom, 24)
    }

    private var ledgerSummarySection: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 10) {
                Text("장부 금액")
                    .font(.subheadline)
                    .foregroundStyle(CelinkTheme.inkMuted)
                Text(formatAmount(totalLedgerAmount))
                    .font(.system(size: 38, weight: .semibold, design: .rounded))
                    .foregroundStyle(CelinkTheme.primaryDeep)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 18)
            .padding(.vertical, 20)
            .background(CelinkTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(CelinkTheme.border, lineWidth: 1)
            }

            HStack(spacing: 10) {
                NavigationLink(value: ProfileDestination.ledgerOverview) {
                    Text("장부 열기")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(CelinkTheme.primaryDeep)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)

                NavigationLink(value: ProfileDestination.withdraw) {
                    Text("출금하기")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(CelinkTheme.primaryDeep)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(CelinkTheme.backgroundSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(CelinkTheme.border, lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 4)
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [CelinkTheme.surface, CelinkTheme.backgroundSecondary.opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(CelinkTheme.primary.opacity(0.35), lineWidth: 1.2)
        }
        .padding(.horizontal, CelinkLayout.horizontalPadding)
        .padding(.bottom, 20)
    }

    private func eventSection(
        title: String,
        count: Int,
        events: [EventSummary],
        contentWidth: CGFloat
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                SectionHeaderView(title: title, trailing: "\(count)개")
            }
            .padding(.horizontal, CelinkLayout.horizontalPadding)
            .padding(.bottom, 12)

            VStack(spacing: CelinkLayout.itemSpacing) {
                ForEach(events) { event in
                    NavigationLink(value: event.id) {
                        EventCardView(event: event, style: .standard, contentWidth: contentWidth)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, CelinkLayout.horizontalPadding)
            .padding(.bottom, CelinkLayout.sectionSpacing)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Text("아직 이벤트가 없어요")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(CelinkTheme.ink)
            Text("만들기 탭에서 첫 이벤트를 만들어 보세요")
                .font(.caption)
                .foregroundStyle(CelinkTheme.inkMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }

    private func formatAmount(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let text = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        return "\(text)원"
    }
}

private enum ProfileDestination: Hashable {
    case ledgerOverview
    case withdraw
}

#Preview {
    NavigationStack {
        ProfileView()
    }
}
