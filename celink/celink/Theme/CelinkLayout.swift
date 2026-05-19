import SwiftUI

/// iPhone 화면 너비 기준 레이아웃 (패딩·썸네일·그리드 셀 크기)
enum CelinkLayout {
    static let horizontalPadding: CGFloat = 20
    static let sectionSpacing: CGFloat = 32
    static let itemSpacing: CGFloat = 12
    static let cardCornerRadius: CGFloat = 16
    static let photoGridColumns = 4
    static let photoGridSpacing: CGFloat = 6
    static let standardThumbnail: CGFloat = 104
    static let compactThumbnail: CGFloat = 72

    /// 스크롤 콘텐츠 하단 (탭 바 여유)
    static let scrollBottomInset: CGFloat = 24

    static func contentWidth(in containerWidth: CGFloat) -> CGFloat {
        max(0, containerWidth - horizontalPadding * 2)
    }

    static func photoCellSize(contentWidth: CGFloat) -> CGFloat {
        let gaps = photoGridSpacing * CGFloat(photoGridColumns - 1)
        return floor((contentWidth - gaps) / CGFloat(photoGridColumns))
    }

    /// 대표 카드 4:5 (세로형)
    static func featuredCardHeight(contentWidth: CGFloat) -> CGFloat {
        contentWidth * 5 / 4
    }
}
