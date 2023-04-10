import SwiftUI

extension MapItemDisplaySheet {
    @ViewBuilder var topScrollInfoView: some View {
        let items = topScrollableItems
        if !items.isEmpty {
            VStack {
                Divider()
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(items) { item in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title, bundle: .module)
                                    .font(.caption.bold())
                                    .textCaseUppercase()
                                    .opacity(0.75)
                                HStack(spacing: 4) {
                                    Image(systemName: item.imageName).opacity(0.5)
                                    Text(item.value)
                                }
                                .font(.body.bold())
                            }
                            if item != items.last {
                                Divider()
                            }
                        }
                    }
                }
                Divider()
            }
        }
    }
}

extension MapItemDisplaySheet {
    struct DisplayItem: Identifiable, Equatable {
        var id: String { imageName }
        
        let imageName: String
        let title: LocalizedStringKey
        let value: String
    }
    
    var topScrollableItems: [DisplayItem] {
        var items: [DisplayItem] = []
        
        if let population = item.population {
            items.append(.init(
                imageName: "person.3.fill",
                title: "itemSheet.topScrollableItems.population",
                value: population.compatibleFormatted()
            ))
        }
        if let area = item.area {
            items.append(.init(
                imageName: "rectangle.dashed",
                title: "itemSheet.topScrollableItems.area",
                value: "\((area / 1000000).toFormattedString()) km²"
            ))
        }
        if let altitude = item.altitude {
            items.append(.init(
                imageName: "water.waves.and.arrow.up",
                title: "itemSheet.topScrollableItems.altitude",
                value: "\(altitude.compatibleFormatted()) m"
            ))
        }
        
        return items
    }
}
