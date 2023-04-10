import MapKit
import SwiftUI

@available(iOS 16.0, *)
extension MKMapConfiguration {
    static var cases: [MKMapConfiguration] {
        let traffic = MKStandardMapConfiguration()
        traffic.showsTraffic = true
        return [MKStandardMapConfiguration(), traffic, MKHybridMapConfiguration()]
    }
    
    var imageName: String {
        if self is MKHybridMapConfiguration {
            return "globe.europe.africa.fill"
        } else if let standard = self as? MKStandardMapConfiguration, standard.showsTraffic {
            return "car"
        }
        
        return "map"
    }
    
    var title: LocalizedStringKey {
        if self is MKHybridMapConfiguration {
            return "MKMapConfiguration.title.hybrid"
        } else if let standard = self as? MKStandardMapConfiguration, standard.showsTraffic {
            return "MKMapConfiguration.title.traffic"
        }
        
        return "MKMapConfiguration.title.standard"
    }
}
