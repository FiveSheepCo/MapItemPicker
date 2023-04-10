import Foundation
import MapKit

/// A protocol that is used to check whether two `MKAnnotation`s are equal.
///
/// - note: In a `ConfigurableMapItemPicker`, elements are updated when they are not equal and retained when they are. When `MKAnnotations` don't implement the `MapAnnotationEquatable` protocol, they are updated when they are not the exact object instance anymore.
public protocol MapAnnotationEquatable: MKAnnotation {
    func annotationIsEqual(to other: MapAnnotationEquatable) -> Bool
}
