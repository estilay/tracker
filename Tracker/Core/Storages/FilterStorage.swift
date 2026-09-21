import Foundation

final class FilterStorage {
    
    static let shared = FilterStorage()
    
    private let userDefaults: UserDefaults
    private let key = "tracker.currentFilter"
    
    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    var currentFilter: TrackerFilter? {
        get {
            guard let raw = userDefaults.string(forKey: key) else { return nil }
            return TrackerFilter(rawValue: raw)
        }
        set {
            if let newValue {
                userDefaults.set(newValue.rawValue, forKey: key)
            } else {
                userDefaults.removeObject(forKey: key)
            }
        }
    }
}
