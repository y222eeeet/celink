import SwiftUI

enum CelinkTheme {
    /// 앱 배경 — 연보라 화이트
    static let background = Color(red: 248 / 255, green: 246 / 255, blue: 252 / 255)
    /// 카드·스켈레톤 배경
    static let backgroundSecondary = Color(red: 238 / 255, green: 233 / 255, blue: 248 / 255)
    /// 본문·제목
    static let ink = Color(red: 42 / 255, green: 36 / 255, blue: 56 / 255)
    static let inkMuted = Color(red: 110 / 255, green: 102 / 255, blue: 128 / 255)
    /// 메인 — 연보라
    static let primary = Color(red: 159 / 255, green: 143 / 255, blue: 239 / 255)
    /// 강조·탭·버튼
    static let primaryDeep = Color(red: 117 / 255, green: 102 / 255, blue: 217 / 255)
    /// 테두리·구분선
    static let border = Color(red: 221 / 255, green: 214 / 255, blue: 243 / 255)
    /// 카드 표면
    static let surface = Color.white

    // 이전 이름 호환 (점진적 제거 가능)
    static var cream: Color { background }
    static var creamDark: Color { backgroundSecondary }
    static var rose: Color { primary }
    static var roseDeep: Color { primaryDeep }
    static var blush: Color { border }
}

enum EventLabels {
    static func typeName(_ type: EventType) -> String {
        switch type {
        case .wedding: "결혼식"
        case .exhibition: "전시"
        case .performance: "공연"
        case .dol: "돌잔치"
        }
    }

    /// 제목 입력 필드 placeholder
    static func titlePlaceholder(for type: EventType) -> String {
        switch type {
        case .wedding: "김민수와 김서연의 결혼식"
        case .exhibition: "숙명여대 시각디자인과 졸업 전시"
        case .performance: "숙명여대 무용과 라이브 공연"
        case .dol: "규민이의 첫 번째 생일잔치"
        }
    }

    static func rsvpName(_ status: RSVPStatus) -> String {
        switch status {
        case .pending: "미응답"
        case .yes: "참석"
        case .no: "불참"
        case .maybe: "미정"
        }
    }

    static func rsvpColors(_ status: RSVPStatus) -> (background: Color, foreground: Color) {
        switch status {
        case .pending:
            (CelinkTheme.backgroundSecondary, CelinkTheme.inkMuted)
        case .yes:
            (Color(red: 237 / 255, green: 233 / 255, blue: 254 / 255), CelinkTheme.primaryDeep)
        case .no:
            (CelinkTheme.backgroundSecondary, CelinkTheme.inkMuted.opacity(0.8))
        case .maybe:
            (Color(red: 245 / 255, green: 240 / 255, blue: 255 / 255), Color(red: 107 / 255, green: 78 / 255, blue: 185 / 255))
        }
    }

    static func rsvpIcon(_ status: RSVPStatus) -> String {
        switch status {
        case .pending: "questionmark.circle"
        case .yes: "checkmark.circle.fill"
        case .no: "xmark.circle.fill"
        case .maybe: "clock.fill"
        }
    }

    static func rsvpSubtitle(_ status: RSVPStatus) -> String {
        switch status {
        case .pending: "아직 응답하지 않았어요"
        case .yes: "행사에 참석할 예정이에요"
        case .no: "참석이 어려워요"
        case .maybe: "일정 확인 후 다시 알려드릴게요"
        }
    }
}
