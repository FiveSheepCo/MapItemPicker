import MapKit

extension MapItemController {
    
    func loadLookAround() {
        guard case .notLoaded = lookaroundLoadingState, #available(iOS 16.0, *) else { return }
        lookaroundLoadingState = .inProgress
        
        Task {
            let sceneRequest = MKLookAroundSceneRequest(coordinate: item.location)
            do {
                if let scene = try await sceneRequest.scene {
                    lookaroundLoadingState = .success
                    lookaroundScene = scene
                } else {
                    lookaroundLoadingState = .successWithoutResult
                }
            }
            catch {
                lookaroundLoadingState = .error(error)
            }
        }
    }
}
