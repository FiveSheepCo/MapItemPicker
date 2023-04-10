import SwiftUI
import MapKit

let miniDetentHeight: CGFloat = 80
let standardDetentHeight: CGFloat = 300
let miniDetentIdentifier = UISheetPresentationController.Detent.Identifier("mini")
let standardDetentIdentifier = UISheetPresentationController.Detent.Identifier("standard")
let bigDetentIdentifier = UISheetPresentationController.Detent.Identifier("big")
private let standardDetents: [UISheetPresentationController.Detent] = { () -> [UISheetPresentationController.Detent] in
    if #available(iOS 16, *) {
        return [
            .custom(identifier: miniDetentIdentifier, resolver: { _ in miniDetentHeight }),
            .custom(identifier: standardDetentIdentifier, resolver: { _ in standardDetentHeight }),
            // -1 so that the screen doesn't get smaller, see https://stackoverflow.com/questions/75635250/leaving-the-presentingviewcontroller-full-screen-while-presenting-a-pagesheet?noredirect=1#comment133439969_75635250
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
        
        self.view = mapView
    }
    
    func update(mapItemController: MapItemController?) {
        if let mapItemDisplaySheet {
            if let mapItemController {
                mapItemDisplaySheet.rootView.itemCoordinator = mapItemController
            } else {
                mapItemDisplaySheet.dismiss()
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
            
            updateSheets()
        }
    }
    
    func update(selectedCluster: MKClusterAnnotation?) {
        if let mapItemClusterSheet {
            if let selectedCluster {
                mapItemClusterSheet.rootView.cluster = selectedCluster
            } else {
                mapItemClusterSheet.dismiss()
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
            
            updateSheets()
        }
    }
    
    func update(localSearchCompletion: MKLocalSearchCompletion?) {
        if localSearchCompletion != localSearchCompletionSearchSheet?.rootView.completion {
            localSearchCompletionSearchSheet?.dismiss()
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
            
            updateSheets()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presentWithDetents(mainSheet)
    }
    
    private func updateSheets() {
        if let mapItemDisplaySheet {
            presentWithDetents(mapItemDisplaySheet)
        } else if let mapItemClusterSheet {
            presentWithDetents(mapItemClusterSheet)
        } else if let localSearchCompletionSearchSheet {
            presentWithDetents(localSearchCompletionSearchSheet)
        }
    }
    
    func update(searchSheetShown: Bool) {
        if searchSheetShown {
            presentWithDetents(searchSheet)
        } else if searchSheet.isModalInPresentation {
            searchSheet.dismiss()
            searchSheet.isModalInPresentation = false
        }
    }
    
    private func presentWithDetents(_ controller: UIViewController) {
        guard !controller.isModalInPresentation else { return }
        
        controller.isModalInPresentation = true
        controller.modalPresentationStyle = .pageSheet
        let presentationController = controller.sheetPresentationController!
        presentationController.prefersGrabberVisible = true
        presentationController.detents = standardDetents
        presentationController.selectedDetentIdentifier = standardDetentIdentifier
        presentationController.largestUndimmedDetentIdentifier = bigDetentIdentifier
        presentationController.delegate = searchSheet.rootView.coordinator
        
        if controller == mainSheet {
            RunLoop.main.perform { [self] in
                if controller.isBeingPresented { return }
                present(controller, animated: false)
            }
        } else {
            // This dismisses software keybaords so that they are not stuck inside one of the views that is not on screen anymore. It has to be outside of the RunLoop block, so that it doesn't mess with our presentation.
            mainSheet.view.window?.firstResponder?.resignFirstResponder()
            
            RunLoop.main.perform { [self] in
                let topmostController = mainSheet.topmostViewController
                let topmostSheetPresentation = topmostController.sheetPresentationController!
                topmostSheetPresentation.animateChanges {
                    topmostController.sheetPresentationController!.selectedDetentIdentifier = standardDetentIdentifier
                }
                topmostController.present(controller)
            }
        }
    }
}
