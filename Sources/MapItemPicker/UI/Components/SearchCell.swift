import SwiftUI

struct SearchCell: View {
    let systemImageName: String
    let color: Color
    let title: String
    let subtitle: String
    let action: () -> Void
    
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
            .foregroundColor(.label)
        }
    }
}
