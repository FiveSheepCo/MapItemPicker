import Foundation

infix operator ?= : AssignmentPrecedence
extension Optional {
    static func ?=(lhs: inout Self, rhs: Self) {
        if case .none = lhs {
            lhs = rhs
        }
    }
}
