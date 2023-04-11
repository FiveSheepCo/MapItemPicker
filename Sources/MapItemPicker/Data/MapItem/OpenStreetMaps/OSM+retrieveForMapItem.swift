import Foundation
import MapKit
import SchafKit

public extension OSMItem {
    static func retrieve(for mapItem: MapItem) async throws -> OSMItem? {
        
        func normalize(string: String) -> String { // TODO: str. -> strasse, etc.
            let lowercased = string.lowercased()
            let lettersOnly = lowercased.filter(\.isLetter)
            
            if lettersOnly.isEmpty {
                return lowercased
            }
            return lettersOnly
        }
        
        let c = mapItem.location
        let requestString = "way[\"amenity\"](around:100,\(c.latitude),\(c.longitude));".replacingOccurrences(of: "\"", with: "%22")
        
        let data = try await OpenStreetMapOverpassAPI.shared.send(request: requestString)
        let places = try JSONDecoder().decode(TopLevelItemDecoding.self, from: data)
        
        let itemName = normalize(string: mapItem.name)
        
        let itemStreet: String? = mapItem.street.map(normalize(string:))
        let houseNumber: String? = mapItem.housenumber?.lowercased()
        
        let itemPostcode = mapItem.postcode?.lowercased()
        
        let minimumScore = 6.0
        var currentPlace: OSMItem?
        var currentScore: Double? = nil
        for place in places.elements.compactMap(\.tags) {
            var score = 0.0
            
            if let name = place.name {
                let normalized = normalize(string: name)
                if itemName == normalized {
                    score += 10
                } // TODO: levenshtein
            }
            
            if let itemStreet, let street = place.street, itemStreet == normalize(string: street) {
                score += 3
            }
            
            if let itemNumber = houseNumber, itemNumber == place.housenumber?.lowercased() {
                score += 3
            }
            
            if let itemPostcode = itemPostcode, itemPostcode == place.postcode?.lowercased() {
                score += 2
            }
            
            // TODO: Location
            
            if score >= minimumScore {
                if let currentScore, currentScore > score {
                    continue
                }
                currentPlace = place
                currentScore = score
            }
        }
        
        return currentPlace
    }
}

class OpenStreetMapOverpassAPI {
    static let shared = OpenStreetMapOverpassAPI(url: "https://overpass-api.de/api")
    
    let endpoint: SKNetworking.Endpoint
    
    init(url: String) {
        endpoint = .init(url: url)
    }
    
    func send(request: String) async throws -> Data {
        try await endpoint.request(path: "interpreter?data=[out:json];(\(request));out;%3E;").data
    }
}

private struct TopLevelItemDecoding: Decodable {
    struct Element: Decodable {
        
        let type: String
        let id: Int
        
        // Way
        let nodes: [Int]?
        let tags: OSMItem?
        
        // Node
        let lat: Double?
        let lon: Double?
    }
    
    let elements: [Element]
}
