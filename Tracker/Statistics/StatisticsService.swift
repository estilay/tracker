import Foundation

// MARK: - Statistics
struct Statistics {
    let completedTrackers: Int
}

// MARK: - StatisticsService
final class StatisticsService {
    
    static let shared = StatisticsService()
    
    private enum Keys {
        static let completedTrackers = "statistics.completedTrackers"
    }
    
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - Public
    var statistics: Statistics {
        Statistics(
            completedTrackers: userDefaults.integer(forKey: Keys.completedTrackers)
        )
    }
    
    func incrementCompletedTrackers() {
        let current = userDefaults.integer(forKey: Keys.completedTrackers)
        userDefaults.set(current + 1, forKey: Keys.completedTrackers)
    }
    
    func decrementCompletedTrackers() {
        let current = userDefaults.integer(forKey: Keys.completedTrackers)
        userDefaults.set(max(0, current - 1), forKey: Keys.completedTrackers)
    }
}
