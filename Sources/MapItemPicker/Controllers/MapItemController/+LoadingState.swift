import Foundation

extension MapItemController {
    enum LoadingState {
        case notLoaded, inProgress, error(Error), successWithoutResult, success
    }
}
