import SwiftUI

public struct MapItemDisplayView: View {
    let mapItem: MapItem
    let shouldScroll: Bool
    
    @State private var coordinator: MapItemController?
    
    public init(mapItem: MapItem, shouldScroll: Bool) {
        self.mapItem = mapItem
        self.shouldScroll = shouldScroll
    }
    
    public var body: some View {
        if let coordinator {
            MapItemDisplaySheet(
                coordinator: nil,
                itemCoordinator: coordinator,
                primaryAction: nil,
                actions: [],
                dismissHandler: nil,
                shouldScroll: shouldScroll,
                shouldAddPadding: false
            )
        } else {
            Rectangle()
                .onAppear { coordinator = .init(item: mapItem) }
        }
    }
}
