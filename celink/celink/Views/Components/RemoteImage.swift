import SwiftUI

/// 부모가 지정한 frame 안에서 이미지를 채웁니다. 반드시 `.frame(width:height:)` 와 함께 사용하세요.
struct RemoteImage: View {
    let url: URL

    var body: some View {
        AsyncImage(url: url) { phase in
            Group {
                switch phase {
                case .empty:
                    CelinkTheme.backgroundSecondary
                        .overlay {
                            ProgressView()
                                .tint(CelinkTheme.primaryDeep)
                        }
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    CelinkTheme.backgroundSecondary
                        .overlay {
                            Image(systemName: "photo")
                                .font(.title3)
                                .foregroundStyle(CelinkTheme.inkMuted)
                        }
                @unknown default:
                    CelinkTheme.backgroundSecondary
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .clipped()
    }
}
