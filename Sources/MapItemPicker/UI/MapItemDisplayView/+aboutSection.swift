import SwiftUI

extension MapItemDisplaySheet {
    @ViewBuilder var aboutSection: some View {
        if let about = item.wikiDescription {
            VStack {
                ListEmulationSection(headerText: "itemSheet.about") {
                    HStack {
                        Text(about.capitalizedSentence)
                            .listCellEmulationPadding()
                        Spacer(minLength: 0)
                    }
                }
                if let wikipediaURL = item.wikipediaURL, let url = URL(string: wikipediaURL), #available(iOS 15, *) {
                    HStack {
                        Text("itemSheet.about.moreOn", bundle: .module) + Text(" ") +
                        Text(AttributedString("Wikipedia", attributes: .init([.link: url])))
                        Spacer(minLength: 0)
                    }
                    .padding(.leading, 12)
                }
            }
        }
    }
}
