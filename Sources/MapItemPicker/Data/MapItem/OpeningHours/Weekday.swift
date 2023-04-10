import Foundation

extension OpeningHours {
    public enum Weekday: String, Codable {
        static var allWeekdays: [Weekday] {
            [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        }
        
        case monday = "mo", tuesday = "tu", wednesday = "we", thursday = "th", friday = "fr", saturday = "sa", sunday = "su"
        case holiday = "ph", schoolHoliday = "sh"
        
        var next: Weekday? {
            switch self {
            case .monday: return .tuesday
            case .tuesday: return .wednesday
            case .wednesday: return .thursday
            case .thursday: return .friday
            case .friday: return .saturday
            case .saturday: return .sunday
            case .sunday: return .monday
            default: return nil
            }
        }
        
        var last: Weekday? {
            switch self {
            case .monday: return .sunday
            case .tuesday: return .monday
            case .wednesday: return .tuesday
            case .thursday: return .wednesday
            case .friday: return .thursday
            case .saturday: return .friday
            case .sunday: return .saturday
            default: return nil
            }
        }
        
        var sortIndex: Int {
            switch self {
            case .monday: return 0
            case .tuesday: return 1
            case .wednesday: return 2
            case .thursday: return 3
            case .friday: return 4
            case .saturday: return 5
            case .sunday: return 6
            case .holiday: return 7
            case .schoolHoliday: return 8
            }
        }
        
        var calendarIndex: Int? {
            switch self {
            case .sunday: return 0
            case .monday: return 1
            case .tuesday: return 2
            case .wednesday: return 3
            case .thursday: return 4
            case .friday: return 5
            case .saturday: return 6
            default: return nil
            }
        }
        
        var localizedName: String {
            guard let calendarIndex else {
                switch self {
                case .holiday:
                    return "openingHours.holiday".moduleLocalized
                case .schoolHoliday:
                    return "openingHours.schoolHoliday".moduleLocalized
                default: return "-"
                }
            }
            
            let prefLanguage = Locale.preferredLanguages[0]
            var calendar = Calendar(identifier: .gregorian)
            calendar.locale = NSLocale(localeIdentifier: prefLanguage) as Locale
            return calendar.standaloneWeekdaySymbols[calendarIndex]
        }
        
        var shortLocalizedName: String {
            guard let calendarIndex else {
                return localizedName
            }
            
            let prefLanguage = Locale.preferredLanguages[0]
            var calendar = Calendar(identifier: .gregorian)
            calendar.locale = NSLocale(localeIdentifier: prefLanguage) as Locale
            return calendar.shortStandaloneWeekdaySymbols[calendarIndex]
        }
    }
}

extension Array where Element == OpeningHours.Weekday {
    var weekdaySorted: Self {
        var new = sorted(by: \.sortIndex)
        
        guard new.count < 7 else {
            return new
        }
        
        while let last = new.last, last == new.first!.last {
            new.insert(new.removeLast(), at: 0)
        }
        
        return new
    }
}
