import Foundation

enum OnboardingStorage {
    private static let key = "hasCompletedOnboarding"
    
    static var hasCompleted: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}
