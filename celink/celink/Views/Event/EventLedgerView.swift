import SwiftUI

struct EventLedgerView: View {
    let eventId: String
    @Bindable private var interactionStore = EventInteractionStore.shared

    private var detail: EventDetail? {
        interactionStore.eventDetail(id: eventId)
    }

    private var entries: [CelebrationLedgerEntry] {
        interactionStore.ledgerEntries(for: eventId)
    }

    private var totalAmount: Int {
        entries.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        Group {
            if let detail {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        EventSubpageHeader(
                            title: "장부",
                            eventTitle: detail.summary.title,
                            subtitle: "축하금을 전달한 내역을 확인해요"
                        )

                        HStack {
                            Text("총 \(entries.count)명")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(CelinkTheme.inkMuted)
                            Spacer()
                            Text("합계 \(formattedAmount(totalAmount))")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(CelinkTheme.primaryDeep)
                        }
                        .padding(14)
                        .background(CelinkTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(CelinkTheme.border, lineWidth: 1)
                        }

                        if entries.isEmpty {
                            Text("아직 전달받은 내역이 없어요.")
                                .font(.subheadline)
                                .foregroundStyle(CelinkTheme.inkMuted)
                                .padding(.top, 12)
                        } else {
                            VStack(spacing: 10) {
                                ForEach(entries) { entry in
                                    HStack(spacing: 12) {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(entry.senderName)
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(CelinkTheme.ink)
                                            Text(entry.relation.rawValue)
                                                .font(.caption)
                                                .foregroundStyle(CelinkTheme.inkMuted)
                                        }
                                        Spacer()
                                        Text(formattedAmount(entry.amount))
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(CelinkTheme.primaryDeep)
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
        .navigationTitle("장부 확인하기")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(CelinkTheme.background, for: .navigationBar)
    }

    private func formattedAmount(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let result = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        return "\(result)원"
    }
}

#Preview {
    NavigationStack {
        EventLedgerView(eventId: "owned-birthday-1")
    }
}
