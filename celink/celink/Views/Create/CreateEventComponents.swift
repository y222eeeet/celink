import SwiftUI

extension EventLabels {
    static func typeIcon(_ type: EventType) -> String {
        switch type {
        case .wedding: "heart.fill"
        case .exhibition: "paintpalette.fill"
        case .performance: "music.note"
        case .dol: "gift.fill"
        }
    }

    static func typeSubtitle(_ type: EventType) -> String {
        switch type {
        case .wedding: "결혼식 초대와 식순"
        case .exhibition: "전시·오프닝 안내"
        case .performance: "공연 일정과 좌석"
        case .dol: "돌잔치 초대"
        }
    }
}

struct CreateStepIndicator: View {
    let current: Int
    let total: Int
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("STEP \(current + 1) / \(total)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CelinkTheme.primaryDeep)

                Spacer()

                Text(title)
                    .font(.caption)
                    .foregroundStyle(CelinkTheme.inkMuted)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(CelinkTheme.border)
                        .frame(height: 4)

                    Capsule()
                        .fill(CelinkTheme.primary)
                        .frame(
                            width: geo.size.width * CGFloat(current + 1) / CGFloat(total),
                            height: 4
                        )
                }
            }
            .frame(height: 4)
        }
    }
}

struct CelinkFormField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var axis: Axis = .horizontal

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(CelinkTheme.ink)

            TextField(placeholder, text: $text, axis: axis)
                .font(.body)
                .foregroundStyle(CelinkTheme.ink)
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

struct CelinkPrimaryButton: View {
    let title: String
    var disabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(disabled ? CelinkTheme.primary.opacity(0.4) : CelinkTheme.primaryDeep)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(disabled)
    }
}

struct CelinkSecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body.weight(.medium))
                .foregroundStyle(CelinkTheme.primaryDeep)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(CelinkTheme.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(CelinkTheme.border, lineWidth: 1)
                }
        }
    }
}
