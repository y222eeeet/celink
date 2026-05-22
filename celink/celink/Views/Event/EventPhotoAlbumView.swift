import PhotosUI
import SwiftUI

struct EventPhotoAlbumView: View {
    let eventId: String
    @Bindable private var interactionStore = EventInteractionStore.shared

    @State private var photoItem: PhotosPickerItem?
    @State private var selectedPhotoIndex: PhotoIndex?

    private var detail: EventDetail? {
        interactionStore.eventDetail(id: eventId)
    }

    private var photoURLs: [URL] {
        interactionStore.photoURLs(for: eventId)
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
        .navigationTitle("사진 앨범")
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
        .fullScreenCover(item: $selectedPhotoIndex) { index in
            PhotoViewerSheet(urls: photoURLs, initialIndex: index.id)
        }
    }

    private func content(_ detail: EventDetail) -> some View {
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
                        ForEach(Array(photoURLs.enumerated()), id: \.offset) { index, url in
                            Button {
                                selectedPhotoIndex = PhotoIndex(id: index)
                            } label: {
                                RemoteImage(url: url)
                                    .aspectRatio(1, contentMode: .fill)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
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
            .padding(.horizontal, CelinkLayout.horizontalPadding)
            .padding(.top, 8)
            .padding(.bottom, 32)
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

private struct PhotoIndex: Identifiable {
    let id: Int
}

private struct PhotoViewerSheet: View {
    let urls: [URL]
    let initialIndex: Int
    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex: Int

    init(urls: [URL], initialIndex: Int) {
        self.urls = urls
        self.initialIndex = initialIndex
        _currentIndex = State(initialValue: initialIndex)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            TabView(selection: $currentIndex) {
                ForEach(Array(urls.enumerated()), id: \.offset) { index, url in
                    RemoteImage(url: url)
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .white.opacity(0.35))
                    .padding(20)
            }
        }
    }
}

#Preview {
    NavigationStack {
        EventPhotoAlbumView(eventId: "evt-1")
    }
}
