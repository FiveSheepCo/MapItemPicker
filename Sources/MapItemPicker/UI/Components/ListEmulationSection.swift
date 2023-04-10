import SwiftUI

struct ListEmulationSection<T: View>: View {
    let headerText: LocalizedStringKey
    @ViewBuilder let content: () -> T
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(headerText, bundle: .module)
                    .font(.title3Compatible.bold())
                    .padding(.horizontal, 12)
                Spacer()
            }
            VStack(spacing: 0) {
                content()
            }
            .background(Color.secondarySystemBackground)
            .cornerRadius(8)
        }
    }
}
