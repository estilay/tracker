import Foundation

enum FilterType: Int, CaseIterable {
    case all
    case today
    case completed
    case notCompleted
    
    var title: String {
        switch self {
        case .all:          return String(localized: "Все трекеры")
        case .today:        return String(localized: "Трекеры на сегодня")
        case .completed:    return String(localized: "Завершенные")
        case .notCompleted: return String(localized: "Не завершенные")
        }
    }
    
    var showsCheckmark: Bool {
        self == .completed || self == .notCompleted
    }
    
    var resetsDateToToday: Bool {
        self == .today
    }
    
    var trackerFilter: TrackerFilter? {
        switch self {
        case .all, .today:  return nil
        case .completed:    return .completed
        case .notCompleted: return .notCompleted
        }
    }
    
    static func from(_ filter: TrackerFilter?) -> FilterType {
        switch filter {
        case .none:         return .all
        case .completed:    return .completed
        case .notCompleted: return .notCompleted
        }
    }
}
