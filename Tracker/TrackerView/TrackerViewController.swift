import UIKit

// MARK: - TrackerViewController
final class TrackerViewController: UIViewController {
    // MARK: - Properties
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    // MARK: - UI Elements
    private lazy var stubImageView: UIImageView = {
        let stubImage = UIImage(resource: .dizzy)
        let stubImageView = UIImageView(image: stubImage)
        
        stubImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stubImageView)
        
        return stubImageView
    }()
    
    private lazy var stubLabel: UILabel = {
        let stubLabel = UILabel()
        stubLabel.textColor = .yBlackDay
        stubLabel.text = "Что будем отслеживать?"
        stubLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        stubLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stubLabel)
        
        return stubLabel
    }()
    
    private lazy var stubContainerView: UIStackView = {
        let stubContainerView = UIStackView(arrangedSubviews: [stubImageView, stubLabel])
        stubContainerView.axis = .vertical
        stubContainerView.spacing = 8
        stubContainerView.alignment = .center
        
        stubContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stubContainerView)
        
        return stubContainerView
    }()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    @objc
    private func didTapAddButton() {
        // TODO:
    }
    
    

}


// MARK: - UI Methods
extension TrackerViewController {
    private func setupUI() {
        view.backgroundColor = .yWhiteDay
        setupNavigationBar()
        setupConstraints()
    }
    // MARK: - SetupNavigationBar
    private func setupNavigationBar() {
        title = "Трекеры"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: UIColor.yBlackDay,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        let addButton = UIBarButtonItem(
            image: UIImage(resource: .plus),
            style: .plain,
            target: self,
            action: #selector(didTapAddButton)
        )
        
        addButton.tintColor = .yBlackDay
        navigationItem.leftBarButtonItem = addButton
    }
    
    // MARK: - Setup Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stubContainerView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stubContainerView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
}
