import SwiftUI
import MapKit

private let canShowLocationButton: Bool = {
    if
        let infoPlistPath = Bundle.main.url(forResource: "Info", withExtension: "plist"),
        let infoPlistData = try? Data(contentsOf: infoPlistPath),
        let dict = try? PropertyListSerialization.propertyList(from: infoPlistData, options: [], format: nil) as? [String: Any]
    {
        return ["NSLocationAlwaysAndWhenInUseUsageDescription", "NSLocationAlwaysUsageDescription", "NSLocationWhenInUseUsageDescription", "NSLocationUsageDescription"].any({ dict.keys.contains($0) })
    }
    return false
}()

public struct MapItemPicker<StandardView: View, SearchView: View>: View {
    @StateObject private var coordinator: MapItemPickerController
    
    @Binding private var searchControllerShown: Bool
    
    private let annotations: [MKAnnotation]
    private let overlays: [MKOverlay]
    private let overlayRenderer: (MKOverlay) -> MKOverlayRenderer
    private let annotationView: (MKAnnotation) -> MKAnnotationView
    private let annotationSelectionHandler: (MKAnnotation) -> Void
    private let primaryMapItemAction: MapItemPickerAction
    private let additionalMapItemActions: [MapItemPickerAction]
    private let showsLocationButton: Bool
    private let additionalTopRightButtons: [MIPAction]
    private let standardView: () -> StandardView
    private let standardSearchView: () -> SearchView
    private let initialMapRect: MKMapRect?
    
    /// Creates a new `MapItemPicker` with the given parameters.
    /// - Parameters:
    ///   - coordinator: The coordinator to use for this view. The default value is `nil`, which makes the view create one itself.
    ///   - annotations: The annotations to show on the map.
    ///   - annotationView: The block to retrieve the annotation view for an annotation.
    ///   - annotationSelectionHandler: The block to execute after an annotation was selected.
    ///   - overlays: The overlays to show on the map.
    ///   - overlayRenderer: The block to retrieve the overlay renderer for an overlay
    ///   - primaryMapItemAction: The primary action on map items, displayed with the accent color as the background.
    ///   - additionalMapItemActions: Additional map item actions.
    ///   - showsLocationButton: Whether the location button is shown in the top-left buttons. It will never be shown if there is no Location usage description in the Info.plist.
    ///   - additionalTopRightButtons: Additional buttons to display on the top-left
    ///   - initialRegion: The region to initially display.
    ///   - standardSearchView: The view that is displayed below the search field. It receives the `MapItemPickerController` as an environment object. By default, this is a `StandardSearchView`.
    public init(
        coordinator: MapItemPickerController? = nil,
        annotations: [MKAnnotation] = [],
        annotationView: @escaping (MKAnnotation) -> MKAnnotationView = {
            fatalError("`annotationView` has not been implemented, but annotation was provided: \($0)")
        },
        annotationSelectionHandler: @escaping (MKAnnotation) -> Void = { _ in },
        overlays: [MKOverlay] = [],
        overlayRenderer: @escaping (MKOverlay) -> MKOverlayRenderer = {
            fatalError("`overlayRenderer` has not been implemented, but overlay was provided: \($0)")
        },
        primaryMapItemAction: MapItemPickerAction,
        additionalMapItemActions: [MapItemPickerAction] = [],
        showsLocationButton: Bool = true,
        additionalTopRightButtons: [MIPAction] = [],
        initialRegion: MKCoordinateRegion? = nil,
        standardSearchView: @escaping () -> SearchView = { StandardSearchView() }
    ) where StandardView == EmptyView {
        self._coordinator = .init(wrappedValue: coordinator ?? .init())
        self.annotations = annotations
        self.overlays = overlays
        self.overlayRenderer = overlayRenderer
        self.annotationView = annotationView
        self.annotationSelectionHandler = annotationSelectionHandler
        self.primaryMapItemAction = primaryMapItemAction
        self.additionalMapItemActions = additionalMapItemActions
        self.showsLocationButton = showsLocationButton
        self.additionalTopRightButtons = additionalTopRightButtons
        self.standardSearchView = standardSearchView
        
        self._searchControllerShown = .constant(true)
        self.standardView = { EmptyView() }
        
        self.initialMapRect = initialRegion.map(MKMapRect.init)
    }
    
