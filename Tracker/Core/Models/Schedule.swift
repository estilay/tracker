import Foundation

enum Schedule: String, CaseIterable {
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"
    
    var full: String {
        switch self {
        case .monday:    return String(localized: "Понедельник")
        case .tuesday:   return String(localized: "Вторник")
        case .wednesday: return String(localized: "Среда")
        case .thursday:  return String(localized: "Четверг")
        case .friday:    return String(localized: "Пятница")
        case .saturday:  return String(localized: "Суббота")
        case .sunday:    return String(localized: "Воскресенье")
        }
    }
    
    var short: String {
        switch self {
        case .monday:    return String(localized: "Пн")
        case .tuesday:   return String(localized: "Вт")
        case .wednesday: return String(localized: "Ср")
        case .thursday:  return String(localized: "Чт")
        case .friday:    return String(localized: "Пт")
        case .saturday:  return String(localized: "Сб")
        case .sunday:    return String(localized: "Вс")
        }
    }
    
    static func from(weekday: Int) -> Schedule {
        switch weekday {
        case 1: .sunday
        case 2: .monday
        case 3: .tuesday
        case 4: .wednesday
        case 5: .thursday
        case 6: .friday
        case 7: .saturday
        default: .monday
        }
    }
}
