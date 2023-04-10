import SwiftUI
import SchafKit

struct TopRightButtons: View {
    @ObservedObject var coordinator: MapItemPickerController
    let showsLocationButton: Bool
    let additionalTopRightButtons: [MIPAction]
    
    enum Constants {
        static let size: CGFloat = 44
        static let glyphSize: CGFloat = 22
        static let padding: CGFloat = 10
    }
    
    struct SingleDisplay: View {
        let imageName: String
        
        var body: some View {
            Rectangle()
                .fill(Color.clear)
                .frame(height: Constants.size)
                .overlay(
                    Image(systemName: imageName)
                        .font(.system(size: Constants.glyphSize))
                        .foregroundColor(.label)
                )
        }
    }
    
    struct Single: View {
        let imageName: String
        let handler: () -> Void
        
        var body: some View {
            Button(action: handler) {
                SingleDisplay(imageName: imageName)
            }
        }
    }
    
    struct Location: View {
        @ObservedObject var helper: LocationController
        @ObservedObject var coordinator: MapItemPickerController
        
        var body: some View {
            Single(imageName: helper.displayedImage) {
                helper.tapped(coordinator: coordinator)
            }
        }
    }
    
    var body: some View {
        VStack {
            VStack(spacing: 0) {
                if #available(iOS 16, *) {
                    MapStyleChooser(coordinator: coordinator)
                }
                if showsLocationButton {
                    if #available(iOS 16, *) { Divider() }
                    Location(helper: coordinator.locationController, coordinator: coordinator)
                }
                ForEach(additionalTopRightButtons) { button in
                    Divider()
                    Single(imageName: button.imageName, handler: button.handler)
                }
            }
            .frame(width: Constants.size)
            .background(Blur(.regular))
            .cornerRadius(6)
            .shadow(radius: 1)
            CompassView(mapView: coordinator.currentMapView)
                .frame(width: Constants.size, height: Constants.size)
        }
        .padding(.top, 8)
        .padding(.trailing, Constants.padding)
    }
}
