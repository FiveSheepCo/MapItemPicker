import SwiftUI

public extension View {
    func mapItemPickerSheet(isPresented: Binding<Bool>, action: @escaping (MapItem) -> Void) -> some View {
        self.compatibleFullScreen(isPresented: isPresented) {
            NavigationView {
                MapItemPicker(
                    primaryMapItemAction: .init(
                        title: .init("select".moduleLocalized),
                        imageName: "checkmark.circle.fill",
                        handler: { mapItem in
                            action(mapItem)
                            isPresented.wrappedValue = false
                            return true
                        }
                    )
                )
                .navigationBarItems(
                    leading: Button("cancel".moduleLocalized) {
                        isPresented.wrappedValue = false
                    }
                )
                .navigationBarTitle(Text("select", bundle: .module), displayMode: .inline)
                .navigationBarBackgroundVisible()
            }
        }
    }
}
