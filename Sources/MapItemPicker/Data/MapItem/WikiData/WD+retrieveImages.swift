import Foundation
import SchafKit

extension WDItem {
    static private func decodeImageInfos(
        from data: Data,
        isFromViewCategory: Bool = false
    ) throws -> [MapItemImage]? {
        let raw = try JSONDecoder().decode(_RawImageInfoResult.self, from: data)
            .query.pages.values
            .flatMap({ $0.imageinfo })
            .filter({ info in
                if isFromViewCategory {
                    let categories = info.extmetadata.Categories.value
                    
                    // There are a lot of very old images in this view category, which is why we're going to remove anything that looks even remotely strange.
                    // This gets rid of all images with a category that looks like a year before 2000.
                    guard categories.regexMatches(with: "\\D1?\\d\\d\\d\\D")!.isEmpty else { return false }
                    
                    // Remove things that are no photographs.
                    guard !["lithograph", "engraving", "etching"].contains(categories.lowercased()) else { return false }
                }
                
                return true
            })
            .sorted(by: \.extmetadata.DateTimeOriginal.value, ascending: false)
            .sorted(by: \.extmetadata.Categories.value.count, ascending: false)
        
        return raw.compactMap({
            if
                let url = URL(string: $0.url),
                let thumbnailUrl = URL(string: $0.thumburl),
                let sourceUrl = URL(string: $0.descriptionurl)
            {
                return MapItemImage(
                    url: url,
                    thumbnailUrl: thumbnailUrl,
                    description: $0.extmetadata.ImageDescription?.value,
                    source: .wikipedia,
                    sourceUrl: sourceUrl
                )
            }
            return nil
        })
    }
    
    static func retrieveViewCategoryImages(for mapItem: MapItem) async throws -> [MapItemImage]? {
        guard let id = mapItem.identifiers[.wikimediaCommonsCategory] else { return nil }
        
        let category = id.urlParameterEncoded
        let url = "https://commons.wikimedia.org/w/api.php?action=query&generator=categorymembers&gcmtitle=\(category)&gcmlimit=100&gcmtype=file&prop=imageinfo&iiprop=extmetadata%7Curl&format=json&iiurlheight=400"
        let data = try await SKNetworking.request(url: url).data
        
        return try decodeImageInfos(from: data, isFromViewCategory: true)
    }
    
    static func retrieveStandardImages(for mapItem: MapItem) async throws -> [MapItemImage]? {
        let prefix = "File%3A"
        let separator = "%7C\(prefix)"
        let filenames = [
            mapItem.identifiers[.wikidataCommonsImageFilename],
            mapItem.identifiers[.wikidataCommonsNighttimeViewImageFilename]
        ]
        .removingNils()
        
        guard !filenames.isEmpty else { return nil }
        
        let titles = prefix + filenames.joined(separator: separator)
        let url = "https://commons.wikimedia.org/w/api.php?action=query&prop=imageinfo&iiprop=extmetadata%7Curl&redirects&format=json&iiurlheight=400&titles=\(titles)"
        
        let data = try! await SKNetworking.request(url: url).data
        
        return try decodeImageInfos(from: data)
    }
}

private struct _RawImageInfoResult: Decodable {
    struct ExtMetadata: Decodable {
        struct StringValue: Decodable {
            let value: String
        }
        
        let Categories: StringValue
        let License: StringValue?
        let DateTimeOriginal: StringValue
        let ImageDescription: StringValue?
    }
    
    struct ImageInfo: Decodable {
        let url: String
        let thumburl: String
        let descriptionurl: String
        
        let extmetadata: ExtMetadata
    }
    
    struct Page: Decodable {
        let imageinfo: [ImageInfo]
    }
    
    struct Query: Decodable {
        let pages: [String: Page]
    }
    
    let query: Query
}
