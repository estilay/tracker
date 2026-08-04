import UIKit

// MARK: - TrackerViewController
final class TrackerViewController: UIViewController {
    // MARK: - Properties
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    
    // MARK: - UI Elements
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        collectionView.register(TrackerViewCell.self, forCellWithReuseIdentifier: "Cell")
        return collectionView
    }()
    
    private lazy var stubImageView: UIImageView = {
        let stubImage = UIImage(resource: .dizzy)
        let stubImageView = UIImageView(image: stubImage)
        
        stubImageView.translatesAutoresizingMaskIntoConstraints = false
        
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
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        
        return datePicker
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - Actions
    @objc
    private func didTapAddButton() {
        // TODO:
    }
    
    @objc
    private func datePickerValueChanged(_ sender: UIDatePicker) {
        // TODO:
    }
}


// MARK: - UI Methods
extension TrackerViewController {
    private func setupUI() {
        view.backgroundColor = .yWhiteDay
        setupNavigationBar()
        setupCollectionView()
//        setupStubContainerViewConstraints()
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Поиск"
        navigationItem.searchController = searchController
    }
    
    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])

        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func setupStubContainerViewConstraints() {
        NSLayoutConstraint.activate([
            stubContainerView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stubContainerView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
}

// MARK: - UICollectionViewDataSource
extension TrackerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? TrackerViewCell else { return UICollectionViewCell() }
        
        cell.titleLabel.text = "Stub text"
        return cell
    }
}


// MARK: - UICollectionViewDelegateFlowLayout
extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let insets: CGFloat = 32
        let spacing: CGFloat = 9
        
        let avaibleWidth = collectionView.bounds.width - insets - spacing
        
        let cellWidth = avaibleWidth / 2
        let cellHeight = cellWidth * (148 / 167)
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
}


