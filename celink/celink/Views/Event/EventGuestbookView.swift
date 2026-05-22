import SwiftUI

struct EventGuestbookView: View {
    let eventId: String
    @Bindable private var interactionStore = EventInteractionStore.shared

    @State private var authorName = MockData.userName
    @State private var message = ""
    @State private var isPrivate = false
    @FocusState private var messageFocused: Bool

    private var detail: EventDetail? {
        interactionStore.eventDetail(id: eventId)
    }

    private var entries: [GuestbookEntry] {
        interactionStore.guestbookEntries(for: eventId)
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
        .navigationTitle("방명록")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(CelinkTheme.background, for: .navigationBar)
    }

    private func content(_ detail: EventDetail) -> some View {
        VStack(spacing: 0) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    EventSubpageHeader(
                        title: "방명록",
                        eventTitle: detail.summary.title,
                        subtitle: "\(entries.count)개의 메시지"
                    )

                    if entries.isEmpty {
                        emptyState
                    } else {
                        VStack(spacing: 10) {
                            ForEach(entries) { entry in
                                guestbookCard(entry)
                            }
                        }
                    }
                }
                .padding(.horizontal, CelinkLayout.horizontalPadding)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }

            composeBar
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "text.quote")
                .font(.largeTitle)
                .foregroundStyle(CelinkTheme.primary.opacity(0.7))

            Text("첫 번째 축하 메시지를 남겨보세요")
                .font(.subheadline)
                .foregroundStyle(CelinkTheme.inkMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
        .background(CelinkTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: CelinkLayout.cardCornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: CelinkLayout.cardCornerRadius)
                .stroke(CelinkTheme.border, lineWidth: 1)
        }
    }

    private func guestbookCard(_ entry: GuestbookEntry) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.isPrivate ? "비공개 메시지" : entry.authorName)
                    .font(.subheadline.weight(.semibold))
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
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CelinkTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(CelinkTheme.border, lineWidth: 1)
        }
    }

    private var composeBar: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider().background(CelinkTheme.border)

            TextField("이름", text: $authorName)
                .font(.subheadline)
                .foregroundStyle(CelinkTheme.ink)
                .padding(12)
                .background(CelinkTheme.backgroundSecondary.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            TextField("축하 메시지를 입력해 주세요", text: $message, axis: .vertical)
                .lineLimit(2...4)
                .focused($messageFocused)
                .font(.body)
                .foregroundStyle(CelinkTheme.ink)
                .padding(12)
                .background(CelinkTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(CelinkTheme.border, lineWidth: 1)
                }

            Toggle(isOn: $isPrivate) {
                Text("비공개 메시지 (호스트만 보기)")
                    .font(.caption)
                    .foregroundStyle(CelinkTheme.inkMuted)
            }
            .tint(CelinkTheme.primaryDeep)

            CelinkPrimaryButton(
                title: "메시지 남기기",
                disabled: message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ) {
                submitMessage()
            }
        }
        .padding(.horizontal, CelinkLayout.horizontalPadding)
        .padding(.top, 12)
        .padding(.bottom, 16)
        .background(CelinkTheme.background)
    }

    private func submitMessage() {
        guard interactionStore.addGuestbookEntry(
            eventId: eventId,
            authorName: authorName,
            content: message,
            isPrivate: isPrivate
        ) != nil else { return }

        message = ""
        isPrivate = false
        messageFocused = false
    }
}

#Preview {
    NavigationStack {
        EventGuestbookView(eventId: "evt-1")
    }
}
