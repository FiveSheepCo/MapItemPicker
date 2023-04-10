import Foundation
import CoreLocation
import SchafKit

private let endpoint = SKNetworking.Endpoint(url: "https://query.wikidata.org/")

extension String {
    /// A URL-encoded version of the receiver.
    var urlParameterEncoded : String {
        // TODO: Option to percent encode space
        var allowedCharacters = CharacterSet.alphanumerics
        allowedCharacters.insert(charactersIn: "-_.~")
        
        return (self.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? self)
    }
}

extension WDItem {
    static private func buildQuery(name: String, location: CLLocationCoordinate2D) -> String {
        let geoPoint = "\"Point(\(location.longitude) \(location.latitude))\"^^geo:wktLiteral"
        let c = name.count
        let inQuery = (c-2...c+2).map(String.init).joined(separator: ",")
        let language = Locale.preferredLanguages.first?.components(separatedBy: ["_", "-"]).first ?? "en"
        
return """
SELECT
  ?item
  (SAMPLE(?article) as ?wikiURL)
  (group_concat(distinct ?itemType;separator=",") as ?types)
  (SAMPLE(?viewCategory) as $view)
  (SAMPLE(?itemDescription) as ?description)
  (group_concat(distinct ?itemLabel;separator=",") as ?label)
  (MIN($dist) as $distance)
  (SAMPLE(?itemPopulation) as ?population)
  (SAMPLE(?itemArea) as ?area)
  (SAMPLE(?itemWebsite) as ?website)
  (SAMPLE(?itemAltitude) as ?altitude)
  (SAMPLE(?itemImage) as ?image)
  (SAMPLE(?itemNighttimeImage) as ?nighttimeImage)
{
  SERVICE wikibase:around {
      ?item wdt:P625 ?location .
      bd:serviceParam wikibase:center \(geoPoint) .
      bd:serviceParam wikibase:radius "5" .
  }
  ?item rdfs:label ?itemLabel.
  FILTER (strlen(?itemLabel) IN (\(inQuery))).
  FILTER contains(lcase(?itemLabel), '\(name.lowercased())').
  OPTIONAL { ?item wdt:P576 ?dissolved. }
  FILTER(!BOUND(?dissolved)) # is not dissolved
  
  # Description
  OPTIONAL {
      ?item schema:description ?itemDescription
      FILTER (LANG(?itemDescription) = "\(language)").
  }
  # Item Type
  OPTIONAL {
     ?item wdt:P31 ?itemTypeType .
     ?itemTypeType rdfs:label ?itemType
     FILTER (LANG(?itemType) = "\(language)").
  }
  # Wikimedia Category
  OPTIONAL {
     ?item wdt:P8989 ?viewsId .
     ?viewsId rdfs:label ?viewCategory
     FILTER (LANG(?viewCategory) = "en").
  }
  # Wikipedia URL
  OPTIONAL {
      ?article schema:about ?item .
      ?article schema:inLanguage "\(language)" .
      ?article schema:isPartOf <https://\(language).wikipedia.org/> .
  }
  # Other Properties
  Optional { ?item wdt:P1082 ?itemPopulation }
  Optional { ?item p:P2046/psn:P2046/wikibase:quantityAmount ?itemArea }
  Optional { ?item wdt:P856 ?itemWebsite }
  Optional { ?item wdt:P2044 ?itemAltitude }
  Optional { ?item wdt:P18 ?itemImage }
  Optional { ?item wdt:P3451 ?itemNighttimeImage }
  
  BIND(geof:distance(\(geoPoint), ?location) as ?dist) # bind distance
  SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". } # set language
}
GROUP BY ?item
ORDER BY ?distance
""" // TODO: Language Stuff
    }
    
    private static func send(query: String) async throws -> Data {
        try await endpoint.request(
            path: "sparql?query=\(query.urlParameterEncoded)",
            options: [.headerFields(value: [.accept: "application/sparql-results+json"])]
        ).data
    }
    
    private static func retrieveImageFilename(for originatingUrl: String?) -> String? {
        guard
            let originatingUrl,
            originatingUrl.starts(with: "http://commons.wikimedia.org/wiki/Special:FilePath/")
        else { return nil }
        
        return originatingUrl[51...]
    }
    
