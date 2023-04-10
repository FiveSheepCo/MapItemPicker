import Foundation
import CoreLocation
import MapKit

class LocationController: NSObject, CLLocationManagerDelegate, ObservableObject {
    let locationManager: CLLocationManager = .init()
    
    @Published var isAuthorized: Bool = false
    @Published var userTrackingMode: MKUserTrackingMode = .none
    
    var displayedImage: String {
        if !isAuthorized {
            return "location.slash"
        }
        
        switch userTrackingMode {
        case .none: return "location"
        case .follow: return "location.fill"
        case .followWithHeading: return "location.north.line.fill"
        @unknown default: return "location"
        }
    }
    
    override init() {
        super.init()
        
        locationManager.delegate = self
    }
    
    @available(iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationManager(manager, didChangeAuthorization: manager.authorizationStatus)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        isAuthorized = [.authorizedAlways, .authorizedWhenInUse].contains(status)
    }
    
    func authorizeIfPossible() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func tapped(coordinator: MapItemPickerController) {
        if !isAuthorized {
            authorizeIfPossible()
            return
        }
        
        switch userTrackingMode {
        case .none: userTrackingMode = .follow
        case .follow: userTrackingMode = .followWithHeading
        default: userTrackingMode = .none
        }
        
        coordinator.currentMapView?.setUserTrackingMode(userTrackingMode, animated: true)
    }
}
