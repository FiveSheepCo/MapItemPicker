import Foundation

extension OpeningHours {
    
    public struct DayTime: Equatable, Comparable, Hashable {
        
        public static func < (lhs: OpeningHours.DayTime, rhs: OpeningHours.DayTime) -> Bool {
            lhs.dayMinutes < rhs.dayMinutes
        }
        
        static let midnight = DayTime(hour: 0, minute: 0)
        
        public let hour: Int
        public let minute: Int
        
        private var dayMinutes: Int {
            hour * 60 + minute
        }
        
        init?(string: String) {
            let parts = string.components(separatedBy: ":")
            guard
                parts.count == 2,
                let hour = Int(parts[0]),
                let minute = Int(parts[1])
            else { return nil }
            
            self.hour = hour % 24
            self.minute = minute
        }
        
        init(hour: Int, minute: Int) {
            self.hour = hour
            self.minute = minute
        }
        
        var displayString: String {
            let calendar = Calendar.current
            
            guard let date = calendar.date(from: DateComponents(hour: hour, minute: minute)) else {
                return "?"
            }
            
            return DateFormatter(timeStyle: .short).string(from: date)
        }
    }
}
