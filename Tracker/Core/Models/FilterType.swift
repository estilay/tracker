import Foundation

enum FilterType: Int, CaseIterable {
    case all
    case today
    case completed
    case notCompleted
    
    var title: String {
        switch self {
        case .all:           String(localized: "Все трекеры")
        case .today:         String(localized: "Трекеры на сегодня")
        case .completed:     String(localized: "Завершенные")
        case .notCompleted:  String(localized: "Не завершенные")
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
        case .all, .today:   nil
        case .completed:     .completed
        case .notCompleted:  .notCompleted
        }
    }
    
    static func from(_ filter: TrackerFilter?) -> FilterType {
        switch filter {
        case .none:          .all
        case .completed:     .completed
        case .notCompleted:  .notCompleted
        }
    }
}
