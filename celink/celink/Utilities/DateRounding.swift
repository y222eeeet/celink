import Foundation

enum DateRounding {
    /// 분을 5분 단위로 맞춥니다 (0, 5, 10, … 55).
    static func toFiveMinuteInterval(_ date: Date) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        let minute = components.minute ?? 0
        components.minute = (minute / 5) * 5
        components.second = 0
        components.nanosecond = 0
        return calendar.date(from: components) ?? date
    }

    /// 달력에서 고른 날짜 + 기존 시각 유지
    static func mergeDay(from newDay: Date, keepingTimeFrom source: Date) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: newDay)
        let time = calendar.dateComponents([.hour, .minute], from: source)
        components.hour = time.hour
        components.minute = time.minute
        components.second = 0
        components.nanosecond = 0
        return toFiveMinuteInterval(calendar.date(from: components) ?? newDay)
    }

    /// 시간 휠에서 고른 시각 + 기존 날짜 유지
    static func mergeTime(from newTime: Date, keepingDayFrom source: Date) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: source)
        let time = calendar.dateComponents([.hour, .minute], from: newTime)
        components.hour = time.hour
        components.minute = time.minute
        components.second = 0
        components.nanosecond = 0
        return toFiveMinuteInterval(calendar.date(from: components) ?? source)
    }
}
