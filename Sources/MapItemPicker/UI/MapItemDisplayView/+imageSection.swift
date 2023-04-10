import SwiftUI

private let imageHeight: CGFloat = 200
private let imageWidth: CGFloat = 150

extension MapItemDisplaySheet {
    
    struct ImageSection: View {
        @ObservedObject var itemCoordinator: MapItemController
        @State private var shownImage: MapItemImage?
        
        @ViewBuilder private var lookaroundView: some View {
            if #available(iOS 16, *), let lookaroundScene = itemCoordinator.lookaroundScene {
                LookaroundView(lookaroundScene: lookaroundScene)
                    .cornerRadius(8)
            }
        }
        
        var body: some View {
            if !itemCoordinator.images.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        lookaroundView.frame(width: imageWidth)
                        LazyHStack {
                            ForEach(itemCoordinator.images) { image in
                                Button {
                                    shownImage = image
                                } label: {
                                    AsyncImage(url: image.thumbnailUrl) { image in
                                        image.resizable().scaledToFill()
                                    } placeholder: {
                                        Color.gray.opacity(0.25)
                                    }
                                    .frame(width: imageWidth, height: imageHeight)
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                .frame(height: imageHeight)
                .fullScreenCover(item: $shownImage) { image in
                    ImageSheet(image: image, dismiss: { shownImage = nil })
                }
            } else {
                lookaroundView
                    .frame(height: imageHeight)
            }
        }
    }
    
    @ViewBuilder var imageSection: some View {
        ImageSection(itemCoordinator: itemCoordinator)
    }
}
