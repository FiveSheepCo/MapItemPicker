import SwiftUI

extension MapItemDisplaySheet {
    
    @ViewBuilder var contactSection: some View {
        if item.website != nil || item.phone != nil {
            ListEmulationSection(headerText: "itemSheet.contact") {
                if let website = item.website, let url = URL(string: website) {
                    DetailListEmulationCell(
                        title: "itemSheet.contact.website",
                        detail: website,
                        link: url
                    )
                    if item.phone != nil {
                        Divider()
                    }
                }
                if let phone = item.phone, let url = URL(string: "telprompt://\(phone.filter({ !$0.isWhitespace }))") {
                    DetailListEmulationCell(
                        title: "itemSheet.contact.phone",
                        detail: phone,
                        link: url
                    )
                }
            }
        }
    }
}
