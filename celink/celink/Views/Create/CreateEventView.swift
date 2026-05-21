import PhotosUI
import SwiftUI

struct CreateEventView: View {
    @State private var viewModel = EventFormViewModel(mode: .create)
    @State private var photoItem: PhotosPickerItem?
    /// 생성 완료 후 네비게이션 스택·폼 상태를 완전히 새로 시작
    @State private var formInstanceId = UUID()

    var body: some View {
        EventFormView(
            viewModel: viewModel,
            photoItem: $photoItem,
            showCreateAnother: true,
            onFinished: {},
            onCreateAnother: {},
            onFormReset: refreshFormInstance
        )
        .id(formInstanceId)
        .onAppear(perform: resetFormIfNeededAfterCreate)
    }

    private func resetFormIfNeededAfterCreate() {
        guard viewModel.consumePendingReset() else { return }
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
