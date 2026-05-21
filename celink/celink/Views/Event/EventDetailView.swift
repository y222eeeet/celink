import SwiftUI

struct EventDetailView: View {
    let eventId: String
    @Environment(\.dismiss) private var dismiss
    @Bindable private var createdStore = CreatedEventsStore.shared
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
        .background(CelinkTheme.background)
        .navigationBarBackButtonHidden(true)
        .toolbar(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(CelinkTheme.primaryDeep)
                }
            }

            if isOwnedEvent {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showEdit = true
                    } label: {
                        Image(systemName: "pencil")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(CelinkTheme.primaryDeep)
                    }
                    .accessibilityLabel("이벤트 수정")
                }
            }
        }
        .toolbarBackground(CelinkTheme.background, for: .navigationBar)
        .navigationDestination(isPresented: $showEdit) {
            EditEventView(eventId: eventId)
        }
    }

    private func detailContent(_ detail: EventDetail) -> some View {
        let event = detail.summary

        return ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                hero(event: event)
                infoSection(detail: detail)
                actionButtons(event: event)
                if !detail.schedule.isEmpty {
                    scheduleSection(detail.schedule)
                }
                if !detail.guestbook.isEmpty {
                    guestbookSection(detail.guestbook)
                }
                if !detail.photoURLs.isEmpty {
                    photosSection(detail.photoURLs, title: event.title)
                }
            }
            .padding(.bottom, 32)
        }
    }

    private func hero(event: EventSummary) -> some View {
        ZStack(alignment: .bottomLeading) {
            RemoteImage(url: event.coverImageURL)
                .frame(height: 280)
                .frame(maxWidth: .infinity)

            LinearGradient(
                colors: [
                    CelinkTheme.primaryDeep.opacity(0.15),
                    CelinkTheme.primaryDeep.opacity(0.55),
                    CelinkTheme.ink.opacity(0.75),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

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
                    .font(.title2.weight(.medium))
                    .fontDesign(.serif)
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
        .clipped()
    }

    private func infoSection(detail: EventDetail) -> some View {
        let event = detail.summary
        let rsvp = EventLabels.rsvpColors(event.rsvpStatus)

        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(EventLabels.rsvpName(event.rsvpStatus))
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(rsvp.background)
                    .foregroundStyle(rsvp.foreground)
                    .clipShape(Capsule())

                Spacer()

                Text(isOwnedEvent ? "내가 주최한 이벤트" : "\(event.hostName)님의 초대")
                    .font(.caption)
                    .foregroundStyle(CelinkTheme.inkMuted)
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
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CelinkTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: CelinkLayout.cardCornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: CelinkLayout.cardCornerRadius)
                .stroke(CelinkTheme.border, lineWidth: 1)
        }
        .padding(.horizontal, CelinkLayout.horizontalPadding)
        .padding(.top, -28)
        .padding(.bottom, 8)
    }

    private func infoRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(CelinkTheme.primary)
                .frame(width: 22)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(CelinkTheme.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func actionButtons(event: EventSummary) -> some View {
        HStack(spacing: 10) {
            actionChip(title: "RSVP", icon: "checkmark.circle")
            actionChip(title: "방명록", icon: "text.quote")
            actionChip(title: "사진 앨범", icon: "photo.on.rectangle.angled")
        }
        .padding(.horizontal, CelinkLayout.horizontalPadding)
        .padding(.vertical, 16)
    }

    private func actionChip(title: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(CelinkTheme.primaryDeep)
                .frame(width: 48, height: 48)
                .background(CelinkTheme.backgroundSecondary)
                .clipShape(Circle())

            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(CelinkTheme.ink)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(CelinkTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(CelinkTheme.border, lineWidth: 1)
        }
    }

    private func scheduleSection(_ items: [ScheduleItem]) -> some View {
        detailSection(title: "프로그램 식순") {
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
            .background(CelinkTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: CelinkLayout.cardCornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: CelinkLayout.cardCornerRadius)
                    .stroke(CelinkTheme.border, lineWidth: 1)
            }
        }
    }

    private func guestbookSection(_ entries: [GuestbookEntry]) -> some View {
        detailSection(title: "방명록", trailing: "\(entries.count)개") {
            VStack(spacing: 10) {
                ForEach(entries.prefix(3)) { entry in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(entry.isPrivate ? "비공개 메시지" : entry.authorName)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(CelinkTheme.ink)

                            Spacer()

                            if entry.isPrivate {
                                Image(systemName: "lock.fill")
                                    .font(.caption2)
                                    .foregroundStyle(CelinkTheme.inkMuted)
                            }

                            Text(EventFormatting.relativeDate(entry.createdAt))
                                .font(.caption2)
                                .foregroundStyle(CelinkTheme.inkMuted)
                        }

                        Text(entry.isPrivate ? "호스트만 볼 수 있는 메시지입니다." : entry.content)
                            .font(.subheadline)
                            .foregroundStyle(entry.isPrivate ? CelinkTheme.inkMuted : CelinkTheme.ink)
                            .lineSpacing(3)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(CelinkTheme.backgroundSecondary.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    private func photosSection(_ urls: [URL], title: String) -> some View {
        detailSection(title: "공유 앨범", trailing: "전체 보기") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(urls.enumerated()), id: \.offset) { _, url in
                        RemoteImage(url: url)
                            .frame(width: 120, height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
    }

    private func detailSection<Content: View>(
        title: String,
        trailing: String? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CelinkTheme.primaryDeep)
                    .textCase(.uppercase)
                    .tracking(1)

                Spacer()

                if let trailing {
                    Text(trailing)
                        .font(.caption)
                        .foregroundStyle(CelinkTheme.inkMuted)
                }
            }

            content()
        }
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
