import SwiftUI
import MapKit

struct MapItemDisplaySheet: View {
    
    enum Constants {
        static let padding: CGFloat = 12
        static let sectionPadding: CGFloat = 8
    }
    
    let coordinator: MapItemPickerController?
    @ObservedObject var itemCoordinator: MapItemController
    let primaryAction: MapItemPickerAction?
    let actions: [MapItemPickerAction]
    let dismissHandler: (() -> Void)?
    let shouldScroll: Bool
    let shouldAddPadding: Bool
    
    var item: MapItem { itemCoordinator.item }
    
    var content: some View {
        VStack {
            Group {
                topScrollInfoView
                buttonSection
                imageSection
            }
            .padding(.bottom, 4)
            Group {
                aboutSection.padding(.top, 4)
                contactSection
                factsSection
                detailsSection
            }
            .padding(.bottom)
            legalSection
        }
        .padding(.horizontal, shouldAddPadding ? Constants.padding : 0)
    }
    
    var body: some View {
        VStack {
            header.padding([.horizontal, .top], shouldAddPadding ? Constants.padding : 0)
            if shouldScroll {
                ScrollView {
                    content
                }
            } else {
                content
            }
        }
        .onAppearAndChange(of: itemCoordinator, perform: { itemCoordinator in
            itemCoordinator.loadRemaining()
        })
    }
}
