import Foundation
import SwiftUI
import MapKit

struct MapItemActionButtons: View {
    enum Constants {
        static let spacing: CGFloat = 8
    }
    
    let coordinator: MapItemPickerController
    let item: MapItem
    let primaryAction: MapItemPickerAction
    let actions: [MapItemPickerAction]
    
    @State var height: CGFloat? = nil
    
    struct Single: View {
        @Environment(\.colorScheme) var colorScheme
        
        let coordinator: MapItemPickerController
        let item: MapItem
        
        let imageName: String
        let text: LocalizedStringKey
        var textIsFromModule: Bool = true
        let action: MapItemPickerAction.ActionType
        var isProminent = false
        let width: CGFloat
        
        var inner: some View {
            VStack(spacing: 4) {
                if #available(iOS 16.0, *) {
                    Image(systemName: imageName)
                        .fontWeight(.semibold)
                    Text(text, bundle: textIsFromModule ? .module : .main)
                        .fontWeight(.semibold)
                } else {
                    Image(systemName: imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 14)
                    Text(text, bundle: textIsFromModule ? .module : .main)
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 8)
            .frame(width: width)
        }
        
        func subActionsView(for subActions: [MapItemPickerAction]) -> some View {
            ForEach(subActions) { subAction in
                Single(
                    coordinator: coordinator,
                    item: item,
                    imageName: subAction.imageName,
                    text: subAction.title,
                    textIsFromModule: false,
                    action: subAction.action,
                    width: width
                )
            }
        }
        
        @ViewBuilder var button: some View {
            switch action {
            case .single(let action):
                Button {
                    if action(item) {
                        coordinator.manuallySet(selectedMapItem: nil)
                        coordinator.searcher.searchTerm = .empty
                    }
                } label: { inner }
            case .subActions(let subActions):
                if #available(iOS 14, *) {
                    Menu { subActionsView(for: subActions) } label: { inner }
                } else {
                    inner.contextMenu { subActionsView(for: subActions) }
                }
            }
        }
        
        var body: some View {
            button
                .foregroundColor(!isProminent && colorScheme == .light ? .accentColor : .white)
                .background(isProminent ? Color.accentColor : Color.secondarySystemBackground)
                .cornerRadius(8)
        }
    }
    
    func single(for action: MapItemPickerAction, isProminent: Bool = false, width: CGFloat) -> some View {
        Single(
            coordinator: coordinator,
            item: item,
            imageName: action.imageName,
            text: action.title,
            textIsFromModule: false,
            action: action.action,
            isProminent: isProminent,
            width: width
        )
    }
    
    var numberOfItems: Int {
        1 + actions.count + (item.phone == nil ? 0 : 1) + (item.website == nil ? 0 : 1)
    }
    
    func buttons(buttonWidth: CGFloat) -> some View {
        HStack(spacing: Constants.spacing) {
                single(for: primaryAction, isProminent: true, width: buttonWidth)
                ForEach(actions) { action in
                    single(for: action, width: buttonWidth)
                }
                if let phone = item.phone {
                    Single(
                        coordinator: coordinator,
                        item: item,
                        imageName: "phone.fill",
                        text: "itemSheet.action.call",
                        action: .single({ _ in
                            UIApplication.shared.open(URL(string: "telprompt://\(phone.filter({ !$0.isWhitespace }))")!)
                            return false
                        }),
                        width: buttonWidth
                    )
                }
                if let website = item.website {
                    Single(
                        coordinator: coordinator,
                        item: item,
                        imageName: "safari",
                        text: "itemSheet.action.visitWebsite",
                        action: .single({ _ in
                            UIApplication.shared.open(URL(string: website)!)
                            return false
                        }),
                        width: buttonWidth
                    )
                }
        }
    }
    
    var body: some View {
        GeometryReader { proxy in
            let numberOfItems = self.numberOfItems
            let numberOfItemsFloat = CGFloat(numberOfItems)
            Group {
                if numberOfItems <= 4 {
                    buttons(buttonWidth: (proxy.size.width - (numberOfItemsFloat - 1) * Constants.spacing) / numberOfItemsFloat)
                } else {
                    ScrollView(.horizontal) {
                        buttons(buttonWidth: proxy.size.width / 4.5)
                    }
                }
            }
            .sizeReader { size in
                if size.height != height {
                    height = size.height
                }
            }
        }
        .frame(height: height)
    }
}