    /// Creates a new `MapItemPicker` showing a custom view by default with the given parameters.
    /// - Parameters:
    ///   - coordinator: The coordinator to use for this view. The default value is `nil`, which makes the view create one itself.
    ///   - annotations: The annotations to show on the map.
    ///   - annotationView: The block to retrieve the annotation view for an annotation.
    ///   - annotationSelectionHandler: The block to execute after an annotation was selected.
    ///   - overlays: The overlays to show on the map.
    ///   - overlayRenderer: The block to retrieve the overlay renderer for an overlay
    ///   - primaryMapItemAction: The primary action on map items, displayed with the accent color as the background.
    ///   - additionalMapItemActions: Additional map item actions.
    ///   - showsLocationButton: Whether the location button is shown in the top-left buttons. It will never be shown if there is no Location usage description in the Info.plist.
    ///   - additionalTopRightButtons: Additional buttons to display on the top-left
    ///   - initialRegion: The region to initially display.
    ///   - standardView: The view to display above the map, as a resizable bottom sheet.
    ///   - searchControllerShown: Whether the search controller is currently shown.
    ///   - standardSearchView: The view that is displayed below the search field. It receives the `MapItemPickerController` as an environment object. By default, this is a `StandardSearchView`.
    public init(
        coordinator: MapItemPickerController? = nil,
        annotations: [MKAnnotation] = [],
        annotationView: @escaping (MKAnnotation) -> MKAnnotationView = {
            fatalError("`annotationView` has not been implemented, but annotation was provided: \($0)")
        },
        annotationSelectionHandler: @escaping (MKAnnotation) -> Void = { _ in },
        overlays: [MKOverlay] = [],
        overlayRenderer: @escaping (MKOverlay) -> MKOverlayRenderer = {
            fatalError("`overlayRenderer` has not been implemented, but overlay was provided: \($0)")
        },
        primaryMapItemAction: MapItemPickerAction,
        additionalMapItemActions: [MapItemPickerAction] = [],
        showsLocationButton: Bool = true,
        additionalTopRightButtons: [MIPAction] = [],
        initialRegion: MKCoordinateRegion? = nil,
        standardView: @escaping () -> StandardView,
        searchControllerShown: Binding<Bool>,
        standardSearchView: @escaping () -> SearchView = { StandardSearchView() }
    ) {
        self._coordinator = .init(wrappedValue: coordinator ?? .init())
        self.annotations = annotations
        self.overlays = overlays
        self.overlayRenderer = overlayRenderer
        self.annotationView = annotationView
        self.annotationSelectionHandler = annotationSelectionHandler
        self.primaryMapItemAction = primaryMapItemAction
        self.additionalMapItemActions = additionalMapItemActions
        self.showsLocationButton = showsLocationButton
        self.additionalTopRightButtons = additionalTopRightButtons
        self.standardSearchView = standardSearchView
        
        self._searchControllerShown = searchControllerShown
        self.standardView = standardView
        
        self.initialMapRect = initialRegion.map(MKMapRect.init)
    }
    
    /// Creates a new `MapItemPicker` with the given parameters.
    /// - Parameters:
    ///   - coordinator: The coordinator to use for this view. The default value is `nil`, which makes the view create one itself.
    ///   - annotations: The annotations to show on the map.
    ///   - annotationView: The block to retrieve the annotation view for an annotation.
    ///   - annotationSelectionHandler: The block to execute after an annotation was selected.
    ///   - overlays: The overlays to show on the map.
    ///   - overlayRenderer: The block to retrieve the overlay renderer for an overlay
    ///   - primaryMapItemAction: The primary action on map items, displayed with the accent color as the background.
    ///   - additionalMapItemActions: Additional map item actions.
    ///   - showsLocationButton: Whether the location button is shown in the top-left buttons. It will never be shown if there is no Location usage description in the Info.plist.
    ///   - additionalTopRightButtons: Additional buttons to display on the top-left
    ///   - initialCoordinate: The coordinate to initially display. A suitable region will be calculated automatically.
    ///   - standardSearchView: The view that is displayed below the search field. It receives the `MapItemPickerController` as an environment object. By default, this is a `StandardSearchView`.
    public init(
        coordinator: MapItemPickerController? = nil,
        annotations: [MKAnnotation] = [],
        annotationView: @escaping (MKAnnotation) -> MKAnnotationView = {
            fatalError("`annotationView` has not been implemented, but annotation was provided: \($0)")
        },
        annotationSelectionHandler: @escaping (MKAnnotation) -> Void = { _ in },
        overlays: [MKOverlay] = [],
        overlayRenderer: @escaping (MKOverlay) -> MKOverlayRenderer = {
            fatalError("`overlayRenderer` has not been implemented, but overlay was provided: \($0)")
        },
        primaryMapItemAction: MapItemPickerAction,
        additionalMapItemActions: [MapItemPickerAction] = [],
        showsLocationButton: Bool = true,
        additionalTopRightButtons: [MIPAction] = [],
        initialCoordinate: CLLocationCoordinate2D,
        standardSearchView: @escaping () -> SearchView = { StandardSearchView() }
    ) where StandardView == EmptyView {
        self._coordinator = .init(wrappedValue: coordinator ?? .init())
        self.annotations = annotations
        self.overlays = overlays
        self.overlayRenderer = overlayRenderer
        self.annotationView = annotationView
        self.annotationSelectionHandler = annotationSelectionHandler
        self.primaryMapItemAction = primaryMapItemAction
        self.additionalMapItemActions = additionalMapItemActions
        self.showsLocationButton = showsLocationButton
        self.additionalTopRightButtons = additionalTopRightButtons
        self.standardSearchView = standardSearchView
        
        self._searchControllerShown = .constant(true)
        self.standardView = { EmptyView() }
        
        self.initialMapRect = .init(bestFor: [initialCoordinate])
    }
    
