import SwiftUI

struct EventDetailView: View {
    let eventId: String
    @Environment(\.dismiss) private var dismiss
    @Bindable private var createdStore = CreatedEventsStore.shared
    @Bindable private var interactionStore = EventInteractionStore.shared
    @State private var showEdit = false

    private var detail: EventDetail? {
        createdStore.detail(id: eventId) ?? MockData.eventDetail(id: eventId)
    }

    private var isOwnedEvent: Bool {
        CreatedEventsStore.shared.isOwned(eventId: eventId)
    }

    var body: some View {
        Group {
            if let detail {
                detailContent(detail)
            } else {
                notFoundView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CelinkTheme.background)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $showEdit) {
            EditEventView(eventId: eventId)
        }
        .navigationDestination(for: EventDetailDestination.self) { destination in
            switch destination {
            case .rsvp:
                EventRSVPView(eventId: eventId)
            case .guestbook:
                EventGuestbookView(eventId: eventId)
            case .photoAlbum:
                EventPhotoAlbumView(eventId: eventId)
            }
        }
    }

    private func detailContent(_ detail: EventDetail) -> some View {
        let event = detail.summary

        return GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let topInset = geometry.safeAreaInsets.top
            let contentWidth = CelinkLayout.contentWidth(in: screenWidth)
            let heroHeight = CelinkLayout.eventDetailHeroHeight(screenWidth: screenWidth) + topInset

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    hero(
                        event: event,
                        screenWidth: screenWidth,
                        heroHeight: heroHeight,
                        topInset: topInset
                    )

                    infoSection(detail: detail, contentWidth: contentWidth)

                    actionButtons(contentWidth: contentWidth)

                    if !detail.schedule.isEmpty {
                        scheduleSection(detail.schedule, contentWidth: contentWidth)
                    }
                    if !interactionStore.guestbookEntries(for: eventId).isEmpty {
                        guestbookSection(contentWidth: contentWidth)
                    }
                    if !interactionStore.photoURLs(for: eventId).isEmpty {
                        photosSection(contentWidth: contentWidth)
                    }
                }
                .frame(width: screenWidth, alignment: .leading)
                .padding(.bottom, CelinkLayout.scrollBottomInset)
            }
            .frame(width: screenWidth, height: geometry.size.height)
            .scrollIndicators(.hidden)
            .ignoresSafeArea(edges: .top)
            .safeAreaInset(edge: .top, spacing: 0) {
                detailNavBar
                    .padding(.horizontal, CelinkLayout.horizontalPadding)
                    .padding(.bottom, 6)
            }
        }
    }

    private var detailNavBar: some View {
        HStack(alignment: .center, spacing: 12) {
            floatingNavButton(systemName: "chevron.left", accessibilityLabel: "돌아가기") {
                dismiss()
            }

            Spacer(minLength: 0)

            if isOwnedEvent {
                floatingNavButton(systemName: "pencil", accessibilityLabel: "이벤트 수정") {
                    showEdit = true
                }
            }
        }
        .frame(height: 44)
    }

    private func floatingNavButton(
        systemName: String,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.body.weight(.semibold))
                .foregroundStyle(CelinkTheme.primaryDeep)
                .frame(width: 40, height: 40)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.12), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }

    private func hero(
        event: EventSummary,
        screenWidth: CGFloat,
        heroHeight: CGFloat,
        topInset: CGFloat
    ) -> some View {
        ZStack(alignment: .bottomLeading) {
            RemoteImage(url: event.coverImageURL)
                .frame(width: screenWidth, height: heroHeight)

            LinearGradient(
                colors: [
                    CelinkTheme.primaryDeep.opacity(0.12),
                    CelinkTheme.primaryDeep.opacity(0.5),
                    CelinkTheme.ink.opacity(0.72),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: screenWidth, height: heroHeight)

            VStack(alignment: .leading, spacing: 8) {
                if let dDay = EventFormatting.dDay(from: event.date), event.isUpcoming {
                    Text(dDay)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(CelinkTheme.primary.opacity(0.85))
                        .clipShape(Capsule())
                }

                Text(EventLabels.typeName(event.type))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.85))

                Text(event.title)
                    .font(.title3.weight(.medium))
                    .fontDesign(.serif)
                    .foregroundStyle(.white)
                    .lineLimit(3)
                    .minimumScaleFactor(0.9)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, CelinkLayout.horizontalPadding)
            .padding(.bottom, 20)
            .frame(width: screenWidth, alignment: .leading)
        }
        .frame(width: screenWidth, height: heroHeight)
        .clipped()
        .padding(.top, topInset > 0 ? -topInset : 0)
    }

    private func resolvedRSVPStatus(for event: EventSummary) -> RSVPStatus {
        interactionStore.rsvpStatus(for: eventId, default: event.rsvpStatus)
    }

    private func infoSection(detail: EventDetail, contentWidth: CGFloat) -> some View {
        let event = detail.summary
        let status = resolvedRSVPStatus(for: event)
        let rsvp = EventLabels.rsvpColors(status)
        let hostLabel = isOwnedEvent ? "내가 주최한 이벤트" : "\(event.hostName)님의 초대"

        return VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 10) {
                Text(EventLabels.rsvpName(status))
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(rsvp.background)
                    .foregroundStyle(rsvp.foreground)
                    .clipShape(Capsule())
                    .fixedSize()

                Text(hostLabel)
                    .font(.caption)
                    .foregroundStyle(CelinkTheme.inkMuted)
                    .lineLimit(2)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }

            Text(detail.description)
                .font(.subheadline)
                .foregroundStyle(CelinkTheme.ink)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 12) {
                infoRow(icon: "calendar", text: EventFormatting.eventDate(event.date))
                infoRow(icon: "mappin.and.ellipse", text: event.location)
                if let dressCode = detail.dressCode {
                    infoRow(icon: "tshirt", text: dressCode)
                }
                if let notice = detail.notice {
                    infoRow(icon: "info.circle", text: notice)
                }
            }
        }
        .padding(16)
        .frame(width: contentWidth, alignment: .leading)
        .background(CelinkTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: CelinkLayout.cardCornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: CelinkLayout.cardCornerRadius)
                .stroke(CelinkTheme.border, lineWidth: 1)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, CelinkLayout.horizontalPadding)
    }

    private func infoRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(CelinkTheme.primary)
                .frame(width: 22, alignment: .center)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(CelinkTheme.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func actionButtons(contentWidth: CGFloat) -> some View {
        let chipWidth = CelinkLayout.eventDetailActionChipWidth(contentWidth: contentWidth)
        let spacing = CelinkLayout.itemSpacing

        return HStack(spacing: spacing) {
            NavigationLink(value: EventDetailDestination.rsvp) {
                actionChip(title: "RSVP", icon: "checkmark.circle", width: chipWidth)
            }
            .buttonStyle(.plain)

            NavigationLink(value: EventDetailDestination.guestbook) {
                actionChip(title: "방명록", icon: "text.quote", width: chipWidth)
            }
            .buttonStyle(.plain)

            NavigationLink(value: EventDetailDestination.photoAlbum) {
                actionChip(title: "사진 앨범", icon: "photo.on.rectangle.angled", width: chipWidth)
            }
            .buttonStyle(.plain)
        }
        .frame(width: contentWidth)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, CelinkLayout.horizontalPadding)
        .padding(.vertical, 4)
    }

    private func actionChip(title: String, icon: String, width: CGFloat) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(CelinkTheme.primaryDeep)
                .frame(width: 40, height: 40)
                .background(CelinkTheme.backgroundSecondary)
                .clipShape(Circle())

            Text(title)
                .font(.caption2.weight(.medium))
                .foregroundStyle(CelinkTheme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(width: width)
        .padding(.vertical, 10)
        .background(CelinkTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(CelinkTheme.border, lineWidth: 1)
        }
    }

    private func scheduleSection(_ items: [ScheduleItem], contentWidth: CGFloat) -> some View {
        detailSection(title: "프로그램 식순", contentWidth: contentWidth) {
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    HStack(alignment: .top, spacing: 14) {
                        VStack(spacing: 0) {
                            Circle()
                                .fill(CelinkTheme.primary)
                                .frame(width: 10, height: 10)
                            if index < items.count - 1 {
                                Rectangle()
                                    .fill(CelinkTheme.border)
                                    .frame(width: 2)
                                    .frame(maxHeight: .infinity)
                            }
                        }
                        .frame(width: 10)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(scheduleTime(item.time))
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(CelinkTheme.primaryDeep)

                            Text(item.title)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(CelinkTheme.ink)

                            if let note = item.note {
                                Text(note)
                                    .font(.caption)
                                    .foregroundStyle(CelinkTheme.inkMuted)
                            }
                        }
                        .padding(.bottom, index < items.count - 1 ? 20 : 0)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(16)
            .frame(width: contentWidth, alignment: .leading)
            .background(CelinkTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: CelinkLayout.cardCornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: CelinkLayout.cardCornerRadius)
                    .stroke(CelinkTheme.border, lineWidth: 1)
            }
        }
    }

    private func guestbookSection(contentWidth: CGFloat) -> some View {
        let allEntries = interactionStore.guestbookEntries(for: eventId)
        return detailSection(
            title: "방명록",
            trailing: "\(allEntries.count)개",
            trailingDestination: .guestbook,
            contentWidth: contentWidth
        ) {
            VStack(spacing: 10) {
                ForEach(allEntries.prefix(3)) { entry in
                    guestbookCard(entry)
                }
            }
            .frame(width: contentWidth, alignment: .leading)
        }
    }

    private func guestbookCard(_ entry: GuestbookEntry) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(entry.isPrivate ? "비공개 메시지" : entry.authorName)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(CelinkTheme.ink)
                    .lineLimit(1)

                Spacer(minLength: 8)

                if entry.isPrivate {
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                        .foregroundStyle(CelinkTheme.inkMuted)
                }

                Text(EventFormatting.relativeDate(entry.createdAt))
                    .font(.caption2)
                    .foregroundStyle(CelinkTheme.inkMuted)
                    .lineLimit(1)
            }

            Text(entry.isPrivate ? "호스트만 볼 수 있는 메시지입니다." : entry.content)
                .font(.subheadline)
                .foregroundStyle(entry.isPrivate ? CelinkTheme.inkMuted : CelinkTheme.ink)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CelinkTheme.backgroundSecondary.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func photosSection(contentWidth: CGFloat) -> some View {
        let allURLs = interactionStore.photoURLs(for: eventId)
        let thumbSize = min(120, floor((contentWidth - 20) / 3))

        return detailSection(
            title: "공유 앨범",
            trailing: "전체 보기",
            trailingDestination: .photoAlbum,
            contentWidth: contentWidth
        ) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(allURLs.prefix(6).enumerated()), id: \.offset) { _, url in
                        RemoteImage(url: url)
                            .frame(width: thumbSize, height: thumbSize)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            .frame(width: contentWidth, alignment: .leading)
        }
    }

    private func detailSection<Content: View>(
        title: String,
        trailing: String? = nil,
        trailingDestination: EventDetailDestination? = nil,
        contentWidth: CGFloat,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CelinkTheme.primaryDeep)
                    .textCase(.uppercase)
                    .tracking(0.5)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                Spacer(minLength: 8)

                if let trailing {
                    if let trailingDestination {
                        NavigationLink(value: trailingDestination) {
                            Text(trailing)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(CelinkTheme.primaryDeep)
                                .lineLimit(1)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Text(trailing)
                            .font(.caption)
                            .foregroundStyle(CelinkTheme.inkMuted)
                            .lineLimit(1)
                    }
                }
            }

            content()
        }
        .frame(width: contentWidth, alignment: .leading)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, CelinkLayout.horizontalPadding)
        .padding(.bottom, 24)
    }

    private func scheduleTime(_ date: Date) -> String {
        date.formatted(
            .dateTime
                .locale(Locale(identifier: "ko_KR"))
                .hour()
                .minute()
        )
    }

    private var notFoundView: some View {
        VStack(spacing: 12) {
            Text("이벤트를 찾을 수 없습니다")
                .foregroundStyle(CelinkTheme.inkMuted)
            Button("돌아가기") { dismiss() }
                .foregroundStyle(CelinkTheme.primaryDeep)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NavigationStack {
        EventDetailView(eventId: "evt-1")
    }
}
