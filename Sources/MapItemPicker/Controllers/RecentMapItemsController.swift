import Foundation
import SwiftUI
import Combine
import SchafKit

/// A controller that holds the most recently selected map items.
public class RecentMapItemsController: ObservableObject {
    /// The shared instance of `RecentMapItemsController`.
    public static let shared = RecentMapItemsController()
    
    // MARK: - Constants
    
    enum Constants {
        static let directory = SKDirectory.caches.directoryByAppending(path: MapItemPickerConstants.cacheDirectoryName, createIfNonexistant: true)
        
        static let recentMapItemsFilename = "recentMapItems.json"
        static let maximumNumberOfRecentMapItems = 20
    }
    
    // MARK: - Initializer
    
    private init() {
        recentMapItems = Constants.directory.getData(at: Constants.recentMapItemsFilename).map { data in
            (try? JSONDecoder().decode([MapItem].self, from: data)) ?? []
        } ?? []
    }
    
    // MARK: - Variables
    
    var currentMapItemControllerObserver: AnyCancellable?
    /// The most recently selected map items.
    @Published public private(set) var recentMapItems: [MapItem] {
        didSet {
            saveRecentMapItems()
        }
    }
    
    // MARK: - Public Functions
    
    /// Adds or updates the given map item.
    ///
    /// - note: If a similar map item is already in the stack, it will be removed and the given map item will be added to the top of the list.
    public func addOrUpdate(mapItem: MapItem) {
        var newMapItems = recentMapItems
        
        newMapItems.removeAll(where: {
            mapItem.name == $0.name && mapItem.location == $0.location
        })
        newMapItems.insert(mapItem, at: 0)
        
        while newMapItems.count > Constants.maximumNumberOfRecentMapItems {
            newMapItems.removeLast()
        }
        
        recentMapItems = newMapItems
    }
    
    // MARK: - Internal Functions
    
    func mapItemWasSelected(_ mapItemController: MapItemController?) {
        guard let mapItemController else {
            currentMapItemControllerObserver = nil
            return
        }
        
        addOrUpdate(mapItem: mapItemController.item)
        currentMapItemControllerObserver = mapItemController.objectWillChange.sink { _ in
            RunLoop.main.perform {
                self.addOrUpdate(mapItem: mapItemController.item)
            }
        }
    }
    
    private func saveRecentMapItems() {
        if let data = try? JSONEncoder().encode(recentMapItems) {
            Constants.directory.save(data: data, at: Constants.recentMapItemsFilename)
        }
    }
}