    /// Creates a new `MapItemPicker` showing a custom view by default with the given parameters.
    /// - Parameters:
    ///   - coordinator: The coordinator to use for this view. The default value is `nil`, which makes the view create one itself.
    ///   - annotations: The annotations to show on the map.
    ///   - annotationView: The block to retrieve the annotation view for an annotation.
    ///   - annotationSelectionHandler: The block to execute after an annotation was selected.
    ///   - overlays: The overlays to show on the map.
    ///   - overlayRenderer: The block to retrieve the overlay renderer for an overlay
    ///   - primaryMapItemAction: The primary action on map items, displayed with the accent color as the background.
    ///   - additionalMapItemActions: Additional map item actions.
    ///   - showsLocationButton: Whether the location button is shown in the top-left buttons. It will never be shown if there is no Location usage description in the Info.plist.
    ///   - additionalTopRightButtons: Additional buttons to display on the top-left
    ///   - initialCoordinate: The coordinate to initially display. A suitable region will be calculated automatically.
    ///   - standardView: The view to display above the map, as a resizable bottom sheet.
    ///   - searchControllerShown: Whether the search controller is currently shown.
    ///   - standardSearchView: The view that is displayed below the search field. It receives the `MapItemPickerController` as an environment object. By default, this is a `StandardSearchView`.
    public init(
        coordinator: MapItemPickerController? = nil,
        annotations: [MKAnnotation] = [],
        annotationView: @escaping (MKAnnotation) -> MKAnnotationView = {
            fatalError("`annotationView` has not been implemented, but annotation was provided: \($0)")
        },
        annotationSelectionHandler: @escaping (MKAnnotation) -> Void = { _ in },
        overlays: [MKOverlay] = [],
        overlayRenderer: @escaping (MKOverlay) -> MKOverlayRenderer = {
            fatalError("`overlayRenderer` has not been implemented, but overlay was provided: \($0)")
        },
        primaryMapItemAction: MapItemPickerAction,
        additionalMapItemActions: [MapItemPickerAction] = [],
        showsLocationButton: Bool = true,
        additionalTopRightButtons: [MIPAction] = [],
        initialCoordinate: CLLocationCoordinate2D,
        standardView: @escaping () -> StandardView,
        searchControllerShown: Binding<Bool>,
        standardSearchView: @escaping () -> SearchView = { StandardSearchView() }
    ) {
        self._coordinator = .init(wrappedValue: coordinator ?? .init())
        self.annotations = annotations
        self.overlays = overlays
        self.overlayRenderer = overlayRenderer
        self.annotationView = annotationView
        self.annotationSelectionHandler = annotationSelectionHandler
        self.primaryMapItemAction = primaryMapItemAction
        self.additionalMapItemActions = additionalMapItemActions
        self.showsLocationButton = showsLocationButton
        self.additionalTopRightButtons = additionalTopRightButtons
        self.standardSearchView = standardSearchView
        
        self._searchControllerShown = searchControllerShown
        self.standardView = standardView
        
        self.initialMapRect = .init(bestFor: [initialCoordinate])
    }
    
    public var body: some View {
        MapControllerHolder<StandardView, SearchView>(
            coordinator: coordinator,
            searcher: coordinator.searcher,
            searchControllerShown: $searchControllerShown,
            annotations: annotations,
            overlays: overlays,
            primaryAction: primaryMapItemAction,
            actions: additionalMapItemActions,
            standardView: standardView,
            standardSearchView: standardSearchView
        )
        .onRender {
            coordinator.annotationView = annotationView
            coordinator.overlayRenderer = overlayRenderer
            coordinator.annotationSelectionHandler = annotationSelectionHandler
        }
        .onAppear {
            if let initialMapRect {
                coordinator.set(rect: initialMapRect, animated: false)
            }
        }
        .edgesIgnoringSafeArea(NavigationView<EmptyView>.backgroundVisibilityAdjustable ? .top : [])
        .overlayCompatible(alignment: .topTrailing) {
            TopRightButtons(
                coordinator: coordinator,
                showsLocationButton: canShowLocationButton && showsLocationButton,
                additionalTopRightButtons: additionalTopRightButtons
            )
            .opacity(coordinator.shouldShowTopLeftButtons ? 1 : 0)
        }
    }
}
