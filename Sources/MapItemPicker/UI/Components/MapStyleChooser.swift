import SwiftUI
import MapKit

extension TopRightButtons {
    @available(iOS 16.0, *)
    struct MapStyleChooser: View {
        @ObservedObject var coordinator: MapItemPickerController
        
        private let cases = MKMapConfiguration.cases
        @State private var selectedIndex: Int = 0
        
        var body: some View {
            Menu {
                Picker(
                    "",
                    selection: $selectedIndex
                ) {
                    ForEach(0..<3) { caseIndex in
                        let singleCase = cases[caseIndex]
                        HStack {
                            Image(systemName: singleCase.imageName)
                            Text(singleCase.title, bundle: Bundle.module)
                        }
                        .tag(caseIndex)
                    }
                }
            } label: {
                SingleDisplay(imageName: cases[selectedIndex].imageName)
            }
            .onAppear {
                selectedIndex = cases.firstIndex(where: { config in
                    config.title == coordinator.currentMapView?.preferredConfiguration.title
                }) ?? 0
            }
            .onChange(of: selectedIndex) { selectedIndex in
                coordinator.currentMapView?.preferredConfiguration = cases[selectedIndex]
            }
        }
    }
}
