import SwiftUI

extension MapItemDisplaySheet {
    var legalSection: some View {
        HStack {
            Spacer()
            Button {
                UIApplication.shared.open(.init(string: "https://gspe21-ssl.ls.apple.com/html/attribution-252.html")!)
            } label: {
                Text("legal", bundle: .module)
                    .underline()
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 4)
    }
}
