import Foundation
import SwiftUI

/// The section displaying the recently selected map items in the search view.
public struct RecentMapItemsSection: View {
    @ObservedObject var controller: RecentMapItemsController = .shared
    @EnvironmentObject var coordinator: MapItemPickerController
    
    @State private var showMore: Bool = false
    
    public var body: some View {
        if !controller.recentMapItems.isEmpty {
            Section {
                ForEach(controller.recentMapItems.sliced(upTo: showMore ? RecentMapItemsController.Constants.maximumNumberOfRecentMapItems : 3), id: \.location) { mapItem in
                    SearchCell(mapItemController: .init(item: mapItem), coordinator: coordinator)
                }
            } header: {
                HStack(alignment: .bottom) {
                    Text("search.recentMapItems", bundle: .module)
                    Spacer()
                    if controller.recentMapItems.count > 3 {
                        Button {
                            withAnimation {
                                showMore.toggle()
                            }
                        } label: {
                            Text(showMore ? "search.recentMapItems.showLess" : "search.recentMapItems.showMore", bundle: .module)
                                .textCase(.none)
                                .font(.footnote)
                        }
                    }
                }
            }
        }
    }
}
