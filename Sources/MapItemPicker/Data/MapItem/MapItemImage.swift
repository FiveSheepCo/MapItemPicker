import Foundation
import SwiftUI

struct MapItemImage: Identifiable, Hashable {
    
    enum Source: String {
        case wikipedia
        
        var nameLocalizationKey: String {
            "image.source.\(rawValue)"
        }
    }
    
    var id: String { url.absoluteString }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
    
    let url: URL
    let thumbnailUrl: URL
    let description: String?
    
    let source: Source
    let sourceUrl: URL
}
