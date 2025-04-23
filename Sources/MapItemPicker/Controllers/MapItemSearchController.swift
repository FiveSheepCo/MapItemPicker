import Foundation
import MapKit
import SwiftUI
import Combine

extension MapItemSearchController {
    enum State {
        case noSearch, searching, completed, error(Error?)
    }
}

final class MapItemSearchController: NSObject, ObservableObject {
    
    weak var coordinator: MapItemPickerController?
    
    @Published var searchTerm: String = .empty { didSet { reload() } }
    @Published var filteredCategories: [MapItemCategory] = [] { didSet { reload() } }
    
    @Published var completions: [MKLocalSearchCompletion] = []
    @Published var items: [MapItemController] = []
    
    private var cityItems: [MapItemController] = [] {
        didSet { reloadItems() }
    }
    private var otherItems: [MapItemController] = [] {
        didSet { reloadItems() }
    }
    
    // MARK: - State
    
    // TODO: handle errors
    var isNoSearch: Bool {
        [cityItemsState, otherItemsState, completionsState].allSatisfy { state in
            if case .noSearch = state {
                return true
            }
            return false
        }
    }
    var isAnySearching: Bool {
        [cityItemsState, otherItemsState, completionsState].any { state in
            if case .searching = state {
                return true
            }
            return false
        }
    }
    var areAllSearching: Bool {
        [cityItemsState, otherItemsState, completionsState].allSatisfy { state in
            if case .searching = state {
                return true
            }
            return false
        }
    }
    @Published var cityItemsState: State = .noSearch
    @Published var otherItemsState: State = .noSearch
    @Published var completionsState: State = .noSearch
    private var otherItemsRequestRegion: MKCoordinateRegion? = nil
    private var otherItemsResultRegion: MKCoordinateRegion? = nil
    
    // MARK: - Completion Items Storage
    
    @Published var searchedCompletion: MKLocalSearchCompletion? = nil {
        didSet {
            if searchedCompletion == nil {
                completionLocalSearch?.cancel()
                completionLocalSearch = nil
                completionItems = nil
            }
        }
    }
    private var completionLocalSearch: MKLocalSearch? = nil
    @Published var completionItems: [MapItemController]? = nil
    
    private let geocoder = CLGeocoder()
    private let completer = MKLocalSearchCompleter()
    private var lastLocalSearch: MKLocalSearch? = nil
    
    override init() {
        super.init()
        
        completer.resultTypes = .query
        completer.delegate = self
    }
    
    // MARK: - Region Change
    
    func regionChanged() {
        guard
            let currentRegion = coordinator?.region,
            let otherItemsResultRegion,
            let otherItemsRequestRegion,
            coordinator?.selectedMapItem == nil && coordinator?.selectedMapItemCluster == nil
        else { return }
        
        let regionChange = currentRegion.span.longitudeDelta / otherItemsRequestRegion.span.longitudeDelta
        if
            !MKMapRect(otherItemsRequestRegion).contains(MKMapPoint(currentRegion.center)) ||
            !(0.65...1.5).contains(regionChange)
        {
            reload()
        }
    }
    
    // MARK: - Filters
    
    func clearFilters() {
        filteredCategories = []
    }
    
    // MARK: - Reload
    
    private func reload() {
        guard let region = coordinator?.region else { return }
        
        reloadLocalSearch(region: region)
        reloadGeocoder()
        reloadCompleter(region: region)
    }
    
    private func reloadItems() {
        items = (cityItems + otherItems).removingDuplicates()
    }
}

// MARK: - Local Search
extension MapItemSearchController {
    fileprivate func reloadLocalSearch(region: MKCoordinateRegion) {
        self.otherItemsRequestRegion = region
        self.otherItemsResultRegion = nil
        self.lastLocalSearch?.cancel()
        self.lastLocalSearch = nil
        
        guard !searchTerm.isEmpty || !filteredCategories.isEmpty else {
            otherItems = []
            otherItemsState = .noSearch
            return
        }
        self.otherItemsState = .searching
        
        // TODO: When the region of a `MKLocalSearch.Request` is so small that no or few items would be returned, it just returns results near the user no matter where the region is. This region minimum size is different per category. We should just make the region bigger until we get a reasonable result. This is testable by navigating into an ocean and choosing any category.
        let search: MKLocalSearch
        let filter = filteredCategories.isEmpty ? nil : MKPointOfInterestFilter(including: filteredCategories.map(\.nativeCategory))
        if !searchTerm.isEmpty {
            let request = MKLocalSearch.Request()
            request.region = region
            request.pointOfInterestFilter = filter
            request.naturalLanguageQuery = searchTerm
            search = MKLocalSearch(request: request)
        } else {
            // TODO: let request = MKLocalPointsOfInterestRequest(coordinateRegion: region)
            let request = MKLocalSearch.Request()
            request.region = region
            request.naturalLanguageQuery = filteredCategories.first?.name
            request.pointOfInterestFilter = filter
            search = MKLocalSearch(request: request)
        }
        
        search.start { response, error in
            guard let response else {
                self.otherItemsState = .error(error)
                return
            }
            
            self.otherItems = response.mapItems.compactMap(MapItemController.init(mapItem:))
            self.otherItemsState = .completed
            self.otherItemsResultRegion = response.boundingRegion
        }
        lastLocalSearch = search
    }
}

// MARK: - Geocoder
extension MapItemSearchController {
    fileprivate func reloadGeocoder() {
        geocoder.cancelGeocode()
        
        guard !searchTerm.isEmpty else {
            cityItems = []
            cityItemsState = .noSearch
            return
        }
        self.cityItemsState = .searching
        
        geocoder.geocodeAddressString(searchTerm) { placemarks, error in
            guard let placemarks else {
                self.cityItemsState = .error(error)
                return
            }
                
            self.cityItems = placemarks.compactMap { MapItemController(mapItem: MKMapItem(placemark: .init(placemark: $0))) }
            self.cityItemsState = .completed
        }
    }
}

// MARK: - SearchCompleter
extension MapItemSearchController: MKLocalSearchCompleterDelegate {
    fileprivate func reloadCompleter(region: MKCoordinateRegion) {
        completer.cancel()
        
        guard !searchTerm.isEmpty else {
            completions = []
            completionsState = .noSearch
            return
        }
        self.completionsState = .searching
        
        completer.region = region
        // TODO: completer.pointOfInterestFilter = filter?
        completer.queryFragment = searchTerm
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // This hack is necessary since, as usual, apples frameworks don't work and `suggestor.resultTypes = .query` has NO effect.
        completions = completer.results.filter({ !$0.subtitle.contains(where: \.isNumber) })
        completionsState = .completed
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        completionsState = .error(error)
    }
}

// MARK: Completion Items
extension MapItemSearchController {
    
    var singularCompletionItem: MapItemController? {
        completionItems?.count == 1 ? completionItems?.first : nil
    }
    
    func search(with completion: MKLocalSearchCompletion) {
        completionLocalSearch?.cancel()
        completionItems = nil
        
        searchedCompletion = completion
        
        completionLocalSearch = MKLocalSearch(request: .init(completion: completion))
        completionLocalSearch!.start(completionHandler: { response, error in
            guard let response else {
                // TODO: ErrorHelper.shared.errorOccured(error!)
                return
            }
            
            RunLoop.main.perform {
                self.completionItems = response.mapItems.compactMap(MapItemController.init(mapItem:))
                if let singularCompletionItem = self.singularCompletionItem {
                    RecentMapItemsController.shared.addOrUpdate(mapItem: singularCompletionItem.item)
                }
            }
        })
    }
}
