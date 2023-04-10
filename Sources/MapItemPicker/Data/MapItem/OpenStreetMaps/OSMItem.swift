import Foundation
import SchafKit

public struct OSMItem: Decodable {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name", description = "description"
        case city = "addr:city", housenumber = "addr:housenumber", postcode = "addr:postcode", street = "addr:street"
        case brand = "brand", wikidataBrand = "brand:wikidata", wikipediaBrand = "brand:wikipedia"
        case amenity = "amenity", cuisine = "cuisine", hasVegetarianFood = "diet:vegetarian", hasVeganFood = "diet:vegan"
        case indoorSeating = "indoor_seating", outdoorSeating = "outdoor_seating", internetAccess = "internet_access", smoking = "smoking", takeaway = "takeaway", wheelchair = "wheelchair"
        case level = "level"
        case openingHours = "opening_hours"
        case phone = "phone", website = "website"
    }
    
    public let id: String?
    
    public let name: String?
    public let description: String?
    
    public let street: String?
    public let housenumber: String?
    public let postcode: String?
    public let city: String?
    
    public let phone: String?
    public let website: String?
    
    public let amenity: String? // TODO: Enum
    public let brand: String?
    public let wikidataBrand: String?
    public let wikipediaBrand: String?
    
    public let cuisine: String? // TODO: Enum
    public let hasVegetarianFood: ExclusivityBool?
    public let hasVeganFood: ExclusivityBool?
    
    public let indoorSeating: PlaceBool?
    public let outdoorSeating: PlaceBool?
    public let internetAccess: InternetAccessType?
    public let smoking: PlaceBool?
    public let takeaway: ExclusivityBool?
    public let wheelchair: WheelchairBool?
    
    public let level: String?
    
    public let openingHours: OpeningHours?
    
    /* TODO:
     "payment:american_express": "yes",
         "payment:maestro": "yes",
         "payment:mastercard": "yes",
         "payment:visa": "yes",
     "dogs": "no"
     "note:opening_hours": "oberer Teil des Restaurants hat ab 10:00 Uhr geöffnet",
     "operator"
     "contact:fax": "+49 911 2355033",
     "contact:phone": "+49 911 2355032",
     "toilets": "yes",
     see toilet thing
     website
     */
}

public enum WheelchairBool: String, Codable {
    case yes, no, limited, designated
}

public enum ExclusivityBool: String, Codable {
    case yes, no, only
}

public enum PlaceBool: String, Codable {
    case yes, no
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        let string = try container.decode(String.self)
        if string == "no" {
            self = .no
        } else {
            self = .yes
        }
    }
}

public enum InternetAccessType: String, Codable {
    case yes, no, wlan, terminal, service, wired
}


