import SwiftUI

struct SearchCell: View {
    let systemImageName: String
    let color: Color
    let title: String
    let subtitle: String
    let action: () -> Void
    
    init(systemImageName: String, color: Color, title: String, subtitle: String, action: @escaping () -> Void) {
        self.systemImageName = systemImageName
        self.color = color
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }
    
    init(mapItemController: MapItemController, coordinator: MapItemPickerController) {
        self.systemImageName = mapItemController.item.imageName
        self.color = mapItemController.item.color
        self.title = mapItemController.item.name
        self.subtitle = mapItemController.item.subtitle
        self.action = {
            coordinator.manuallySet(selectedMapItem: mapItemController)
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Circle()
                    .fill(color)
                    .overlay {
                        Image(systemName: systemImageName)
                            .resizable()
                            .scaledToFit()
                            .padding(6)
                            .foregroundColor(.white)
                    }
                    .frame(width: 30)
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.body.bold())
                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.caption)
                            .opacity(0.75)
                    }
                }
                Spacer()
            }
            .frame(height: 30)
            .padding(.vertical, 4)
            .foregroundColor(.label)
        }
    }
}
