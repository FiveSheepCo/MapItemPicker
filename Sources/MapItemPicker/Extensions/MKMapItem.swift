import MapKit
import SwiftUI

extension MKMapItem: @retroactive Identifiable {
    public var id: Int {
        hashValue
    }
}
