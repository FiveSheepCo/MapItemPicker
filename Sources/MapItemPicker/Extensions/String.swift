import Foundation

extension String {
    var moduleLocalized: String {
        NSLocalizedString(self, bundle: Bundle.module, comment: .empty)
    }
    
    func components(separatedBy strings: [String]) -> [String] {
        var result = [self]
        
        for separator in strings {
            result = result.flatMap({ $0.components(separatedBy: separator) })
        }
        
        return result
    }
    
    var capitalizedSentence: String {
        prefix(1).capitalized + dropFirst()
    }
}
