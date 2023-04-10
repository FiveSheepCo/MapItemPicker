import SwiftUI

extension MapItemDisplaySheet {
    private var coordinateString: String {
        let lat = item.location.latitude
        let lon = item.location.longitude
        
        return "\(lat.magnitude.toFormattedString(decimals: 5))° \(lat >= 0 ? "N" : "S"), \(lon.magnitude.toFormattedString(decimals: 5))° \(lon >= 0 ? "E" : "W")"
    }
    
    @ViewBuilder var detailsSection: some View {
        ListEmulationSection(headerText: "itemSheet.details") {
            if let openingHours = item.openingHours {
                OpeningHoursCell(openingHours: openingHours)
                Divider()
            }
            let lines = item.addressLines
            if !lines.isEmpty {
                DetailListEmulationCell(
                    title: "itemSheet.details.location",
                    detail: lines.joined(separator: .newline),
                    link: nil
                )
                Divider()
            }
            DetailListEmulationCell(
                title: "itemSheet.details.coordinates",
                detail: coordinateString,
                link: nil
            )
            if let level = item.level {
                Divider()
                DetailListEmulationCell(
                    title: "itemSheet.details.level",
                    detail: "\(level)",
                    link: nil
                )
            }
        }
    }
}
