import SwiftUI
import MapKit

let miniDetentHeight: CGFloat = 80
let standardDetentHeight: CGFloat = 300
let miniDetentIdentifier = UISheetPresentationController.Detent.Identifier("mini")
let standardDetentIdentifier = UISheetPresentationController.Detent.Identifier("standard")
let bigDetentIdentifier = UISheetPresentationController.Detent.Identifier("big")

private let standardDetents: [UISheetPresentationController.Detent] = {
    if #available(iOS 16, *) {
        return [
            .custom(identifier: miniDetentIdentifier, resolver: { _ in miniDetentHeight }),
            .custom(identifier: standardDetentIdentifier, resolver: { _ in standardDetentHeight }),
            .custom(identifier: bigDetentIdentifier, resolver: { context in context.maximumDetentValue - 1 })
        ]
    }
    return [.medium(), .large()]
}()

class MapViewController<StandardView: View, SearchView: View>: UIViewController {
    let mapView = MKMapView()
    let coordinator: MapItemPickerController
    
    let standardSheet: UIHostingController<StandardView>
    let searchSheet: UIHostingController<SearchSheet<SearchView>>
    var shownSearchSheet: UIHostingController<SearchSheet<SearchView>>?
    
    var primaryAction: MapItemPickerAction
    var actions: [MapItemPickerAction]
    
    var mapItemDisplaySheet: UIHostingController<MapItemDisplaySheet>? = nil
    var mapItemClusterSheet: UIHostingController<MapItemClusterSheet>? = nil
    var localSearchCompletionSearchSheet: UIHostingController<LocalSearchCompletionSearchSheet>? = nil
    
    private var mainSheet: UIViewController {
        (standardSheet.rootView is EmptyView) ? searchSheet : standardSheet
    }
    
    init(
        coordinator: MapItemPickerController,
        primaryAction: MapItemPickerAction,
        actions: [MapItemPickerAction],
        searchSheetDismissHandler: @escaping () -> Void,
        standardView: @escaping () -> StandardView,
        standardSearchView: @escaping () -> SearchView
    ) {
        self.coordinator = coordinator
        self.standardSheet = UIHostingController(rootView: standardView())
        self.searchSheet = UIHostingController(rootView: SearchSheet(
            coordinator: coordinator,
            searcher: coordinator.searcher,
            dismissHandler: (standardSheet.rootView is EmptyView) ? nil : searchSheetDismissHandler,
            standardView: standardSearchView
        ))
        self.primaryAction = primaryAction
        self.actions = actions
        
        super.init(nibName: nil, bundle: nil)
        
        mapView.showsUserLocation = true
        mapView.showsCompass = false
        if #available(iOS 16.0, *) {
            mapView.selectableMapFeatures = [.physicalFeatures, .pointsOfInterest, .territories]
        }
        
        // ADD LONG PRESS GESTURE FOR DROPPING PINS
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        mapView.addGestureRecognizer(longPressGesture)
        
        self.view = mapView
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        let touchPoint = gesture.location(in: mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Pinned Location"
        
        mapView.addAnnotation(annotation)
    }
    
    func update(mapItemController: MapItemController?) {
        if let mapItemDisplaySheet {
            if let mapItemController {
                mapItemDisplaySheet.rootView.itemCoordinator = mapItemController
            } else {
                self.mapItemDisplaySheet = nil
            }
        } else if let mapItemController {
            let sheet = UIHostingController<MapItemDisplaySheet>(rootView: .init(
                coordinator: coordinator,
                itemCoordinator: mapItemController,
                primaryAction: primaryAction,
                actions: actions,
                dismissHandler: { [self] in
                    searchSheet.rootView.coordinator.manuallySet(selectedMapItem: nil)
                    coordinator.sheetPresentationControllerDidChangeSelectedDetentIdentifier(
                        localSearchCompletionSearchSheet?.sheetPresentationController ??
                        searchSheet.sheetPresentationController!
                    )
                },
                shouldScroll: true,
                shouldAddPadding: true
            ))
            mapItemDisplaySheet = sheet
        }
        
        updateSheets()
    }
    
    func update(selectedCluster: MKClusterAnnotation?) {
        if let mapItemClusterSheet {
            if let selectedCluster {
                mapItemClusterSheet.rootView.cluster = selectedCluster
            } else {
                self.mapItemClusterSheet = nil
            }
        } else if let selectedCluster {
            let sheet = UIHostingController<MapItemClusterSheet>(rootView:
                .init(
                    coordinator: coordinator,
                    cluster: selectedCluster,
                    dismissHandler: {
                        self.coordinator.selectedMapItemCluster = nil
                        self.coordinator.reloadSelectedAnnotation()
                        self.coordinator.sheetPresentationControllerDidChangeSelectedDetentIdentifier(self.mainSheet.topmostViewController.sheetPresentationController!)
                    }
                )
            )
            mapItemClusterSheet = sheet
        }
        
        updateSheets()
    }
    
    func update(localSearchCompletion: MKLocalSearchCompletion?) {
        if localSearchCompletion != localSearchCompletionSearchSheet?.rootView.completion {
            localSearchCompletionSearchSheet = nil
            
            if let localSearchCompletion {
                let sheet = UIHostingController<LocalSearchCompletionSearchSheet>(
                    rootView: .init(
                        completion: localSearchCompletion,
                        searcher: searchSheet.rootView.coordinator.searcher,
                        coordinator: searchSheet.rootView.coordinator,
                        primaryAction: primaryAction,
                        actions: actions
                    ) { [self] in
                        coordinator.searcher.searchedCompletion = nil
                        coordinator.sheetPresentationControllerDidChangeSelectedDetentIdentifier(searchSheet.sheetPresentationController!)
                    }
                )
                localSearchCompletionSearchSheet = sheet
            }
        }
        
        updateSheets()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presentWithDetents(mainSheet)
    }
    
    private func updateSheets() {
        let currentlyPresentedSheet = mainSheet.topmostViewController
        if
            currentlyPresentedSheet != mainSheet &&
            ![shownSearchSheet, mapItemDisplaySheet, mapItemClusterSheet, localSearchCompletionSearchSheet].contains(exactObject: currentlyPresentedSheet)
        {
            currentlyPresentedSheet.dismiss(animated: true) {
                currentlyPresentedSheet.isModalInPresentation = false
                self.updateSheets()
            }
            return
        }
        
        if let mapItemDisplaySheet {
            presentWithDetents(mapItemDisplaySheet)
        } else if let mapItemClusterSheet {
            presentWithDetents(mapItemClusterSheet)
        } else if let localSearchCompletionSearchSheet {
            presentWithDetents(localSearchCompletionSearchSheet)
        } else if let shownSearchSheet {
            presentWithDetents(shownSearchSheet)
        }
    }
    
    private func presentWithDetents(_ viewController: UIViewController) {
        if let sheet = viewController.sheetPresentationController {
            sheet.detents = standardDetents
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            sheet.selectedDetentIdentifier = standardDetentIdentifier
        }
        
        if presentedViewController != viewController {
            present(viewController, animated: true)
        }
    }
}
