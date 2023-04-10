import SwiftUI
import MapKit

struct CompassView: UIViewRepresentable {
    let mapView: MKMapView?
    
    func makeUIView(context: Context) -> MKCompassButton {
        let button = MKCompassButton(mapView: mapView)
        button.compassVisibility = .adaptive
        return button
    }
    
    func updateUIView(_ uiView: MKCompassButton, context: Context) {
        uiView.mapView = mapView
    }
}
