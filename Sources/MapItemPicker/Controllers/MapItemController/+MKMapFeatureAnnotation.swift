import Foundation
import MapKit

extension MapItemController {
    
    @available(iOS 16.0, *)
    convenience init?(mapFeatureAnnotation: MKMapFeatureAnnotation) {
        guard let name = mapFeatureAnnotation.title ?? mapFeatureAnnotation.subtitle else { return nil }
        
        self.init(
            item: .init(
                name: name,
                location: mapFeatureAnnotation.coordinate,
                featureAnnotationType: .init(rawValue: mapFeatureAnnotation.featureType.rawValue)
            )
        )
        
        originatingMapFeatureAnnotation = mapFeatureAnnotation
    }
}
