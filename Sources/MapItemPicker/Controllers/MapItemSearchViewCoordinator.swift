import Foundation
import SwiftUI
import MapKit

/// A class that coordinates a MapItemPicker. It can retrieve or set the region of the map view.
public final class MapItemPickerController: NSObject, ObservableObject {
    @Published private(set) var selectedMapItem: MapItemController? = nil {
        didSet {
            if oldValue != selectedMapItem {
                RecentMapItemsController.shared.mapItemWasSelected(selectedMapItem)
            }
        }
    }
    @Published var selectedMapItemCluster: MKClusterAnnotation? = nil
    @Published private(set) var shouldShowTopLeftButtons: Bool = true
    private var savedRectToSet: (rect: MKMapRect, animated: Bool)? = nil
    @Published internal var currentMapView: MKMapView? {
        didSet {
            if let savedRectToSet {
                self.savedRectToSet = nil
                set(rect: savedRectToSet.rect, animated: savedRectToSet.animated)
            }
        }
    }
    internal var currentMainController: UIViewController?
    
    let locationController = LocationController()
    let searcher = MapItemSearchController()
    
    var annotationSelectionHandler: ((MKAnnotation) -> Void)! = nil
    var overlayRenderer: ((MKOverlay) -> MKOverlayRenderer)! = nil
    var annotationView: ((MKAnnotation) -> MKAnnotationView)! = nil
    
    /// Creates a new `MapItemPickerController`.
    public override init() {
        super.init()
        
        searcher.coordinator = self
    }
    
    func manuallySet(selectedMapItem: MapItemController?) {
        // This usually happens within a view update so we use a Task here
        Task { @MainActor in
            guard let mapView = currentMapView else { return }
            
            self.selectedMapItem = selectedMapItem
            reloadSelectedAnnotation()
        }
    }
    
    func reloadSelectedAnnotation() {
        let selectedMapItem = self.selectedMapItem ?? searcher.singularCompletionItem
        
        guard let mapView = currentMapView else { return }
        
        if let selectedMapItem {
            let annotations = mapView.selectedAnnotations + mapView.annotations//.filter({ !($0 is MKClusterAnnotation) })
            let annotation =
            annotations.first(where: {
                ($0 as? MKClusterAnnotation)?.memberAnnotations.contains(annotation: selectedMapItem) ?? false
            }) ?? selectedMapItem
            
            let point = MKMapPoint(annotation.coordinate)
            if !mapView.visibleMapRect.contains(point) {
                setBestRegion(for: [point], animated: true)
            }
            mapView.selectAnnotation(annotation, animated: true)
        } else if let selectedMapItemCluster {
            mapView.selectAnnotation(selectedMapItemCluster, animated: true)
        } else {
            mapView.deselectAnnotation(nil, animated: true)
        }
    }
    
}

