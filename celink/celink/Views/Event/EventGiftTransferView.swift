import SwiftUI

struct EventGiftTransferView: View {
    let eventId: String
    @Environment(\.dismiss) private var dismiss
    @Bindable private var interactionStore = EventInteractionStore.shared

    @State private var selectedAmount: Int?
    @State private var customAmountText = ""
    @State private var showCompleteAlert = false

    private let presetAmounts = [10_000, 30_000, 50_000, 100_000]

    private var detail: EventDetail? {
        interactionStore.eventDetail(id: eventId)
    }

    private var finalAmount: Int? {
        if let selectedAmount { return selectedAmount }
        let digits = customAmountText.filter(\.isNumber)
        return Int(digits)
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
        .navigationTitle("축하하기")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(CelinkTheme.background, for: .navigationBar)
        .alert("결제가 완료되었습니다", isPresented: $showCompleteAlert) {
            Button("확인") { dismiss() }
        } message: {
            Text("\(formattedCurrency(finalAmount ?? 0))을 축하금으로 전달했어요.")
        }
    }

    private func content(_ detail: EventDetail) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                EventSubpageHeader(
                    title: "앱 내 결제",
                    eventTitle: detail.summary.title,
                    subtitle: "축하금을 안전하게 전달할 수 있어요"
                )

                VStack(alignment: .leading, spacing: 12) {
                    Text("금액 선택")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(CelinkTheme.ink)

                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: 10
                    ) {
                        ForEach(presetAmounts, id: \.self) { amount in
                            amountButton(amount)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("직접 입력")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(CelinkTheme.ink)

                    TextField("예: 20000", text: $customAmountText)
                        .keyboardType(.numberPad)
                        .font(.body)
                        .foregroundStyle(CelinkTheme.ink)
                        .padding(14)
                        .background(CelinkTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(CelinkTheme.border, lineWidth: 1)
                        }
                        .onChange(of: customAmountText) { _, newValue in
                            let digits = newValue.filter(\.isNumber)
                            if digits != newValue {
                                customAmountText = digits
                            }
                            if !digits.isEmpty {
                                selectedAmount = nil
                            }
                        }
                }

                if let finalAmount {
                    Text("결제 금액: \(formattedCurrency(finalAmount))")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(CelinkTheme.primaryDeep)
                }

                CelinkPrimaryButton(
                    title: "결제하기",
                    disabled: (finalAmount ?? 0) <= 0
                ) {
                    showCompleteAlert = true
                }
            }
            .padding(.horizontal, CelinkLayout.horizontalPadding)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
    }

    private func amountButton(_ amount: Int) -> some View {
        let isSelected = selectedAmount == amount

        return Button {
            selectedAmount = amount
            customAmountText = ""
        } label: {
            Text(formattedCurrency(amount))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? CelinkTheme.primaryDeep : CelinkTheme.ink)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(isSelected ? CelinkTheme.backgroundSecondary : CelinkTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? CelinkTheme.primary : CelinkTheme.border, lineWidth: isSelected ? 2 : 1)
                }
        }
        .buttonStyle(.plain)
    }

    private func formattedCurrency(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let number = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        return "\(number)원"
    }
}

#Preview {
    NavigationStack {
        EventGiftTransferView(eventId: "evt-1")
    }
}
