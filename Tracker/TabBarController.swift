import UIKit

// MARK: - TabBarController
final class TabBarController: UITabBarController {
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.backgroundColor = .yWhiteDay
        setupViewControllers()
    }
    
    private func setupViewControllers() {
        let trackerViewController = TrackerViewController()
        let statViewController = StatViewController()
        
        let trackerNav = UINavigationController(rootViewController: trackerViewController)
        let statNav = UINavigationController(rootViewController: statViewController)
        
        trackerNav.tabBarItem = UITabBarItem(
            title: "Трекер",
            image: UIImage(resource: .recordCircleFill),
            selectedImage: nil
        )
        
        statNav.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(resource: .hareFill),
            selectedImage: nil
        )
        
        viewControllers = [trackerNav, statNav]
    }
}