// MARK: - MKMapViewDelegate
extension MapItemPickerController: MKMapViewDelegate {
    
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        overlayRenderer(overlay)
    }
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let coordinator = annotation as? MapItemController {
            let view = MKMarkerAnnotationView(annotation: coordinator, reuseIdentifier: nil)
            view.glyphImage = .init(systemName: coordinator.item.imageName)
            view.markerTintColor = coordinator.item.uiColor
            view.clusteringIdentifier = "mapItem"
            return view
        } else if let user = annotation as? MKUserLocation {
            return mapView.dequeueReusableAnnotationView(withIdentifier: "userLocation") ??
                MKUserLocationView(annotation: user, reuseIdentifier: "userLocation")
        } else if let cluster = annotation as? MKClusterAnnotation, cluster.memberAnnotations.contains(where: { $0 is MapItemController }) {
            let coordinators = cluster.memberAnnotations.filter({ $0 is MapItemController }) as! [MapItemController]
            let occurancesByColor: [UIColor: Int]? =  coordinators.reduce(into: [:]) { partialResult, coordinator in
                partialResult[coordinator.item.uiColor, default: 0] += 1
            }
            let color = occurancesByColor?.keys(for: occurancesByColor?.values.max() ?? 0).first ?? .gray
            
            let view = MKMarkerAnnotationView(annotation: cluster, reuseIdentifier: nil)
            view.glyphText = "\(coordinators.count)"
            view.markerTintColor = color
            return view
        } else if #available(iOS 16, *), let featureAnnotation = annotation as? MKMapFeatureAnnotation {
            let view = MKMarkerAnnotationView(annotation: featureAnnotation, reuseIdentifier: nil)
            view.glyphImage = featureAnnotation.iconStyle?.image
            view.markerTintColor = featureAnnotation.iconStyle?.backgroundColor
            return view
        }
        
        return annotationView(annotation)
    }
    
    public func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
        .init(memberAnnotations: memberAnnotations)
    }
    
    public func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        if let completionItem = searcher.singularCompletionItem, annotation as? MapItemController == completionItem { return }
        
        var selectedMapItem: MapItemController? = nil
        if let coordinator = annotation as? MapItemController {
            selectedMapItem = coordinator
        } else if let cluster = annotation as? MKClusterAnnotation, cluster.memberAnnotations.first is MapItemController {
            if let alreadySelected = self.selectedMapItem, cluster.memberAnnotations.contains(annotation: alreadySelected) {
                return
            }
            selectedMapItemCluster = cluster
        } else if #available(iOS 16, *), let item = annotation as? MKMapFeatureAnnotation {
            selectedMapItem = .init(mapFeatureAnnotation: item)
        } else {
            annotationSelectionHandler(annotation)
        }
        
        Task { @MainActor in
            self.selectedMapItem = selectedMapItem
        }
    }
    
    // This function is necessary since the annotation handed to `mapView(_ mapView: MKMapView, didDeselect annotation: MKAnnotation)` is sometimes nil. Casting this within the original function works in debug builds, but not in release builds (due to optimization, propably).
    private func didDeselect(optional annotation: MKAnnotation?) {
        guard let annotation = annotation else { return }

        if let cluster = annotation as? MKClusterAnnotation, cluster == selectedMapItemCluster {
            DispatchQueue.main.async { self.selectedMapItemCluster = nil }
        } else if
            let eq1 = annotation as? MapAnnotationEquatable,
            let eq2 = selectedMapItem as? MapAnnotationEquatable,
            eq1.annotationIsEqual(to: eq2)
        {
            DispatchQueue.main.async { self.selectedMapItem = nil }
        } else if annotation === selectedMapItem {
            DispatchQueue.main.async { self.selectedMapItem = nil }
        }
    }
    
    public func mapView(_ mapView: MKMapView, didDeselect annotation: MKAnnotation) {
        didDeselect(optional: annotation)
    }
    
    // MARK: Compatibility
    
    public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if #available(iOS 16, *) { return }
        
        if let annotation = view.annotation {
            self.mapView(mapView, didSelect: annotation)
        }
    }
    
    public func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if #available(iOS 16, *) { return }
        
        if let annotation = view.annotation {
            self.mapView(mapView, didDeselect: annotation)
        }
    }
    
    public func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        locationController.userTrackingMode = mode
    }
    
    public func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        searcher.regionChanged()
    }
}

// MARK: - UISheetPresentationControllerDelegate
extension MapItemPickerController: UISheetPresentationControllerDelegate {
    public func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        withAnimation {
            shouldShowTopLeftButtons = sheetPresentationController.selectedDetentIdentifier != bigDetentIdentifier
        }
    }
}

// MARK: - Region Coordination
extension MapItemPickerController {
    /// The region currently displayed by the map view.
    public var region: MKCoordinateRegion { currentMapView?.region ?? .unitedStates }
    
    /// Changes the currently visible portion of the map.
    /// - Parameters:
    ///   - rect: The map rectangle to make visible in the map view.
    ///   - animated: Specify `true` if you want the map view to animate the transition to the new map rectangle or `false` if you want the map to center on the specified rectangle immediately.
    public func set(rect: MKMapRect, animated: Bool) {
        let currentPresentationDetent = currentMapView?.window?.rootViewController?.highestPresentedController.sheetPresentationController?.selectedDetentIdentifier
        
        guard let currentMapView else {
            savedRectToSet = (rect, animated)
            return
        }
        
        currentMapView.setVisibleMapRect(
            rect,
            edgePadding: .init(
                top: 16,
                left: 16,
                bottom: (currentPresentationDetent == miniDetentIdentifier ? miniDetentHeight : standardDetentHeight) + 16,
                right: TopRightButtons.Constants.size + TopRightButtons.Constants.padding * 2
            ),
            animated: animated
        )
    }
    
    /// Changes the currently visible portion of the map to the best found region for the given coordinates.
    /// - Parameters:
    ///   - coordinates: The coordinates to form the map rectangle to make visible in the map view.
    ///   - animated: Specify `true` if you want the map view to animate the transition to the new map rectangle or `false` if you want the map to center on the specified rectangle immediately.
    public func setBestRegion(for coordinates: [CLLocationCoordinate2D], animated: Bool) {
        setBestRegion(for: coordinates.map(MKMapPoint.init), animated: animated)
    }
    
    /// Changes the currently visible portion of the map to the best found region for the given points.
    /// - Parameters:
    ///   - points: The points to form the map rectangle to make visible in the map view.
    ///   - animated: Specify `true` if you want the map view to animate the transition to the new map rectangle or `false` if you want the map to center on the specified rectangle immediately.
    public func setBestRegion(for points: [MKMapPoint], animated: Bool) {
        if let rect = MKMapRect(bestFor: points) {
            set(rect: rect, animated: animated)
        }
    }
}
