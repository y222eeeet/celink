import SwiftUI

struct HomeView: View {
    @Bindable private var createdStore = CreatedEventsStore.shared

    private let events = MockData.invitedEvents
    private let photos = MockData.recentPhotos
    private let reminders = MockData.reminders

    private var upcomingEvents: [EventSummary] {
        (createdStore.summaries + events)
            .filter(\.isUpcoming)
            .sorted { $0.date < $1.date }
    }

    private var recentParticipation: [EventSummary] {
        events
            .filter { $0.lastParticipatedAt != nil }
            .sorted {
                ($0.lastParticipatedAt ?? .distantPast) > ($1.lastParticipatedAt ?? .distantPast)
            }
            .prefix(3)
            .map { $0 }
    }

    var body: some View {
        GeometryReader { geometry in
            let contentWidth = CelinkLayout.contentWidth(in: geometry.size.width)
            let photoCell = CelinkLayout.photoCellSize(contentWidth: contentWidth)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    header

                    myCreatedSection(contentWidth: contentWidth)
                    remindersSection(contentWidth: contentWidth)
                    upcomingSection(contentWidth: contentWidth)
                    recentPhotosSection(contentWidth: contentWidth, cellSize: photoCell)
                    recentParticipationSection(contentWidth: contentWidth)
                    invitedSection(contentWidth: contentWidth)
                }
                .frame(maxWidth: .infinity)
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
            Text(EventFormatting.greeting())
                .font(.subheadline)
                .foregroundStyle(CelinkTheme.inkMuted)

            Text("\(MockData.userName)님")
                .font(.system(size: 28, weight: .medium, design: .serif))
                .foregroundStyle(CelinkTheme.ink)

            Text("소중한 순간에 초대받은 이벤트를 모아봤어요")
                .font(.subheadline)
                .foregroundStyle(CelinkTheme.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, CelinkLayout.horizontalPadding)
        .padding(.top, 8)
        .padding(.bottom, 20)
    }

    @ViewBuilder
    private func eventLink<Content: View>(
        eventId: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationLink(value: eventId) {
            content()
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func myCreatedSection(contentWidth: CGFloat) -> some View {
        if !createdStore.summaries.isEmpty {
            sectionBlock {
                SectionHeaderView(title: "내가 만든 이벤트", trailing: "\(createdStore.summaries.count)개")
                    .padding(.bottom, 12)

                VStack(spacing: CelinkLayout.itemSpacing) {
                    ForEach(createdStore.summaries) { event in
                        eventLink(eventId: event.id) {
                            EventCardView(event: event, style: .standard, contentWidth: contentWidth)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func remindersSection(contentWidth: CGFloat) -> some View {
        if !reminders.isEmpty {
            sectionBlock {
                SectionHeaderView(title: "리마인더")
                    .padding(.bottom, 12)

                VStack(spacing: 8) {
                    ForEach(reminders) { reminder in
                        eventLink(eventId: reminder.eventId) {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "bell.fill")
                                    .font(.body)
                                    .foregroundStyle(CelinkTheme.primaryDeep)
                                    .frame(width: 32, height: 32)
                                    .background(CelinkTheme.primary.opacity(0.25))
                                    .clipShape(Circle())

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(reminder.eventTitle)
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(CelinkTheme.ink)
                                    Text(reminder.message)
                                        .font(.caption)
                                        .foregroundStyle(CelinkTheme.inkMuted)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)

                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(CelinkTheme.primary.opacity(0.8))
                            }
                            .padding(14)
                            .frame(width: contentWidth, alignment: .leading)
                            .background(CelinkTheme.backgroundSecondary.opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(CelinkTheme.border, lineWidth: 1)
                            }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func upcomingSection(contentWidth: CGFloat) -> some View {
        if let featured = upcomingEvents.first {
            sectionBlock {
                SectionHeaderView(title: "다가오는 이벤트")
                    .padding(.bottom, 12)

                VStack(spacing: CelinkLayout.itemSpacing) {
                    eventLink(eventId: featured.id) {
                        EventCardView(event: featured, style: .featured, contentWidth: contentWidth)
                    }

                    ForEach(upcomingEvents.dropFirst().prefix(2)) { event in
                        eventLink(eventId: event.id) {
                            EventCardView(event: event, style: .compact, contentWidth: contentWidth)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func recentPhotosSection(contentWidth: CGFloat, cellSize: CGFloat) -> some View {
        if !photos.isEmpty {
            sectionBlock {
                SectionHeaderView(title: "최근 업로드", trailing: "전체 보기")
                    .padding(.bottom, 12)

                LazyVGrid(
                    columns: Array(
                        repeating: GridItem(.fixed(cellSize), spacing: CelinkLayout.photoGridSpacing),
                        count: CelinkLayout.photoGridColumns
                    ),
                    spacing: CelinkLayout.photoGridSpacing
                ) {
                    ForEach(photos.prefix(4)) { photo in
                        eventLink(eventId: photo.eventId) {
                            RemoteImage(url: photo.imageURL)
                                .frame(width: cellSize, height: cellSize)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .frame(width: contentWidth)
            }
        }
    }

    @ViewBuilder
    private func recentParticipationSection(contentWidth: CGFloat) -> some View {
        if !recentParticipation.isEmpty {
            sectionBlock {
                SectionHeaderView(title: "최근 참여")
                    .padding(.bottom, 12)

                VStack(spacing: 8) {
                    ForEach(recentParticipation) { event in
                        eventLink(eventId: event.id) {
                            EventCardView(event: event, style: .compact, contentWidth: contentWidth)
                        }
                    }
                }
            }
        }
    }

    private func invitedSection(contentWidth: CGFloat) -> some View {
        sectionBlock {
            SectionHeaderView(title: "초대받은 이벤트", trailing: "\(events.count)개")
                .padding(.bottom, 12)

            VStack(spacing: CelinkLayout.itemSpacing) {
                ForEach(events) { event in
                    eventLink(eventId: event.id) {
                        EventCardView(event: event, style: .standard, contentWidth: contentWidth)
                    }
                }
            }
        }
    }

    private func sectionBlock<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, CelinkLayout.horizontalPadding)
        .padding(.bottom, CelinkLayout.sectionSpacing)
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
