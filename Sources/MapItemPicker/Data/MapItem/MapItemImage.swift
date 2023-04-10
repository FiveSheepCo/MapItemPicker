import Foundation
import SwiftUI

struct MapItemImage: Identifiable, Equatable {
    
    static func ==(lhs: MapItemImage, rhs: MapItemImage) -> Bool {
        lhs.url == rhs.url
    }
    
    enum Source: String {
        case wikipedia
        
        var nameLocalizationKey: String {
            "image.source.\(rawValue)"
        }
    }
    
    var id: String { url.absoluteString }
    
    let url: URL
    let thumbnailUrl: URL
    let description: String?
    
    let source: Source
    let sourceUrl: URL
}
