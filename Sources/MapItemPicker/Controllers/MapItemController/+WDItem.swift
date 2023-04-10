import Foundation

extension MapItemController {
    
    func loadWDItem() {
        guard case .notLoaded = wDItemLoadingState else { return }
        wDItemLoadingState = .inProgress
        
        Task {
            do {
                guard let item = try await WDItem.retrieve(for: item) else {
                    wDItemLoadingState = .successWithoutResult
                    return
                }
                self.update(with: item)
                self.loadWDItemImages()
            }
            catch {
                wDItemLoadingState = .error(error)
            }
        }
    }
    
    func loadWDItemImages() {
        guard
            case .notLoaded = wDItemImagesLoadingState,
            case .notLoaded = wDItemViewCategoryImagesLoadingState
        else { return }
        
        wDItemImagesLoadingState = .inProgress
        wDItemViewCategoryImagesLoadingState = .inProgress
        
        Task {
            // Standard Image + Nighttime View Image
            do {
                guard let images = try await WDItem.retrieveStandardImages(for: self.item) else {
                    wDItemImagesLoadingState = .notLoaded
                    return
                }
                
                add(images: images)
                wDItemImagesLoadingState = .success
            }
            catch {
                wDItemImagesLoadingState = .error(error)
            }
            
            // View Category
            do {
                guard let images = try await WDItem.retrieveViewCategoryImages(for: self.item) else {
                    wDItemViewCategoryImagesLoadingState = .notLoaded
                    return
                }
                
                add(images: images)
                wDItemViewCategoryImagesLoadingState = .success
            }
            catch {
                wDItemViewCategoryImagesLoadingState = .error(error)
            }
        }
    }
    
    private func update(with place: WDItem) {
        wDItemLoadingState = .success
        
        item.identifiers[.wikidata] = place.identifier
        if let commonsImageCatagory = place.commonsImageCatagory {
            item.identifiers[.wikimediaCommonsCategory] = commonsImageCatagory
        }
        if let wikidataCommonsImageFilename = place.imageFileTitle {
            item.identifiers[.wikidataCommonsImageFilename] = wikidataCommonsImageFilename
        }
        if let wikidataCommonsNighttimeViewImageFilename = place.nighttimeImageFileTitle {
            item.identifiers[.wikidataCommonsNighttimeViewImageFilename] = wikidataCommonsNighttimeViewImageFilename
        }
        
        item.categoryString ?= place.type ?? place.description
        item.wikiDescription ?= place.description
        item.wikipediaURL ?= place.url
        item.website ?= place.website

        item.area ?= place.area
        item.altitude ?= place.altitude
        item.population ?= place.population
    }
}
