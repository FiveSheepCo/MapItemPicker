import SwiftUI

extension MapItemDisplaySheet {
    @ViewBuilder var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.title.bold())
                Text(item.subtitle)
            }
            Spacer()
            if let dismissHandler {
                Button(action: dismissHandler) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}
