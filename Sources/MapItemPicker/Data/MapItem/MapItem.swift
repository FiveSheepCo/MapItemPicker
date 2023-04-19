import Foundation
import MapKit
import SwiftUI
import AddressBook
import SchafKit

public struct MapItem: Equatable, Hashable, Codable {
    public init(name: String, location: CLLocationCoordinate2D, region: CLCodableCircularRegion? = nil, featureAnnotationType: FeatureType? = nil, category: MapItemCategory? = nil, notes: String? = nil, street: String? = nil, housenumber: String? = nil, postcode: String? = nil, cityRegion: String? = nil, city: String? = nil, state: String? = nil, stateRegion: String? = nil, country: String? = nil, phone: String? = nil, website: String? = nil, wikidataBrand: String? = nil, wikipediaBrand: String? = nil, hasVegetarianFood: ExclusivityBool? = nil, hasVeganFood: ExclusivityBool? = nil, indoorSeating: PlaceBool? = nil, outdoorSeating: PlaceBool? = nil, internetAccess: InternetAccessType? = nil, smoking: PlaceBool? = nil, takeaway: ExclusivityBool? = nil, wheelchair: WheelchairBool? = nil, level: String? = nil, openingHours: OpeningHours? = nil) {
        self.name = name
        self.location = location
        self.region = region
        self.featureAnnotationType = featureAnnotationType
        self.identifiers = [:]
        self.category = category
        self.notes = notes
        self.street = street
        self.housenumber = housenumber
        self.postcode = postcode
        self.cityRegion = cityRegion
        self.city = city
        self.state = state
        self.stateRegion = stateRegion
        self.country = country
        self.phone = phone
        self.website = website
        self.wikidataBrand = wikidataBrand
        self.wikipediaBrand = wikipediaBrand
        self.hasVegetarianFood = hasVegetarianFood
        self.hasVeganFood = hasVeganFood
        self.indoorSeating = indoorSeating
        self.outdoorSeating = outdoorSeating
        self.internetAccess = internetAccess
        self.smoking = smoking
        self.takeaway = takeaway
        self.wheelchair = wheelchair
        self.level = level
        self.openingHours = openingHours
    }
    
    enum IdentifierType: String, Codable {
        case openStreetMap, wikidata, wikimediaCommonsCategory, wikidataCommonsImageFilename, wikidataCommonsNighttimeViewImageFilename
    }
    
    public let name: String
    public let location: CLLocationCoordinate2D
    public var region: CLCodableCircularRegion?
    public let featureAnnotationType: FeatureType?
    
    var identifiers: [IdentifierType: String]
    
    public var altitude: Int?
    public var area: Double?
    public var population: Int?
    
    public var category: MapItemCategory?
    public var categoryString: String?
    public var wikiDescription: String?
    
    public var notes: String?
    
    public var street: String?
    public var housenumber: String?
    public var postcode: String?
    public var cityRegion: String?
    public var city: String?
    public var state: String?
    public var stateRegion: String?
    public var country: String?
    
    public var inlandWater: String?
    public var ocean: String?
    
    public var phone: String?
    public var website: String?
    
    public var wikidataBrand: String?
    public var wikipediaBrand: String?
    public var wikipediaURL: String?
    
    public var hasVegetarianFood: ExclusivityBool?
    public var hasVeganFood: ExclusivityBool?
    
    public var indoorSeating: PlaceBool?
    public var outdoorSeating: PlaceBool?
    public var internetAccess: InternetAccessType?
    public var smoking: PlaceBool?
    public var takeaway: ExclusivityBool?
    public var wheelchair: WheelchairBool?
    
    public var level: String?
    
    public var openingHours: OpeningHours?
    
    var imageName: String {
        if let category {
            return category.imageName
        }
        guard let featureAnnotationType, featureAnnotationType == .territory else {
            return "mappin"
        }
        
        if street != nil {
            return "mappin"
        }
        if city != nil {
            return "building.2.fill"
        }
        return "flag.fill"
    }
    
    var color: Color {
        .init(uiColor: uiColor)
    }
    
    var uiColor: UIColor {
        if let category {
            return category.color
        }
        
        if featureAnnotationType == .territory && street == nil {
            return .gray
        }
        
        return .init(red: 1, green: 0.25, blue: 0.25)
    }
    
    var typeName: String {
        if let category {
            return category.name
        }
        if let categoryString {
            return categoryString.capitalized
        }
        
        // TODO: Make this functional without a `featureAnnotationType` (See README TODO #1)
        guard let featureAnnotationType, featureAnnotationType == .territory else {
            return "mapItem.type.item".moduleLocalized
        }
        
        if street != nil {
            return "mapItem.type.address".moduleLocalized
        }
        if cityRegion != nil && cityRegion != city {
            return "mapItem.type.cityRegion".moduleLocalized
        }
        if city != nil {
            return "mapItem.type.city".moduleLocalized
        }
        if inlandWater != nil {
            return "mapItem.type.inlandWater".moduleLocalized
        }
        if state != nil {
            return "mapItem.type.state".moduleLocalized
        }
        if ocean != nil {
            return "mapItem.type.ocean".moduleLocalized
        }
        if country != nil {
            return "mapItem.type.country".moduleLocalized
        }
        return "mapItem.type.territory".moduleLocalized
    }
    
    var addressLines: [String] {
        [
            [street, housenumber].removingNils().joined(separator: " "),
            [postcode, city].removingNils().joined(separator: " "),
            state,
            country
        ]
        .removingNils()
        .filter({ $0.count > 1 })
    }
    
    var readableAddress: String? {
        [[street, housenumber].removingNils().joined(separator: " "), city, state, country]
            .removingNils()
            .filter({ $0.count > 1 })
            .enumerated()
            .filter({ $0.offset > 0 || $0.element != self.name })
            .map(\.element)
            .joined(separator: ", ")
            .nilIfEmpty
    }
    
    var subtitle: String {
        if let readableAddress {
            return "\(typeName) · \(readableAddress)"
        }
        return typeName
    }
    
    public var nativeMapItemRepresentation: MKMapItem {
        let mapItem = MKMapItem(
            placemark: MapItemMKPlacemark(mapItem: self)
        )
        
        mapItem.name = name
        mapItem.pointOfInterestCategory = category?.nativeCategory
        mapItem.phoneNumber = phone
        mapItem.url = website.map({ URL(string: $0) }) ?? nil
        
        return mapItem
    }
    
    public var nativeLocation: CLLocation {
        .init(latitude: location.latitude, longitude: location.longitude)
    }
}

class MapItemMKPlacemark: MKPlacemark {
    let mapItem: MapItem
    
    init(mapItem: MapItem) {
        self.mapItem = mapItem
        
        super.init(coordinate: mapItem.location)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var thoroughfare: String? {
        mapItem.street
    }
    
    override var subThoroughfare: String? {
        mapItem.housenumber
    }
    
    override var postalCode: String? {
        mapItem.postcode
    }
    
    override var locality: String? {
        mapItem.city
    }
    
    override var subLocality: String? {
        mapItem.cityRegion
    }
    
    override var administrativeArea: String? {
        mapItem.state
    }
    
    override var subAdministrativeArea: String? {
        mapItem.stateRegion
    }
    
    override var country: String? {
        mapItem.country
    }
    
    // TODO: Country Code
}
