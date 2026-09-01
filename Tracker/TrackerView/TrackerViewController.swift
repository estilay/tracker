import UIKit

// MARK: - TrackerViewController
final class TrackerViewController: UIViewController {
    // MARK: - Properties
    private let trackerStore = TrackerStore()
    private let recordStore = TrackerRecordStore()
    
    private var selectedDate: Date = Date()
    private var filteredCategories: [TrackerCategory] = []
    
    // MARK: - UI Elements
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.identifier)
        collectionView.register(TrackerViewCell.self, forCellWithReuseIdentifier: TrackerViewCell.identifier)
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
        return datePicker
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStoreDelegates()
        updateTrackersForSelectedDate()
    }
    
    // MARK: - Setup
    private func setupStoreDelegates() {
        trackerStore.delegate = self
        recordStore.delegate = self
    }
    
    // MARK: - Actions
    @objc
    private func didTapAddButton() {
        let newHabitVC = NewHabitViewController()
        let navController = UINavigationController(rootViewController: newHabitVC)
        newHabitVC.modalPresentationStyle = .formSheet
        
        newHabitVC.onTrackerCreated = { [weak self] tracker, categoryTitle in
            self?.addTracker(tracker, to: categoryTitle)
        }
        
        present(navController, animated: true)
    }
    
    @objc
    private func datePickerValueChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
        applyFilters()
    }
    
    // MARK: - Private Methods
    private func addTracker(_ tracker: Tracker, to categoryTitle: String) {
        do {
            try trackerStore.createTracker(
                id: tracker.id,
                name: tracker.name,
                icon: tracker.icon,
                color: tracker.color,
                schedule: tracker.schedule,
                categoryTitle: categoryTitle
            )
            applyFilters()
        } catch {
            print("Creating tracker failed: \(error)")
        }
    }
    
    private func applyFilters() {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: selectedDate)
        let selectedDay = Schedule.from(weekday: weekday)
        
        let allTrackers = trackerStore.allTrackers
        
        let filteredTrackers = allTrackers.filter { tracker in
            tracker.schedule.contains(selectedDay)
        }
        
        let grouped = Dictionary(grouping: filteredTrackers) { tracker -> String in
            // TODO: - Get Category from Store
            return "Важное"
        }
        
        filteredCategories = grouped.map { categoryTitle, trackers in
            TrackerCategory(title: categoryTitle, trackers: trackers)
        }.sorted { $0.title < $1.title }
        
        collectionView.reloadData()
        updateStubVisibility()
    }
    
    private func updateTrackersForSelectedDate() {
        selectedDate = Date()
        datePicker.date = selectedDate
        applyFilters()
    }
    
    private func updateStubVisibility() {
        let hasTrackers = filteredCategories.contains { !$0.trackers.isEmpty }
        
        stubContainerView.isHidden = hasTrackers
        collectionView.isHidden = !hasTrackers
        
        if !hasTrackers {
            stubLabel.text = "Что будем отслеживать?"
        }
    }
    
    private func getCompletedCount(for trackerId: UUID) -> Int {
        return (try? recordStore.countRecords(for: trackerId)) ?? 0
    }
    
    private func isCompletedToday(for trackerId: UUID) -> Bool {
        return (try? recordStore.isRecordExists(trackerId: trackerId, date: selectedDate)) ?? false
    }
}

// MARK: - UI Methods
extension TrackerViewController {
    private func setupUI() {
        view.backgroundColor = .yWhiteDay
        setupNavigationBar()
        setupCollectionView()
        setupStubContainerViewConstraints()
    }
    
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
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section < filteredCategories.count else { return 0 }
        return filteredCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerViewCell.identifier, for: indexPath) as? TrackerViewCell else { return UICollectionViewCell() }
        
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.row]
        let completedCount = getCompletedCount(for: tracker.id)
        let isCompletedToday = isCompletedToday(for: tracker.id)
        
        cell.configure(with: tracker, completedDays: completedCount, isCompletedToday: isCompletedToday, selectedDate: selectedDate)
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
        
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderView.identifier, for: indexPath) as? HeaderView else { return UICollectionReusableView() }
        
        let category = filteredCategories[indexPath.section]
        header.titleLabel.text = category.title
        header.titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        return header
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 19)
    }
}

// MARK: - TrackerCellDelegate
extension TrackerViewController: TrackerCellDelegate {
    func trackerCellDidTapAction(_ cell: TrackerViewCell, trackerId: UUID) {
        do {
            let isCompletedToday = try recordStore.isRecordExists(trackerId: trackerId, date: selectedDate)
            
            if isCompletedToday {
                try recordStore.removeRecord(trackerId: trackerId, date: selectedDate)
            } else {
                try recordStore.addRecord(trackerId: trackerId, date: selectedDate)
            }
            
            applyFilters()
        } catch {
            print("[TrackerViewController.TrackerCellDelegate]: \(error)")
        }
    }
}

// MARK: - TrackerStoreDelegate
extension TrackerViewController: TrackerStoreDelegate {
    func storeDidChange(_ store: TrackerStore) {
        applyFilters()
    }
}

// MARK: - TrackerRecordStoreDelegate
extension TrackerViewController: TrackerRecordStoreDelegate {
    func storeDidChange(_ store: TrackerRecordStore) {
        applyFilters()
    }
}
