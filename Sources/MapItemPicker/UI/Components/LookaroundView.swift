import SwiftUI
import MapKit

@available(iOS 16.0, *)
struct LookaroundView: UIViewControllerRepresentable {
    let lookaroundScene: MKLookAroundScene
    
    func makeUIViewController(context: Context) -> MKLookAroundViewController {
        MKLookAroundViewController(scene: lookaroundScene)
    }
    
    func updateUIViewController(_ uiViewController: MKLookAroundViewController, context: Context) {}
}
