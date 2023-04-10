import CoreLocation

public class CLCodableCircularRegion: CLCircularRegion, Codable {
    private enum CodingKeys: String, CodingKey {
        case center, radius, identifier
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(center, forKey: .center)
        try container.encode(radius, forKey: .radius)
        try container.encode(identifier, forKey: .identifier)
    }
    
    required public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.init(
            center: try container.decode(CLLocationCoordinate2D.self, forKey: .center),
            radius: try container.decode(CLLocationDistance.self, forKey: .radius),
            identifier: try container.decode(String.self, forKey: .identifier)
        )
    }
}
