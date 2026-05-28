import PhotosUI
import SwiftUI

struct EventPhotoAlbumView: View {
    let eventId: String
    var isOwnerMode: Bool = false
    @Bindable private var interactionStore = EventInteractionStore.shared

    @State private var photoItem: PhotosPickerItem?
    @State private var selectedPhoto: PhotoSelection?

    private var detail: EventDetail? {
        interactionStore.eventDetail(id: eventId)
    }

    private var photoURLs: [URL] {
        interactionStore.photoURLs(for: eventId, includePrivate: isOwnerMode)
    }

    private let columns = [
        GridItem(.flexible(), spacing: 6),
        GridItem(.flexible(), spacing: 6),
        GridItem(.flexible(), spacing: 6),
    ]

    var body: some View {
        Group {
            if let detail {
                content(detail)
            } else {
                Text("이벤트를 찾을 수 없습니다")
                    .foregroundStyle(CelinkTheme.inkMuted)
            }
        }
        .background(CelinkTheme.background)
        .navigationTitle(isOwnerMode ? "공유앨범 관리" : "사진 앨범")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(CelinkTheme.background, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                PhotosPicker(selection: $photoItem, matching: .images) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(CelinkTheme.primaryDeep)
                }
                .accessibilityLabel("사진 추가")
            }
        }
        .onChange(of: photoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    _ = interactionStore.addPhoto(eventId: eventId, imageData: data)
                }
                photoItem = nil
            }
        }
        .sheet(item: $selectedPhoto) { selected in
            PhotoFeedSheet(
                eventId: eventId,
                photoURL: selected.url,
                isOwnerMode: isOwnerMode
            )
        }
    }

    private func content(_ detail: EventDetail) -> some View {
        GeometryReader { geometry in
            let contentWidth = CelinkLayout.contentWidth(in: geometry.size.width)
            let cellSize = floor((contentWidth - 12) / 3)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    EventSubpageHeader(
                        title: "공유 앨범",
                        eventTitle: detail.summary.title,
                        subtitle: "\(photoURLs.count)장의 사진"
                    )

                    if photoURLs.isEmpty {
                        emptyState
                    } else {
                        LazyVGrid(columns: columns, spacing: 6) {
                            ForEach(photoURLs, id: \.absoluteString) { url in
                                Button {
                                    selectedPhoto = PhotoSelection(url: url)
                                } label: {
                                    ZStack(alignment: .topTrailing) {
                                        RemoteImage(url: url)
                                            .frame(width: cellSize, height: cellSize)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))

                                        if isOwnerMode, interactionStore.isPhotoPrivate(eventId: eventId, photoURL: url) {
                                            Text("비공개")
                                                .font(.caption2.weight(.semibold))
                                                .foregroundStyle(.white)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 3)
                                                .background(Color.black.opacity(0.6))
                                                .clipShape(Capsule())
                                                .padding(6)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Text("우측 상단 + 버튼으로 사진을 추가할 수 있어요.")
                        .font(.caption)
                        .foregroundStyle(CelinkTheme.inkMuted)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .frame(width: contentWidth, alignment: .leading)
                .padding(.horizontal, CelinkLayout.horizontalPadding)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.largeTitle)
                .foregroundStyle(CelinkTheme.primary.opacity(0.7))

            Text("아직 공유된 사진이 없어요")
                .font(.subheadline)
                .foregroundStyle(CelinkTheme.inkMuted)

            PhotosPicker(selection: $photoItem, matching: .images) {
                Text("첫 사진 올리기")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(CelinkTheme.primaryDeep)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(CelinkTheme.backgroundSecondary)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 56)
        .background(CelinkTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: CelinkLayout.cardCornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: CelinkLayout.cardCornerRadius)
                .stroke(CelinkTheme.border, lineWidth: 1)
        }
    }
}

private struct PhotoSelection: Identifiable {
    let url: URL
    var id: String { url.absoluteString }
}

private struct PhotoFeedSheet: View {
    let eventId: String
    let photoURL: URL
    let isOwnerMode: Bool
    @Environment(\.dismiss) private var dismiss
    @Bindable private var interactionStore = EventInteractionStore.shared
    @State private var commentText = ""

    private var comments: [PhotoComment] {
        interactionStore.comments(for: photoURL)
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let sheetWidth = geometry.size.width
                let contentWidth = CelinkLayout.contentWidth(in: sheetWidth)

                VStack(spacing: 0) {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            FeedPhotoView(url: photoURL, containerWidth: contentWidth)
                                .padding(.horizontal, CelinkLayout.horizontalPadding)
                                .padding(.top, 8)

                            HStack(spacing: 14) {
                                Button {
                                    interactionStore.toggleLike(for: photoURL)
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: interactionStore.isLiked(for: photoURL) ? "heart.fill" : "heart")
                                            .foregroundStyle(interactionStore.isLiked(for: photoURL) ? Color.red : CelinkTheme.ink)
                                        Text("\(interactionStore.likeCount(for: photoURL))")
                                            .foregroundStyle(CelinkTheme.ink)
                                    }
                                    .font(.subheadline.weight(.semibold))
                                }
                                .buttonStyle(.plain)

                                HStack(spacing: 6) {
                                    Image(systemName: "message")
                                    Text("\(comments.count)")
                                }
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(CelinkTheme.ink)

                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, CelinkLayout.horizontalPadding)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)

                            if isOwnerMode {
                                HStack(spacing: 10) {
                                    Button {
                                        interactionStore.togglePhotoPrivacy(eventId: eventId, photoURL: photoURL)
                                    } label: {
                                        Text(
                                            interactionStore.isPhotoPrivate(eventId: eventId, photoURL: photoURL)
                                                ? "공개로 전환"
                                                : "비공개 처리"
                                        )
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(CelinkTheme.primaryDeep)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(CelinkTheme.backgroundSecondary)
                                        .clipShape(Capsule())
                                    }
                                    .buttonStyle(.plain)

                                    Button {
                                        _ = interactionStore.deletePhoto(eventId: eventId, photoURL: photoURL)
                                        dismiss()
                                    } label: {
                                        Text("사진 삭제")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(.white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color.red.opacity(0.85))
                                            .clipShape(Capsule())
                                    }
                                    .buttonStyle(.plain)

                                    Spacer(minLength: 0)
                                }
                                .padding(.horizontal, CelinkLayout.horizontalPadding)
                                .padding(.bottom, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            Divider().background(CelinkTheme.border)

                            VStack(alignment: .leading, spacing: 10) {
                                Text("댓글")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(CelinkTheme.ink)

                                if comments.isEmpty {
                                    Text("첫 댓글을 남겨보세요.")
                                        .font(.caption)
                                        .foregroundStyle(CelinkTheme.inkMuted)
                                } else {
                                    ForEach(comments) { comment in
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack {
                                                Text(comment.authorName)
                                                    .font(.caption.weight(.semibold))
                                                    .foregroundStyle(CelinkTheme.ink)
                                                Spacer(minLength: 0)
                                                Text(EventFormatting.relativeDate(comment.createdAt))
                                                    .font(.caption2)
                                                    .foregroundStyle(CelinkTheme.inkMuted)
                                            }
                                            Text(comment.content)
                                                .font(.subheadline)
                                                .foregroundStyle(CelinkTheme.ink)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                        .padding(12)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(CelinkTheme.backgroundSecondary.opacity(0.55))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                }
                            }
                            .padding(CelinkLayout.horizontalPadding)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(width: sheetWidth, alignment: .leading)
                    }

                    HStack(spacing: 10) {
                        TextField("댓글을 입력해 주세요", text: $commentText)
                            .font(.body)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(CelinkTheme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(CelinkTheme.border, lineWidth: 1)
                            }

                        Button("등록") {
                            interactionStore.addComment(photoURL: photoURL, content: commentText)
                            commentText = ""
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                ? CelinkTheme.primary.opacity(0.4)
                                : CelinkTheme.primaryDeep
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding(.horizontal, CelinkLayout.horizontalPadding)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(CelinkTheme.background)
                }
                .frame(width: sheetWidth, height: geometry.size.height, alignment: .top)
            }
            .background(CelinkTheme.background)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("닫기") { dismiss() }
                        .foregroundStyle(CelinkTheme.primaryDeep)
                }
            }
        }
    }
}

