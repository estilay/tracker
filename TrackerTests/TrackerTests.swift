import XCTest
import SnapshotTesting

@testable import Tracker

final class TrackerTests: XCTestCase {
    func testTabBarContollerLight() {
        let vc = TabBarController()
        
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    }
    
    func testTabBarContollerDark() {
        let vc = TabBarController()
        
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
