import SwiftUI
import SchafKit

struct AsyncPhotoZoomView: View {
    let url: String
    
    @State var image: UIImage?
    
    var body: some View {
        if let image {
            PhotoZoomView(image: image)
        } else {
            VStack {
                Spacer()
                if #available(iOS 14.0, *) {
                    ProgressView()
                } else {
                    Text("search.loading", bundle: .module)
                }
                Spacer()
            }
            .onAppear {
                SKNetworking.request(url: url) { result in
                    switch result {
                    case .success(let result):
                        if let image = UIImage(data: result.data) {
                            self.image = image
                        }
                    case .failure:
                        // TODO: Show Error
                        break
                    }
                }
            }
        }
    }
}
