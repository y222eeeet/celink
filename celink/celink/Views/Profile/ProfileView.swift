import SwiftUI

struct ProfileView: View {
    @Bindable private var createdStore = CreatedEventsStore.shared

    private var joinedEvents: [EventSummary] {
        MockData.invitedEvents.filter { !createdStore.isOwned(eventId: $0.id) }
    }

    var body: some View {
        GeometryReader { geometry in
            let contentWidth = CelinkLayout.contentWidth(in: geometry.size.width)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    header

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
}

#Preview {
    NavigationStack {
        ProfileView()
    }
}
