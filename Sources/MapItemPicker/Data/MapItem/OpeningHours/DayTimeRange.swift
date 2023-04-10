import Foundation

extension OpeningHours {
    
    public struct DayTimeRange: Equatable, Hashable {
        
        public let from: DayTime
        public let to: DayTime
        
        init?(string: String) {
            let fromToParts = string.components(separatedBy: "-")
            guard fromToParts.count == 2 else { return nil }
            
            guard let from = DayTime(string: fromToParts[0]), let to = DayTime(string: fromToParts[1]) else {
                return nil
            }
            
            self.from = from
            self.to = to
        }
        
        init(from: OpeningHours.DayTime, to: OpeningHours.DayTime) {
            self.from = from
            self.to = to
        }
    }
}
