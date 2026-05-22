import SwiftUI

enum EventDetailDestination: Hashable {
    case rsvp
    case guestbook
    case photoAlbum
}

struct EventSubpageHeader: View {
    let title: String
    let eventTitle: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 26, weight: .medium, design: .serif))
                .foregroundStyle(CelinkTheme.ink)

            Text(eventTitle)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(CelinkTheme.primaryDeep)

            if let subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(CelinkTheme.inkMuted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct EventInfoMiniCard: View {
    let dateText: String
    let location: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(dateText, systemImage: "calendar")
            Label(location, systemImage: "mappin.and.ellipse")
        }
        .font(.subheadline)
        .foregroundStyle(CelinkTheme.ink)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(CelinkTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: CelinkLayout.cardCornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: CelinkLayout.cardCornerRadius)
                .stroke(CelinkTheme.border, lineWidth: 1)
        }
    }
}
