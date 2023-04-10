import Foundation
import SwiftUI

/// An action to display for a map item.
public struct MapItemPickerAction: Identifiable {
    
    /// Block to execute when an action is selected by the user. The return value describes whether to dismiss the map item sheet after selection.
    public typealias Handler = (MapItem) -> Bool
    
    /// The type of action.
    public enum ActionType {
        /// An action that has a single handler that is executed when tapped on the action button.
        case single(Handler)
        /// An action that has subactions. These appear in form of a menu resp. submenu when the action is tapped.
        case subActions([MapItemPickerAction])
    }
    
    public let id = UUID()
    
    /// The title of the action.
    public let title: LocalizedStringKey
    /// The system image name of the action.
    public let imageName: String
    /// The type of action that is executed when the corresponding button or menu item is tapped.
    public let action: ActionType
    
    /// Creates a `MapItemPickerAction` from the given parameters.
    /// - Parameters:
    ///   - title: The title of the action.
    ///   - imageName: The system image name of the action.
    ///   - handler: The action that is executed when the corresponding button or menu item is tapped.
    public init(title: LocalizedStringKey, imageName: String, handler: @escaping (MapItem) -> Bool) {
        self.title = title
        self.imageName = imageName
        self.action = .single(handler)
    }
    
    /// Creates a `MapItemPickerAction` from the given parameters.
    /// - Parameters:
    ///   - title: The title of the action.
    ///   - imageName: The system image name of the action.
    ///   - subActions: The actions that are displayed in a (sub-) menu when the corresponding button or menu item is tapped.
    public init(title: LocalizedStringKey, imageName: String, subActions: [MapItemPickerAction]) {
        self.title = title
        self.imageName = imageName
        self.action = .subActions(subActions)
    }
}
