import SwiftUI
import UIKit

extension Font {
    static var title3Compatible: Font {
        if #available(iOS 14, macOS 11, tvOS 14, watchOS 7, *) {
            return .title3
        } else {
            return .init(UIFont.preferredFont(forTextStyle: .title3))
        }
    }
}
