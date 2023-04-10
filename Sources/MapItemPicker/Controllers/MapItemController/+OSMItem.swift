import Foundation

extension MapItemController {
    
    convenience init?(place: OSMItem) {
        guard let name = place.name  else { return nil }
        
        self.init(
            item: .init(
                name: name,
                location: .init(latitude: 0, longitude: 0), // TODO: This
                region: nil // TODO: This?
            )
        )
        update(with: place)
        
        fatalError()
    }
    
    func loadOSMItem() {
        guard case .notLoaded = oSMItemLoadingState else { return }
        oSMItemLoadingState = .inProgress
        
        Task {
            do {
                guard let item = try await OSMItem.retrieve(for: item) else {
                    oSMItemLoadingState = .successWithoutResult
                    return
                }
                self.update(with: item)
            }
            catch {
                oSMItemLoadingState = .error(error)
            }
        }
    }
    
    private func update(with place: OSMItem) {
        oSMItemLoadingState = .success
        
        var item = self.item
        
        item.identifiers[.openStreetMap] = place.id
        
        item.notes ?= place.description
        item.street ?= place.street
        item.housenumber ?= place.housenumber
        item.postcode ?= place.postcode
        item.city ?= place.city
        
        item.phone ?= place.phone
        item.website ?= place.website
        
        item.wikidataBrand ?= place.wikidataBrand
        item.wikipediaBrand ?= place.wikipediaBrand
        
        item.hasVegetarianFood ?= place.hasVegetarianFood
        item.hasVeganFood ?= place.hasVeganFood
        
        item.indoorSeating ?= place.indoorSeating
        item.outdoorSeating ?= place.outdoorSeating
        item.internetAccess ?= place.internetAccess
        item.smoking ?= place.smoking
        item.takeaway ?= place.takeaway
        item.wheelchair ?= place.wheelchair
        
        item.level ?= place.level
        
        item.openingHours ?= place.openingHours
        
        self.item = item
    }
}
