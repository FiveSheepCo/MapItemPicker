import MapKit
import SwiftUI

extension MKMapItem: Identifiable {
    public var id: Int {
        hashValue
    }
}