    static func retrieve(for mapItem: MapItem) async throws -> WDItem? {
        let name = mapItem.name
        
        let query = buildQuery(name: name, location: mapItem.location)
        let data = try await send(query: query)
        
        let raw = try JSONDecoder().decode(_RawWDQueryResult.self, from: data)
        let results = raw.results.bindings.compactMap({ binding in
            Double(binding.distance.value).map({
                _WDQueryResult(
                    url: binding.item.value,
                    names: binding.label.value.components(separatedBy: ","),
                    type: binding.types?.value.components(separatedBy: ",").sorted(by: \.count).first,
                    description: binding.description?.value,
                    view: binding.view?.value,
                    distanceInKilometers: $0,
                    wikiURL: binding.wikiURL?.value,
                    population: binding.population?.value.toInt,
                    area: binding.area?.value.toDouble,
                    website: binding.website?.value,
                    altitude: binding.altitude?.value.toInt,
                    imageFileTitle: retrieveImageFilename(for: binding.image?.value),
                    nighttimeImageFileTitle: retrieveImageFilename(for: binding.nighttimeImage?.value)
                )
            })
        })
        
        let lowerName = name.lowercased()
        var lowestStringDistance = 3
        var bestResults: [_WDQueryResult] = []
        
        for result in results {
            guard let lowestLev = result.names.min(of: { singleName in
                singleName.lowercased().damerauLevenshtein(lowerName, max: lowestStringDistance + 1)
            }) else { continue }
            
            if lowestLev == lowestStringDistance {
                bestResults.append(result)
            } else if lowestLev < lowestStringDistance {
                lowestStringDistance = lowestLev
                bestResults = [result]
            }
        }
        
        let lowestUrlCount = bestResults.min(of: \.url.count)
        let bestResult = bestResults.filter({ $0.url.count == lowestUrlCount }).sorted(by: \.distanceInKilometers).first
        
        guard
            let bestResult,
            let bestIdentifier = bestResult.url.components(separatedBy: "/").last,
            bestIdentifier.first == "Q"
        else {
            return nil
        }
        
        return .init(
            identifier: bestIdentifier,
            description: bestResult.description,
            type: bestResult.type,
            commonsImageCatagory: bestResult.view,
            url: bestResult.wikiURL,
            population: bestResult.population,
            area: bestResult.area,
            website: bestResult.website,
            altitude: bestResult.altitude,
            imageFileTitle: bestResult.imageFileTitle,
            nighttimeImageFileTitle: bestResult.nighttimeImageFileTitle
        )
    }
}

// TODO: Remove?
//struct _RawWDEntityResult: Decodable {
//
//    struct Sitelink: Decodable {
//        let url: String
//    }
//
//    struct Statement: Decodable {
//        struct Value: Decodable {
//            let content: String
//        }
//
//        let value: Value
//    }
//
//    /// Labels by language identifier, e.g. ["en": "New York City"].
//    let labels: [String: String]
//    /// Descriptions by language identifier, e.g. ["en": "most populous city in the United States of America"].
//    let descriptions: [String: String]
//    /// Sitelinks by language identifier.
//    let sitelinks: [String: Sitelink]
//    /// Statements, which are basically references.
//    let statements: [String: [Statement]]
//}

struct _WDQueryResult {
    let url: String
    let names: [String]
    let type: String?
    let description: String?
    let view: String?
    let distanceInKilometers: Double
    let wikiURL: String?
    let population: Int?
    let area: Double?
    let website: String?
    let altitude: Int?
    let imageFileTitle: String?
    let nighttimeImageFileTitle: String?
}

struct _RawWDQueryResult: Decodable {
    
    struct StringBinding: Decodable {
        let value: String
    }
    
    struct Binding: Decodable {
        /// The url of the item, e.g. 'http://www.wikidata.org/entity/Q187725'
        let item: StringBinding
        /// The type of the item, e.g. 'town'
        let types: StringBinding?
        /// The description of the item, e.g. 'city in the German state of Bavaria'
        let description: StringBinding?
        /// The label of the item, e.g. 'Nuremberg'
        let label: StringBinding
        /// The distance in kilometers of the item, e.g. '2.1983287276152437'
        let distance: StringBinding
        /// A category to retrieve images in 'P8989', e.g. 'Category:Views of New York City'.
        let view: StringBinding?
        /// A local wiki URL, e.g. 'https://de.wikipedia.org/wiki/Nürnberg'.
        let wikiURL: StringBinding?
        
        let population: StringBinding?
        let area: StringBinding?
        let website: StringBinding?
        let altitude: StringBinding?
        
        let image: StringBinding?
        let nighttimeImage: StringBinding?
    }
    
    struct Results: Decodable {
        let bindings: [Binding]
    }
    
    let results: Results
}
