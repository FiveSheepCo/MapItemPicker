import Foundation
import MapKit
import SchafKit

class MapItemController: NSObject, ObservableObject, Identifiable {
    
    let id = UUID()
    
    var coordinate: CLLocationCoordinate2D { item.location }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? MapItemController else {
            return false
        }
        
        return self.item == other.item
    }
    
    @BackgroundPublished var item: MapItem
    
    @available(iOS 16, *)
    var originatingMapFeatureAnnotation: MKMapFeatureAnnotation? {
        get { originatingMapFeatureAnnotationStorage as? MKMapFeatureAnnotation }
        set { originatingMapFeatureAnnotationStorage = newValue }
    }
    private var originatingMapFeatureAnnotationStorage: NSObject?
    
    @available(iOS 16, *)
    var lookaroundScene: MKLookAroundScene? {
        get { lookaroundSceneStorage as? MKLookAroundScene }
        set { lookaroundSceneStorage = newValue }
    }
    @BackgroundPublished private var lookaroundSceneStorage: NSObject?
    
    @BackgroundPublished private(set) var images: [MapItemImage] = []
    
    // MARK: - Loading States
    var mKMapItemLoadingState: LoadingState = .notLoaded
    var oSMItemLoadingState: LoadingState = .notLoaded
    var wDItemLoadingState: LoadingState = .notLoaded
    var wDItemImagesLoadingState: LoadingState = .notLoaded
    var wDItemViewCategoryImagesLoadingState: LoadingState = .notLoaded
    var lookaroundLoadingState: LoadingState = .notLoaded
    
    init(item: MapItem) {
        self.item = item
    }
    
    func loadRemaining() {
        loadMKMapItem()
        loadOSMItem()
        loadWDItem()
        loadLookAround()
    }
    
    func add(images: [MapItemImage]) {
        self.images = (self.images + images).removingDuplicates()
    }
}

extension MapItemController: MKAnnotation {
    
    var title: String? {
        self.item.name
    }
}