private struct FeedPhotoView: View {
    let url: URL
    let containerWidth: CGFloat

    @State private var loadedImage: UIImage?

    private var displayHeight: CGFloat {
        guard let loadedImage, loadedImage.size.width > 0 else { return 260 }
        let aspectRatio = loadedImage.size.height / loadedImage.size.width
        return containerWidth * aspectRatio
    }

    var body: some View {
        Group {
            if let loadedImage {
                Image(uiImage: loadedImage)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .frame(width: containerWidth, height: displayHeight)
                    .background(Color.black.opacity(0.03))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                CelinkTheme.backgroundSecondary
                    .overlay {
                        ProgressView()
                            .tint(CelinkTheme.primaryDeep)
                    }
                    .frame(width: containerWidth, height: 260)
            }
        }
        .frame(width: containerWidth, height: loadedImage == nil ? 260 : displayHeight)
        .task(id: url) {
            await loadImage()
        }
    }

    private func loadImage() async {
        let image: UIImage?
        if url.isFileURL {
            if let data = try? Data(contentsOf: url) {
                image = UIImage(data: data)
            } else {
                image = nil
            }
        } else if let (data, _) = try? await URLSession.shared.data(from: url) {
            image = UIImage(data: data)
        } else {
            image = nil
        }

        guard let image else { return }
        await MainActor.run {
            loadedImage = image
        }
    }
}

#Preview {
    NavigationStack {
        EventPhotoAlbumView(eventId: "evt-1")
    }
}
