import PhotosUI
import SwiftUI

struct EditEventView: View {
    let eventId: String
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: EventFormViewModel
    @State private var photoItem: PhotosPickerItem?

    init(eventId: String) {
        self.eventId = eventId
        _viewModel = State(initialValue: EventFormViewModel(mode: .edit(eventId: eventId)))
    }

    var body: some View {
        EventFormView(
            viewModel: viewModel,
            photoItem: $photoItem,
            showCreateAnother: false,
            onFinished: { dismiss() }
        )
        .navigationBarBackButtonHidden(true)
        .toolbar(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(CelinkTheme.primaryDeep)
                }
            }
        }
        .toolbarBackground(CelinkTheme.background, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        EditEventView(eventId: "evt-preview")
    }
}
