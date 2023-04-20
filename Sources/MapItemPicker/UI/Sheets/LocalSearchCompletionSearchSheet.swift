import SwiftUI
import MapKit

struct LocalSearchCompletionSearchSheet: View {
    let completion: MKLocalSearchCompletion
    @ObservedObject var searcher: MapItemSearchController
    @ObservedObject var coordinator: MapItemPickerController
    
    let primaryAction: MapItemPickerAction
    let actions: [MapItemPickerAction]
    let dismissHandler: () -> Void
    
    var body: some View {
        if let items = searcher.completionItems, items.count == 1 {
            MapItemDisplaySheet(
                coordinator: coordinator,
                itemCoordinator: items[0],
                primaryAction: primaryAction,
                actions: actions,
                dismissHandler: dismissHandler,
                shouldScroll: true,
                shouldAddPadding: true
            )
            .onAppear {
                coordinator.reloadSelectedAnnotation()
            }
        } else {
            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text(completion.title)
                            .font(.title.bold())
                        Text(completion.subtitle)
                    }
                    Spacer()
                    Button(action: dismissHandler) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }
                .padding([.horizontal, .top])
                if let items = searcher.completionItems {
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
                } else {
                    Spacer()
                    if #available(iOS 14.0, *) { ProgressView() }
                    Text("search.loading", bundle: .module).padding(.top, 4)
                    Spacer()
                }
            }
        }
    }
}
