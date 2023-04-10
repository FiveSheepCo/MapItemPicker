import Foundation

public struct OpeningHours: Codable, Equatable, Hashable {
    
    public let sortedDisplayableWeekPortions: [DisplayableWeekPortion]
    
    public func encode(to encoder: Encoder) throws {
        fatalError() // TODO: This
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        
        self.init(string: string)
    }
    
    init(sortedDisplayableWeekPortions: [DisplayableWeekPortion]) {
        self.sortedDisplayableWeekPortions = sortedDisplayableWeekPortions
    }
    
    init(string: String) {
        if string == "24/7" {
            self.sortedDisplayableWeekPortions = [.init(weekdays: Weekday.allWeekdays, ranges: [.init(from: .midnight, to: .midnight)])]
            return
        }
        
        var portions: [Weekday: [DayTimeRange]] = [:]
        
        var weekdays: [Weekday] = []
        var iterationAlreadyAddedHours: Bool = false
        for semicolonPart in string.lowercased().components(separatedBy: [";", ", "]) {
            
            var remaining = semicolonPart.trimmingCharacters(in: .whitespaces)
            
            if remaining.first?.isLetter == true {
                if iterationAlreadyAddedHours {
                    weekdays = []
                    iterationAlreadyAddedHours = false
                }
                
                let spaceSeparatedComponents = remaining.components(separatedBy: .whitespaces)
                guard let firstComponent = spaceSeparatedComponents.first, !firstComponent.isEmpty else { continue }
                
                let weekdayParts = spaceSeparatedComponents[0].components(separatedBy: ",")
                for weekdayPart in weekdayParts {
                    let fromToParts = weekdayPart.components(separatedBy: "-")
                    
                    if fromToParts.count > 1 {
                        guard let firstWeekday = Weekday(rawValue: fromToParts[0]),
                              let lastWeekday = Weekday(rawValue: fromToParts[1])
                        else { assertionFailure() ; continue }
                        
                        var currentWeekday = firstWeekday
                        while currentWeekday != lastWeekday {
                            weekdays.append(currentWeekday)
                            guard let next = currentWeekday.next else { break }
                            currentWeekday = next
                        }
                        weekdays.append(currentWeekday)
                    } else {
                        guard let weekday = Weekday(rawValue: fromToParts[0]) else { assertionFailure() ; continue }
                        weekdays.append(weekday)
                    }
                }
                
                guard spaceSeparatedComponents.count == 2 else { continue }
                remaining = spaceSeparatedComponents[1]
                iterationAlreadyAddedHours = true
            }
            
            let hourString = remaining
            let hourRanges: [DayTimeRange]
            if hourString == "off" {
                hourRanges = []
            } else {
                hourRanges = hourString
                    .components(separatedBy: ",")
                    .compactMap { rangePart in
                        DayTimeRange(string: rangePart)
                    }
            }
            
            for weekday in weekdays {
                guard !hourRanges.isEmpty else {
                    portions[weekday] = []
                    continue
                }
                
                for hourRange in hourRanges {
                    portions[weekday, default: []].append(hourRange)
                }
            }
        }
        
        for (weekday, hourRanges) in portions {
            for (index, hourRange) in hourRanges.enumerated() {
                if hourRange.from == .midnight,
                   let last = weekday.last,
                   let extendableIndex = portions[last]?.firstIndex(where: { $0.to == .midnight && $0.from > hourRange.to }) {
                    
                    let original = portions[last]![extendableIndex]
                    portions[last]![extendableIndex] = .init(from: original.from, to: hourRange.to)
                    portions[weekday]!.remove(at: index)
                    break
                }
            }
        }
        
        let portionsArray = Array(portions)
        let dict = Dictionary(
            grouping: portionsArray,
            by: { SortHashable(isHoliday: $0.key == .holiday, isSchoolHoliday: $0.key == .schoolHoliday, ranges: $0.value) }
        )
        self.sortedDisplayableWeekPortions = dict
            .values
            .map { element in
                DisplayableWeekPortion(weekdays: element.map({ $0.key }).weekdaySorted, ranges: element[0].value)
            }
            .filter({ !$0.ranges.isEmpty || $0.weekdays.contains(.holiday) || $0.weekdays.contains(.schoolHoliday) })
            .sorted(by: \.weekdays.last!.sortIndex)
    }
    
    private struct SortHashable: Hashable {
        let isHoliday: Bool
        let isSchoolHoliday: Bool
        let ranges: [OpeningHours.DayTimeRange]
    }
}
