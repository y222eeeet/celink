import SwiftUI

struct SectionHeaderView: View {
    let title: String
    var trailing: String? = nil
    var trailingAction: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(CelinkTheme.primaryDeep)
                .textCase(.uppercase)
                .tracking(1.2)

            Spacer(minLength: 8)

            if let trailing {
                if let trailingAction {
                    Button(trailing, action: trailingAction)
                        .font(.caption)
                        .foregroundStyle(CelinkTheme.inkMuted)
                } else {
                    Text(trailing)
                        .font(.caption)
                        .foregroundStyle(CelinkTheme.inkMuted)
                }
            }
        }
    }
}
