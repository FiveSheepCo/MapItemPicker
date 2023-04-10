import Foundation
import MapKit
import CoreLocation

extension MapItemController {
    
    convenience init?(mapItem: MKMapItem) {
        guard let name = mapItem.name else { return nil }
        
        self.init(
            item: .init(
                name: name,
                location: mapItem.placemark.coordinate
            )
        )
        update(with: mapItem)
    }
    
    func loadMKMapItem() {
        guard #available(iOS 16, *), case .notLoaded = mKMapItemLoadingState, let originatingMapFeatureAnnotation else { return }
        mKMapItemLoadingState = .inProgress
        
        Task {
            do {
                let item = try await MKMapItemRequest(mapFeatureAnnotation: originatingMapFeatureAnnotation).mapItem
                self.update(with: item)
            }
            catch {
                mKMapItemLoadingState = .error(error)
            }
        }
    }
    
    private func update(with mapItem: MKMapItem) {
        mKMapItemLoadingState = .success
        
        let placemark = mapItem.placemark
        var item = self.item
        
        if let category = mapItem.pointOfInterestCategory {
            item.category ?= MapItemCategory(nativeCategory: category)
        }
        
        if let region = mapItem.placemark.region as? CLCircularRegion {
            item.region = .init(center: region.center, radius: region.radius, identifier: region.identifier)
        }
        
        item.street ?= placemark.thoroughfare
        item.housenumber ?= placemark.subThoroughfare
        item.postcode ?= placemark.postalCode
        item.city ?= placemark.locality
        item.cityRegion ?= placemark.subLocality
        item.state ?= placemark.administrativeArea
        item.stateRegion ?= placemark.subAdministrativeArea
        item.country ?= placemark.country
        
        item.inlandWater ?= placemark.inlandWater
        item.ocean ?= placemark.ocean
        
        item.phone ?= mapItem.phoneNumber
        item.website ?= mapItem.url?.absoluteString
        
        self.item = item
    }
}
