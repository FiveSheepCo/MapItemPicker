import Foundation
import SchafKit

extension Int {
    func compatibleFormatted() -> String {
        if #available(iOS 15, *) {
            return formatted()
        }
        return Double(self).toFormattedString(decimals: 0)
    }
}
