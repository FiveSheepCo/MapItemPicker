import Foundation

struct WDItem: Codable {
    let identifier: String
    let description: String?
    let type: String?
    let commonsImageCatagory: String?
    let url: String?
    let population: Int?
    let area: Double?
    let website: String?
    let altitude: Int?
    let imageFileTitle: String?
    let nighttimeImageFileTitle: String?
}
