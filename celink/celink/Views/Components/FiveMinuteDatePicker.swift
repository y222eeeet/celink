import SwiftUI
import UIKit

// MARK: - 시간 휠 (5분 간격)

struct FiveMinuteTimeWheelPicker: UIViewRepresentable {
    @Binding var date: Date
    var minimumDate: Date?

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UIDatePicker {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .wheels
        picker.minuteInterval = 5
        picker.locale = Locale(identifier: "ko_KR")
        if let minimumDate {
            picker.minimumDate = DateRounding.toFiveMinuteInterval(minimumDate)
        }
        picker.date = clampedDate(date)
        picker.addTarget(
            context.coordinator,
            action: #selector(Coordinator.valueChanged(_:)),
            for: .valueChanged
        )
        return picker
    }

    func updateUIView(_ uiView: UIDatePicker, context: Context) {
        uiView.minuteInterval = 5
        if let minimumDate {
            uiView.minimumDate = DateRounding.toFiveMinuteInterval(minimumDate)
        } else {
            uiView.minimumDate = nil
        }
        let clamped = clampedDate(date)
        if abs(uiView.date.timeIntervalSince(clamped)) > 60 {
            uiView.date = clamped
        }
    }

    private func clampedDate(_ value: Date) -> Date {
        let rounded = DateRounding.toFiveMinuteInterval(value)
        guard let minimumDate else { return rounded }
        return max(rounded, DateRounding.toFiveMinuteInterval(minimumDate))
    }

    final class Coordinator: NSObject {
        var parent: FiveMinuteTimeWheelPicker

        init(parent: FiveMinuteTimeWheelPicker) {
            self.parent = parent
        }

        @objc func valueChanged(_ sender: UIDatePicker) {
            let merged = DateRounding.mergeTime(
                from: sender.date,
                keepingDayFrom: parent.date
            )
            parent.date = parent.clampedDate(merged)
        }
    }
}

// MARK: - 폼 필드 (탭 → 선택 → 확인)

private enum CelinkDatePickerLayout {
    /// graphical DatePicker( UICalendarView )가 압축되지 않는 최소 높이
    static let graphicalCalendarHeight: CGFloat = 340
}

struct CelinkDatePickerField: View {
    let label: String
    @Binding var date: Date

    @State private var mode: PickerMode = .collapsed
    @State private var workingDate = Date()

    private enum PickerMode {
        case collapsed
        case pickingDate
        case pickingTime
    }

    private var dateDisplayText: String {
        date.formatted(
            .dateTime
                .locale(Locale(identifier: "ko_KR"))
                .year()
                .month(.wide)
                .day()
                .weekday(.short)
        )
    }

    private var timeDisplayText: String {
        date.formatted(
            .dateTime
                .locale(Locale(identifier: "ko_KR"))
                .hour()
                .minute()
        )
    }

    private var calendarBinding: Binding<Date> {
        Binding(
            get: { workingDate },
            set: { newDay in
                workingDate = DateRounding.mergeDay(from: newDay, keepingTimeFrom: workingDate)
            }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(label)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(CelinkTheme.ink)

            VStack(spacing: 0) {
                switch mode {
                case .collapsed:
                    collapsedRows
                case .pickingDate:
                    datePickerPanel
                case .pickingTime:
                    timePickerPanel
                }
            }
            .background(CelinkTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(CelinkTheme.border, lineWidth: 1)
            }
            .animation(nil, value: mode)
        }
    }

    private func setMode(_ newMode: PickerMode) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            mode = newMode
        }
    }

    // MARK: - 접힌 상태 (요약만 표시)

    private var collapsedRows: some View {
        VStack(spacing: 0) {
            pickerRow(
                title: "날짜",
                value: dateDisplayText,
                icon: "calendar"
            ) {
                workingDate = DateRounding.toFiveMinuteInterval(date)
                setMode(.pickingDate)
            }

            Divider().background(CelinkTheme.border).padding(.leading, 14)

            pickerRow(
                title: "시간",
                value: timeDisplayText,
                icon: "clock"
            ) {
                workingDate = DateRounding.toFiveMinuteInterval(date)
                setMode(.pickingTime)
            }
        }
    }

    private func pickerRow(
        title: String,
        value: String,
        icon: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(CelinkTheme.primary)
                    .frame(width: 22)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.caption)
                        .foregroundStyle(CelinkTheme.inkMuted)
                    Text(value)
                        .font(.body)
                        .foregroundStyle(CelinkTheme.ink)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CelinkTheme.inkMuted)
            }
            .padding(14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - 날짜 선택 (달력)

    private var datePickerPanel: some View {
        VStack(spacing: 12) {
            panelHeader(title: "날짜 선택")

            DatePicker(
                "날짜",
                selection: calendarBinding,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .labelsHidden()
            .environment(\.locale, Locale(identifier: "ko_KR"))
            .tint(CelinkTheme.primaryDeep)
            .compositingGroup()
            .frame(maxWidth: .infinity)
            .frame(height: CelinkDatePickerLayout.graphicalCalendarHeight)
            .layoutPriority(1)
            .padding(.horizontal, 4)

            dualButtons(
                leadingTitle: "취소",
                leadingAction: cancelPicking,
                trailingTitle: "확인",
                trailingAction: confirmDate
            )
        }
        .padding(.bottom, 8)
    }

    // MARK: - 시간 선택 (휠)

    private var timePickerPanel: some View {
        VStack(spacing: 8) {
            panelHeader(title: "시간 선택")

            Text(dateDisplayText)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(CelinkTheme.primaryDeep)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 14)

            FiveMinuteTimeWheelPicker(date: $workingDate)
                .frame(maxWidth: .infinity)
                .frame(height: 160)

            dualButtons(
                leadingTitle: "이전",
                leadingAction: goBackToDatePicker,
                trailingTitle: "확인",
                trailingAction: confirmTime
            )
        }
        .padding(.bottom, 8)
    }

    // MARK: - 공통 UI

    private func panelHeader(title: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(CelinkTheme.ink)
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.top, 14)
    }

    private func dualButtons(
        leadingTitle: String,
        leadingAction: @escaping () -> Void,
        trailingTitle: String,
        trailingAction: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 10) {
            Button(action: leadingAction) {
                Text(leadingTitle)
                    .font(.body.weight(.medium))
                    .foregroundStyle(CelinkTheme.primaryDeep)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(CelinkTheme.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(CelinkTheme.border, lineWidth: 1)
                    }
            }

            Button(action: trailingAction) {
                Text(trailingTitle)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(CelinkTheme.primaryDeep)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(.horizontal, 14)
    }

    private func confirmDate() {
        date = DateRounding.mergeDay(from: workingDate, keepingTimeFrom: date)
        workingDate = date
        setMode(.pickingTime)
    }

    private func confirmTime() {
        date = DateRounding.toFiveMinuteInterval(workingDate)
        setMode(.collapsed)
    }

    private func goBackToDatePicker() {
        setMode(.pickingDate)
    }

    private func cancelPicking() {
        workingDate = date
        setMode(.collapsed)
    }
}
