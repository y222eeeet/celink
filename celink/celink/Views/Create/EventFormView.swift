import PhotosUI
import SwiftUI

struct EventFormView: View {
    @Bindable var viewModel: EventFormViewModel
    @Binding var photoItem: PhotosPickerItem?
    var showCreateAnother: Bool
    var onFinished: () -> Void
    var onCreateAnother: (() -> Void)?
    var onFormReset: (() -> Void)?
    var onViewCreatedEvent: ((String) -> Void)?

    var body: some View {
        GeometryReader { geometry in
            let contentWidth = CelinkLayout.contentWidth(in: geometry.size.width)

            VStack(spacing: 0) {
                header

                ScrollView(.vertical, showsIndicators: false) {
                    stepContent(contentWidth: contentWidth)
                        .padding(.horizontal, CelinkLayout.horizontalPadding)
                        .padding(.top, 8)
                        .padding(.bottom, 24)
                }

                bottomBar
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(CelinkTheme.background)
        }
        .background(CelinkTheme.background)
        .onChange(of: photoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    viewModel.markCoverChanged(data: data)
                }
            }
        }
        .sheet(isPresented: $viewModel.showSuccessSheet) {
            EventFormSuccessSheet(
                title: viewModel.successTitle,
                invitePath: viewModel.lastInvitePath,
                showCreateAnother: showCreateAnother,
                onPrimary: {
                    viewModel.showSuccessSheet = false
                    if viewModel.isEditMode {
                        onFinished()
                    } else if let eventId = viewModel.publishedEventId {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onViewCreatedEvent?(eventId)
                        }
                    }
                },
                onCreateAnother: {
                    viewModel.showSuccessSheet = false
                    viewModel.pendingResetOnNextAppear = false
                    viewModel.reset()
                    onFormReset?()
                    onCreateAnother?()
                }
            )
            .presentationDetents([.medium])
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.screenTitle)
                    .font(.system(size: 28, weight: .medium, design: .serif))
                    .foregroundStyle(CelinkTheme.ink)

                Text(viewModel.screenSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(CelinkTheme.inkMuted)
            }

            CreateStepIndicator(
                current: viewModel.stepIndex,
                total: viewModel.totalSteps,
                title: viewModel.step.title
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, CelinkLayout.horizontalPadding)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }

    @ViewBuilder
    private func stepContent(contentWidth: CGFloat) -> some View {
        switch viewModel.step {
        case .type:
            typeStep
        case .basics:
            basicsStep
        case .cover:
            coverStep
        case .schedule:
            scheduleStep
        case .preview:
            previewStep(contentWidth: contentWidth)
        }
    }

    private var typeStep: some View {
        VStack(spacing: 12) {
            ForEach(EventType.allCases, id: \.self) { type in
                Button {
                    viewModel.selectType(type)
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: EventLabels.typeIcon(type))
                            .font(.title2)
                            .foregroundStyle(
                                viewModel.selectedType == type
                                    ? CelinkTheme.primaryDeep
                                    : CelinkTheme.inkMuted
                            )
                            .frame(width: 44, height: 44)
                            .background(
                                viewModel.selectedType == type
                                    ? CelinkTheme.primary.opacity(0.25)
                                    : CelinkTheme.backgroundSecondary
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(EventLabels.typeName(type))
                                .font(.headline)
                                .foregroundStyle(CelinkTheme.ink)

                            Text(EventLabels.typeSubtitle(type))
                                .font(.caption)
                                .foregroundStyle(CelinkTheme.inkMuted)
                        }

                        Spacer()

                        if viewModel.selectedType == type {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(CelinkTheme.primaryDeep)
                        }
                    }
                    .padding(16)
                    .background(CelinkTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: CelinkLayout.cardCornerRadius))
                    .overlay {
                        RoundedRectangle(cornerRadius: CelinkLayout.cardCornerRadius)
                            .stroke(
                                viewModel.selectedType == type
                                    ? CelinkTheme.primary
                                    : CelinkTheme.border,
                                lineWidth: viewModel.selectedType == type ? 2 : 1
                            )
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var basicsStep: some View {
        VStack(spacing: 20) {
            CelinkFormField(
                label: "이벤트 제목",
                placeholder: viewModel.titlePlaceholder,
                text: $viewModel.title
            )

            CelinkDatePickerField(label: "날짜 및 시간", date: $viewModel.date)

            CelinkFormField(label: "장소", placeholder: "예: 서울 신라호텔", text: $viewModel.location)

            CelinkFormField(
                label: "설명",
                placeholder: "행사 소개를 입력해 주세요",
                text: $viewModel.description,
                axis: .vertical
            )

            CelinkFormField(label: "드레스코드 (선택)", placeholder: "예: 포멀", text: $viewModel.dressCode)

            CelinkFormField(label: "안내사항 (선택)", placeholder: "예: 화환 사양", text: $viewModel.notice)
        }
    }

    private var coverStep: some View {
        VStack(spacing: 16) {
            Text("대표 이미지를 선택하면 초대 페이지가 더 특별해져요.")
                .font(.subheadline)
                .foregroundStyle(CelinkTheme.inkMuted)
                .frame(maxWidth: .infinity, alignment: .leading)

            Group {
                if let data = viewModel.coverImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else if let url = viewModel.existingCoverURL {
                    RemoteImage(url: url)
                } else if let type = viewModel.selectedType {
                    RemoteImage(url: CreateEventDraft.defaultCoverURL(for: type))
                } else {
                    CelinkTheme.backgroundSecondary
                        .overlay {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.largeTitle)
                                .foregroundStyle(CelinkTheme.inkMuted)
                        }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: CelinkLayout.cardCornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: CelinkLayout.cardCornerRadius)
                    .stroke(CelinkTheme.border, lineWidth: 1)
            }

            PhotosPicker(selection: $photoItem, matching: .images) {
                Label(
                    viewModel.coverImageData == nil && viewModel.existingCoverURL == nil
                        ? "사진 선택하기"
                        : "다른 사진 선택",
                    systemImage: "photo.badge.plus"
                )
                .font(.body.weight(.medium))
                .foregroundStyle(CelinkTheme.primaryDeep)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(CelinkTheme.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            if viewModel.coverImageData != nil || viewModel.existingCoverURL != nil {
                Button("기본 이미지로 되돌리기") {
                    viewModel.resetCoverToDefault()
                    photoItem = nil
                }
                .font(.caption)
                .foregroundStyle(CelinkTheme.inkMuted)
            }
        }
    }

    private var scheduleStep: some View {
        VStack(spacing: 16) {
            HStack {
                Text("시간별 진행 순서를 추가해 주세요")
                    .font(.subheadline)
                    .foregroundStyle(CelinkTheme.inkMuted)

                Spacer()

                Button {
                    viewModel.addScheduleItem()
                } label: {
                    Label("추가", systemImage: "plus")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(CelinkTheme.primaryDeep)
                }
            }

            if viewModel.scheduleItems.isEmpty {
                Text(viewModel.isEditMode ? "식순이 없어도 저장할 수 있어요" : "식순이 없어도 발행할 수 있어요")
                    .font(.caption)
                    .foregroundStyle(CelinkTheme.inkMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            ForEach($viewModel.scheduleItems) { $item in
                VStack(spacing: 12) {
                    HStack {
                        Text("식순")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(CelinkTheme.primaryDeep)

                        Spacer()

                        if viewModel.scheduleItems.count > 1 {
                            Button {
                                viewModel.removeScheduleItem(id: item.id)
                            } label: {
                                Image(systemName: "trash")
                                    .font(.caption)
                                    .foregroundStyle(CelinkTheme.inkMuted)
                            }
                        }
                    }

                    CelinkDatePickerField(label: "날짜 및 시간", date: $item.time)

                    CelinkFormField(label: "항목", placeholder: "예: 예식", text: $item.title)
                    CelinkFormField(label: "메모 (선택)", placeholder: "예: 그랜드볼룸", text: $item.note)
                }
                .padding(16)
                .background(CelinkTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(CelinkTheme.border, lineWidth: 1)
                }
            }
        }
    }

    @ViewBuilder
    private func previewStep(contentWidth: CGFloat) -> some View {
        if let type = viewModel.selectedType {
            VStack(spacing: 16) {
                EventCardView(
                    event: EventSummary(
                        id: "preview",
                        type: type,
                        title: viewModel.title.isEmpty ? "이벤트 제목" : viewModel.title,
                        date: viewModel.date,
                        location: viewModel.location.isEmpty ? "장소" : viewModel.location,
                        coverImageURL: previewCoverURL(for: type),
                        hostName: MockData.userName,
                        rsvpStatus: .yes,
                        lastParticipatedAt: nil,
                        isUpcoming: true
                    ),
                    style: .featured,
                    contentWidth: contentWidth
                )

                previewRow("타입", value: EventLabels.typeName(type))
                previewRow("일시", value: EventFormatting.eventDate(viewModel.date))
                previewRow("장소", value: viewModel.location)

                if !viewModel.description.isEmpty {
                    previewRow("설명", value: viewModel.description)
                }

                if !viewModel.scheduleItems.filter({ !$0.title.isEmpty }).isEmpty {
                    previewRow(
                        "식순",
                        value: "\(viewModel.scheduleItems.filter { !$0.title.isEmpty }.count)개 항목"
                    )
                }

                Text(viewModel.previewFootnote)
                    .font(.caption)
                    .foregroundStyle(CelinkTheme.inkMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var bottomBar: some View {
        HStack(spacing: 12) {
            if viewModel.step != .type {
                CelinkSecondaryButton(title: "이전") {
                    viewModel.goBack()
                }
                .frame(width: 100)
            }

            CelinkPrimaryButton(
                title: viewModel.nextButtonTitle,
                disabled: !viewModel.canGoNext
            ) {
                viewModel.goNext()
            }
        }
        .padding(.horizontal, CelinkLayout.horizontalPadding)
        .padding(.vertical, 12)
        .padding(.bottom, 8)
        .background(CelinkTheme.surface.opacity(0.95))
        .overlay(alignment: .top) {
            Divider().background(CelinkTheme.border)
        }
    }

    private func previewRow(_ label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(CelinkTheme.primaryDeep)
                .frame(width: 48, alignment: .leading)

            Text(value)
                .font(.subheadline)
                .foregroundStyle(CelinkTheme.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(CelinkTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(CelinkTheme.border, lineWidth: 1)
        }
    }

    private func previewCoverURL(for type: EventType) -> URL {
        if let data = viewModel.coverImageData,
           let uiImage = UIImage(data: data),
           let jpeg = uiImage.jpegData(compressionQuality: 0.85) {
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("preview-\(UUID().uuidString).jpg")
            try? jpeg.write(to: url)
            return url
        }
        if let existing = viewModel.existingCoverURL, !viewModel.coverImageChanged {
            return existing
        }
        return CreateEventDraft.defaultCoverURL(for: type)
    }
}

struct EventFormSuccessSheet: View {
    let title: String
    let invitePath: String
    var showCreateAnother: Bool
    let onPrimary: () -> Void
    var onCreateAnother: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 52))
                .foregroundStyle(CelinkTheme.primaryDeep)

            Text(title)
                .font(.title3.weight(.semibold))
                .fontDesign(.serif)
                .foregroundStyle(CelinkTheme.ink)

            VStack(spacing: 6) {
                Text("초대 링크")
                    .font(.caption)
                    .foregroundStyle(CelinkTheme.inkMuted)

                Text("celink.app\(invitePath)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(CelinkTheme.primaryDeep)
                    .multilineTextAlignment(.center)
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(CelinkTheme.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            CelinkPrimaryButton(
                title: showCreateAnother ? "이벤트 보기" : "확인",
                action: onPrimary
            )

            if showCreateAnother, let onCreateAnother {
                CelinkSecondaryButton(title: "새 이벤트 만들기", action: onCreateAnother)
            }
        }
        .padding(24)
        .presentationBackground(CelinkTheme.background)
    }
}
