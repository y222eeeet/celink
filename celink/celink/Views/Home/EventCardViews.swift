import SwiftUI

enum EventCardStyle {
    case featured, standard, compact
}

struct EventCardView: View {
    let event: EventSummary
    var style: EventCardStyle = .standard
    var contentWidth: CGFloat = 335

    private var dDay: String? {
        guard event.isUpcoming else { return nil }
        return EventFormatting.dDay(from: event.date)
    }

    private var rsvpStyle: (background: Color, foreground: Color) {
        EventLabels.rsvpColors(event.rsvpStatus)
    }

    private var featuredHeight: CGFloat {
        CelinkLayout.featuredCardHeight(contentWidth: contentWidth)
    }

    var body: some View {
        switch style {
        case .featured:
            featuredCard
        case .standard:
            standardCard
        case .compact:
            compactCard
        }
    }

    private var featuredCard: some View {
        ZStack(alignment: .bottomLeading) {
            RemoteImage(url: event.coverImageURL)
                .frame(width: contentWidth, height: featuredHeight)

            LinearGradient(
                colors: [.clear, .black.opacity(0.35), .black.opacity(0.88)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 6) {
                if let dDay {
                    Text(dDay)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.white.opacity(0.22))
                        .clipShape(Capsule())
                }
                Text(EventLabels.typeName(event.type))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.75))
                Text(event.title)
                    .font(.title3.weight(.medium))
                    .fontDesign(.serif)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Text(EventFormatting.eventDate(event.date))
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
                Text(event.location)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.65))
                    .lineLimit(1)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: contentWidth, height: featuredHeight)
        .clipShape(RoundedRectangle(cornerRadius: CelinkLayout.cardCornerRadius))
        .shadow(color: .black.opacity(0.1), radius: 10, y: 4)
    }

    private var standardCard: some View {
        HStack(alignment: .center, spacing: 0) {
            ZStack(alignment: .topLeading) {
                RemoteImage(url: event.coverImageURL)
                    .frame(
                        width: CelinkLayout.standardThumbnail,
                        height: CelinkLayout.standardThumbnail
                    )

                if let dDay {
                    Text(dDay)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(CelinkTheme.primaryDeep)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(CelinkTheme.background.opacity(0.95))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .padding(6)
                }
            }
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: CelinkLayout.cardCornerRadius,
                    bottomLeadingRadius: CelinkLayout.cardCornerRadius,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 0
                )
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(EventLabels.typeName(event.type))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(CelinkTheme.primaryDeep)
                    .textCase(.uppercase)

                Text(event.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(CelinkTheme.ink)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text("\(EventFormatting.eventDate(event.date)) · \(event.location)")
                    .font(.caption)
                    .foregroundStyle(CelinkTheme.inkMuted)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 6) {
                    Text(EventLabels.rsvpName(event.rsvpStatus))
                        .font(.system(size: 10, weight: .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(rsvpStyle.background)
                        .foregroundStyle(rsvpStyle.foreground)
                        .clipShape(RoundedRectangle(cornerRadius: 6))

                    Text("\(event.hostName)님의 초대")
                        .font(.system(size: 10))
                        .foregroundStyle(CelinkTheme.inkMuted)
                        .lineLimit(1)
                }
                .padding(.top, 2)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: contentWidth)
        .frame(minHeight: CelinkLayout.standardThumbnail)
        .background(CelinkTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: CelinkLayout.cardCornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: CelinkLayout.cardCornerRadius)
                .stroke(CelinkTheme.border, lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }

    private var compactCard: some View {
        HStack(spacing: 12) {
            RemoteImage(url: event.coverImageURL)
                .frame(
                    width: CelinkLayout.compactThumbnail,
                    height: CelinkLayout.compactThumbnail
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(CelinkTheme.ink)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(EventFormatting.eventDate(event.date))
                    .font(.caption)
                    .foregroundStyle(CelinkTheme.inkMuted)
                    .lineLimit(1)

                Text(EventLabels.rsvpName(event.rsvpStatus))
                    .font(.system(size: 10, weight: .medium))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(rsvpStyle.background)
                    .foregroundStyle(rsvpStyle.foreground)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .frame(width: contentWidth, alignment: .leading)
        .background(CelinkTheme.surface.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(CelinkTheme.border, lineWidth: 1)
        }
    }
}
