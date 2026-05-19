import Foundation

enum EventFormatting {
    static func greeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "좋은 아침이에요" }
        if hour < 18 { return "좋은 오후예요" }
        return "좋은 저녁이에요"
    }

    static func eventDate(_ date: Date) -> String {
        date.formatted(
            .dateTime
                .locale(Locale(identifier: "ko_KR"))
                .month(.wide)
                .day()
                .weekday(.short)
                .hour()
                .minute()
        )
    }

    static func relativeDate(_ date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
        if days < 1 { return "오늘" }
        if days == 1 { return "어제" }
        if days < 7 { return "\(days)일 전" }
        if days < 30 { return "\(days / 7)주 전" }
        return date.formatted(.dateTime.locale(Locale(identifier: "ko_KR")).month(.abbreviated).day())
    }

    static func dDay(from eventDate: Date) -> String? {
        let calendar = Calendar.current
        let startToday = calendar.startOfDay(for: Date())
        let startEvent = calendar.startOfDay(for: eventDate)
        let days = calendar.dateComponents([.day], from: startToday, to: startEvent).day ?? 0
        if days < 0 { return nil }
        if days == 0 { return "D-Day" }
        return "D-\(days)"
    }
}
