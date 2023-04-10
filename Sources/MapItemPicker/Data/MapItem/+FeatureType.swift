import Foundation

extension MapItem {
    public enum FeatureType : Int, Codable {
        case pointOfInterest = 0
        case territory = 1
        case physicalFeature = 2
    }
}
