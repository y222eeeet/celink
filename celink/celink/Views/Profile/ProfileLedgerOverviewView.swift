import SwiftUI

struct ProfileLedgerOverviewView: View {
    @Bindable private var interactionStore = EventInteractionStore.shared

    private var receivedByEvent: [EventLedgerOverview] {
        interactionStore.receivedOverviewByOwnedEvent()
    }

    private var sentGifts: [SentGiftEntry] {
        interactionStore.sentGiftOverview()
    }

    private var totalReceived: Int {
        receivedByEvent.reduce(0) { $0 + $1.amount }
    }

    private var totalSent: Int {
        interactionStore.totalSentAmount()
    }

    private var currentLedgerAmount: Int {
        interactionStore.currentLedgerAmount()
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                EventSubpageHeader(
                    title: "장부 상세",
                    eventTitle: "\(MockData.userName)님의 축하금 현황",
                    subtitle: "이벤트별 수령 금액과 내가 보낸 금액을 확인해요"
                )

                summaryCard

                ledgerSection(
                    title: "내가 주최한 이벤트 수령 금액",
                    trailing: "\(receivedByEvent.count)개"
                ) {
                    if receivedByEvent.isEmpty {
                        emptyRow("아직 수령 내역이 없어요")
                    } else {
                        ForEach(receivedByEvent) { item in
                            amountRow(title: item.eventTitle, amount: item.amount)
                        }
                    }
                }

                ledgerSection(
                    title: "내가 보낸 축하금",
                    trailing: "\(sentGifts.count)건"
                ) {
                    if sentGifts.isEmpty {
                        emptyRow("아직 보낸 내역이 없어요")
                    } else {
                        ForEach(sentGifts) { item in
                            amountRow(title: item.eventTitle, amount: item.amount)
                        }
                    }
                }
            }
            .padding(.horizontal, CelinkLayout.horizontalPadding)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(CelinkTheme.background)
        .navigationTitle("장부 열기")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(CelinkTheme.background, for: .navigationBar)
    }

    private var summaryCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("총 받은 축하금")
                    .font(.caption)
                    .foregroundStyle(CelinkTheme.inkMuted)
                Spacer()
                Text(formatAmount(totalReceived))
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(CelinkTheme.primaryDeep)
            }
            HStack {
                Text("총 보낸 축하금")
                    .font(.caption)
                    .foregroundStyle(CelinkTheme.inkMuted)
                Spacer()
                Text(formatAmount(totalSent))
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(CelinkTheme.ink)
            }
            Divider()
            HStack {
                Text("현재 장부 금액")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(CelinkTheme.ink)
                Spacer()
                Text(formatAmount(currentLedgerAmount))
                    .font(.title3.weight(.bold))
                    .foregroundStyle(CelinkTheme.primaryDeep)
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

    private func ledgerSection<Content: View>(
        title: String,
        trailing: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(title: title, trailing: trailing)
            VStack(spacing: 8) {
                content()
            }
        }
    }

    private func amountRow(title: String, amount: Int) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(CelinkTheme.ink)
            Spacer()
            Text(formatAmount(amount))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(CelinkTheme.primaryDeep)
        }
        .padding(12)
        .background(CelinkTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(CelinkTheme.border, lineWidth: 1)
        }
    }

    private func emptyRow(_ message: String) -> some View {
        Text(message)
            .font(.caption)
            .foregroundStyle(CelinkTheme.inkMuted)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(CelinkTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(CelinkTheme.border, lineWidth: 1)
            }
    }

    private func formatAmount(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let text = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        return "\(text)원"
    }
}

#Preview {
    NavigationStack {
        ProfileLedgerOverviewView()
    }
}
