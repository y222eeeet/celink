import PhotosUI
import SwiftUI

struct CreateEventView: View {
    @State private var viewModel = EventFormViewModel(mode: .create)
    @State private var photoItem: PhotosPickerItem?
    @State private var navigateToEventId: String?
    /// 생성 완료 후 폼만 새로 시작 (네비게이션은 부모에서 유지)
    @State private var formInstanceId = UUID()

    var body: some View {
        EventFormView(
            viewModel: viewModel,
            photoItem: $photoItem,
            showCreateAnother: true,
            onFinished: {},
            onCreateAnother: {},
            onFormReset: refreshFormInstance,
            onViewCreatedEvent: { eventId in
                navigateToEventId = eventId
            }
        )
        .id(formInstanceId)
        .onAppear(perform: resetFormIfNeededAfterCreate)
        .navigationDestination(isPresented: Binding(
            get: { navigateToEventId != nil },
            set: { isPresented in
                if !isPresented {
                    navigateToEventId = nil
                    resetFormAfterViewingEvent()
                }
            }
        )) {
            if let eventId = navigateToEventId {
                EventDetailView(eventId: eventId)
            }
        }
    }

    /// 다른 탭에 갔다가 돌아온 경우 등, 상세 보기 없이 만들기 탭만 다시 연 경우
    private func resetFormIfNeededAfterCreate() {
        guard viewModel.consumePendingReset() else { return }
        resetFormAfterViewingEvent()
    }

    /// 상세에서 뒤로 돌아온 뒤 빈 생성 폼 표시
    private func resetFormAfterViewingEvent() {
        viewModel.reset()
        photoItem = nil
        refreshFormInstance()
    }

    private func refreshFormInstance() {
        photoItem = nil
        formInstanceId = UUID()
    }
}

#Preview {
    NavigationStack {
        CreateEventView()
    }
}
