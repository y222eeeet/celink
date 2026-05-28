import SwiftUI

struct ProfileWithdrawView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable private var interactionStore = EventInteractionStore.shared

    @State private var amountText = ""
    @State private var flowState: WithdrawFlowState = .input

    private var availableAmount: Int {
        interactionStore.availableLedgerAmount()
    }

    private var requestedAmount: Int {
        Int(amountText.filter(\.isNumber)) ?? 0
    }

    private var finalAmount: Int {
        min(requestedAmount, availableAmount)
    }

    var body: some View {
        Group {
            switch flowState {
            case .input:
                inputView
            case .pgConnecting:
                blankStatusView("PG사 연동화면")
            case .success:
                blankStatusView("송금완료")
            }
        }
        .background(CelinkTheme.background)
        .navigationTitle("출금하기")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(CelinkTheme.background, for: .navigationBar)
    }

    private var inputView: some View {
        VStack(alignment: .leading, spacing: 20) {
            EventSubpageHeader(
                title: "장부 출금",
                eventTitle: "프로필",
                subtitle: "원하는 금액을 입력해 출금할 수 있어요"
            )

            VStack(alignment: .leading, spacing: 8) {
                Text("출금 가능 금액")
                    .font(.caption)
                    .foregroundStyle(CelinkTheme.inkMuted)
                Text(formattedCurrency(availableAmount))
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(CelinkTheme.primaryDeep)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(CelinkTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(CelinkTheme.border, lineWidth: 1)
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("출금 금액")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(CelinkTheme.ink)
                    Spacer()
                    Button("전체") {
                        amountText = "\(availableAmount)"
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CelinkTheme.primaryDeep)
                }

                TextField("예: 50000", text: $amountText)
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
                    .onChange(of: amountText) { _, newValue in
                        let digits = newValue.filter(\.isNumber)
                        if digits != newValue {
                            amountText = digits
                        }
                    }
            }

            if requestedAmount > 0 {
                Text("출금 예정 금액: \(formattedCurrency(finalAmount))")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(CelinkTheme.primaryDeep)
            }

            Spacer(minLength: 0)

            CelinkPrimaryButton(
                title: "출금하기",
                disabled: finalAmount <= 0
            ) {
                startWithdrawFlow()
            }
        }
        .padding(.horizontal, CelinkLayout.horizontalPadding)
        .padding(.top, 8)
        .padding(.bottom, 24)
    }

    private func blankStatusView(_ title: String) -> some View {
        ZStack {
            CelinkTheme.background.ignoresSafeArea()
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(CelinkTheme.ink)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private func startWithdrawFlow() {
        let acceptedAmount = interactionStore.withdrawFromLedger(finalAmount)
        guard acceptedAmount > 0 else { return }
        flowState = .pgConnecting

        Task {
            try? await Task.sleep(for: .seconds(3))
            await MainActor.run {
                flowState = .success
            }
            try? await Task.sleep(for: .seconds(2))
            await MainActor.run {
                dismiss()
            }
        }
    }

    private func formattedCurrency(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let number = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        return "\(number)원"
    }
}

private enum WithdrawFlowState {
    case input
    case pgConnecting
    case success
}

#Preview {
    NavigationStack {
        ProfileWithdrawView()
    }
}
