import Foundation
import SwiftUI
import MapKit

struct MapControllerHolder<StandardView: View, SearchView: View>: UIViewControllerRepresentable {
    @ObservedObject var coordinator: MapItemPickerController
    @ObservedObject var searcher: MapItemSearchController
    
    @Binding var searchControllerShown: Bool
    
    let annotations: [MKAnnotation]
    let overlays: [MKOverlay]
    let primaryAction: MapItemPickerAction
    let actions: [MapItemPickerAction]
    let standardView: () -> StandardView
    let standardSearchView: () -> SearchView
    
    func makeUIViewController(context: Context) -> MapViewController<StandardView, SearchView> {
        let controller = MapViewController(
            coordinator: coordinator,
            primaryAction: primaryAction,
            actions: actions,
            searchSheetDismissHandler: { searchControllerShown = false },
            standardView: standardView,
            standardSearchView: standardSearchView
        )
        
        RunLoop.main.perform {
            coordinator.currentMapView = controller.mapView
            coordinator.currentMainController = controller
            controller.update(searchSheetShown: searchControllerShown)
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: MapViewController<StandardView, SearchView>, context: Context) {
        let view = uiViewController.mapView
        
        view.delegate = coordinator // (1) This should be set in makeUIView, but it is getting reset to `nil`
        view.translatesAutoresizingMaskIntoConstraints = false // (2) In the absence of this, we get constraints error on rotation; and again, it seems one should do this in makeUIView, but has to be here
        
        uiViewController.primaryAction = primaryAction
        uiViewController.actions = actions
        refreshAnnotations(view: view)
        refreshOverlays(view: view)
        
        uiViewController.update(selectedCluster: coordinator.selectedMapItemCluster)
        uiViewController.update(mapItemController: coordinator.selectedMapItem)
        uiViewController.update(localSearchCompletion: coordinator.searcher.searchedCompletion)
        
        uiViewController.update(searchSheetShown: searchControllerShown)
    }
    
    func refreshAnnotations(view: MKMapView) {
        var newAnnotations: [MKAnnotation] = (coordinator.searcher.completionItems ?? coordinator.searcher.items) + annotations
        if let selected = coordinator.selectedMapItem, !newAnnotations.contains(annotation: selected) {
            newAnnotations.append(selected)
        }
        let oldAnnotations = view.annotations
        
        let annotationsToAdd = newAnnotations.filter({ !oldAnnotations.contains(annotation: $0) })
        let annotationsToRemove = oldAnnotations.filter({
            if #available(iOS 16, *), $0 is MKMapFeatureAnnotation {
                return false
            }
            
            return !newAnnotations.contains(annotation: $0) &&
            !($0 is MKClusterAnnotation)
        })
        
        view.removeAnnotations(annotationsToRemove)
        view.addAnnotations(annotationsToAdd)
        
        // Sometimes the selectedAnnotation was not in the annotations before and thus has to be selected now.
        if let selected = coordinator.selectedMapItem, annotationsToAdd.contains(annotation: selected) {
            coordinator.reloadSelectedAnnotation()
        }
    }
    
    func refreshOverlays(view: MKMapView) {
        let newOverlays = overlays
        let oldOverlays = view.overlays
        
        let overlaysToAdd = newOverlays.filter({ !oldOverlays.contains(overlay: $0) })
        let overlaysToRemove = oldOverlays.filter({ !newOverlays.contains(overlay: $0) })
        
        view.removeOverlays(overlaysToRemove)
        view.addOverlays(overlaysToAdd)
    }
}

