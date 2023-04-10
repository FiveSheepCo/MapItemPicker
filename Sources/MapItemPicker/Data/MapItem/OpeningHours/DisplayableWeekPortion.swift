import Foundation

extension OpeningHours {
    
    public struct DisplayableWeekPortion: Equatable, Hashable {
        public let weekdays: [Weekday]
        public let ranges: [DayTimeRange]
    }
}
