import XCTest
import SnapshotTesting

@testable import Tracker

final class TrackerSnapshotTests: XCTestCase {
    func testTabBarControllerLight() {
        let vc = TabBarController()
        
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    }
    
    func testTabBarControllerDark() {
        let vc = TabBarController()
        
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
