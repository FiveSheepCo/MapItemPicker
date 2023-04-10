import Foundation
import MapKit

/// A protocol that is used to check whether two `MKOverlay`s are equal.
///
/// - note: In a `ConfigurableMapItemPicker`, elements are updated when they are not equal and retained when they are. When `MKOverlay`s don't implement the `MapOverlayEquatable` protocol, they are updated when they are not the exact object instance anymore.
public protocol MapOverlayEquatable: MKOverlay {
    func overlayIsEqual(to other: MapOverlayEquatable) -> Bool
}
