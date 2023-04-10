import SwiftUI

struct DetailListEmulationCell: View {
    let title: LocalizedStringKey
    let detail: String
    let link: URL?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title, bundle: .module)
                    .font(.callout)
                    .opacity(0.75)
                if let link, #available(iOS 14, *) {
                    Link(destination: link) {
                        Text(detail).multilineTextAlignment(.leading)
                    }
                } else {
                    Text(detail)
                }
            }
            .multilineTextAlignment(.leading)
            Spacer()
        }
        .listCellEmulationPadding()
    }
}
