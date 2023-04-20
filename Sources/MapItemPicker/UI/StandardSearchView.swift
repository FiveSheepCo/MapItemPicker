import SwiftUI

/// The view displayed below the search bar by default.
public struct StandardSearchView: View {
    @EnvironmentObject private var coordinator: MapItemPickerController
    
    public init() {}
    
    public var body: some View {
        List {
            RecentMapItemsSection()
            Section("search.category".moduleLocalized) {
                ForEach(MapItemCategory.allCases) { category in
                    SearchCell(
                        systemImageName: category.imageName,
                        color: Color(category.color),
                        title: category.name,
                        subtitle: .empty,
                        action: {
                            coordinator.searcher.filteredCategories = [category]
                        }
                    )
                }
            }
        }
    }
}
