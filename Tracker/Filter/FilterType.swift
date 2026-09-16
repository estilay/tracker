import Foundation

enum FilterType: Int, CaseIterable {
    case all
    case today
    case completed
    case notCompleted
    
    var title: String {
        switch self {
        case .all:          return "Все трекеры"
        case .today:        return "Трекеры на сегодня"
        case .completed:    return "Завершенные"
        case .notCompleted: return "Не завершенные"
        }
    }
    
    var showsCheckmark: Bool {
        switch self {
        case .all, .today:              return false
        case .completed, .notCompleted: return true
        }
    }
}
