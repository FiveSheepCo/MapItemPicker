import SwiftUI
import MapKit

struct MapItemClusterSheet: View {
    @ObservedObject var coordinator: MapItemPickerController
    
    var cluster: MKClusterAnnotation
    let dismissHandler: () -> Void
    
    private var items: [MapItemController] {
        cluster.memberAnnotations as? [MapItemController] ?? []
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(cluster.title ?? .empty)
                        .font(.title.bold())
                    Text(cluster.subtitle ?? .empty)
                }
                Spacer()
                Button(action: dismissHandler) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.gray)
                }
            }
            .padding([.horizontal, .top])
            List {
                ForEach(items) { itemCoordinator in
                    let item = itemCoordinator.item
                    SearchCell(
                        systemImageName: item.imageName,
                        color: item.color,
                        title: item.name,
                        subtitle: item.subtitle
                    ) {
                        coordinator.manuallySet(selectedMapItem: itemCoordinator)
                    }
                }
            }
        }
    }
}
