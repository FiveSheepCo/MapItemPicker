import Foundation
import MapKit

extension Array where Element: MKAnnotation {
    func contains(annotation: Element) -> Bool {
        guard let equatable = annotation as? MapAnnotationEquatable else {
            return contains(exactObject: annotation)
        }
        
        return any({ ($0 as? MapAnnotationEquatable)?.annotationIsEqual(to: equatable) ?? false })
    }
}

extension Array where Element: MKOverlay {
    func contains(overlay: Element) -> Bool {
        guard let equatable = overlay as? MapOverlayEquatable else {
            return contains(exactObject: overlay)
        }
        
        return any({ ($0 as? MapOverlayEquatable)?.overlayIsEqual(to: equatable) ?? false })
    }
}
