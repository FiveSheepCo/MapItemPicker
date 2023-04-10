import Foundation

public struct MIPAction: Identifiable {
    
    public let id = UUID()
    
    public let imageName: String
    public let handler: () -> Void
    
    public init(imageName: String, handler: @escaping () -> Void) {
        self.imageName = imageName
        self.handler = handler
    }
}
