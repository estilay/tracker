import UIKit

// MARK: - TrackerViewController
final class TrackerViewController: UIViewController {
    // MARK: - Properties
    private let trackerStore = TrackerStore()
    private let recordStore = TrackerRecordStore()
    private let categoryStore = TrackerCategoryStore()
    
    private var selectedDate: Date = Date()
    private var filteredCategories: [TrackerCategory] = []
    private var searchText: String = ""
    
    private var currentFilter: TrackerFilter? {
        get { FilterStorage.shared.currentFilter }
        set { FilterStorage.shared.currentFilter = newValue }
    }
    
    private let analyticsService = AnalyticsService()
    
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
        stubLabel.text = String(localized: "Что будем отслеживать?")
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
        return stubContainerView
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        datePicker.preferredDatePickerStyle = .compact
        return datePicker
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 16
        button.backgroundColor = .yBlue
        button.setTitle(String(localized: "Фильтры"), for: .normal)
        button.setTitleColor(.yWhiteDay, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.addTarget(self, action: #selector(didTapFilterButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = String(localized: "Поиск")
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        return searchController
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStoreDelegates()
        updateTrackersForSelectedDate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsService.reportOpen(screen: .main)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analyticsService.reportClose(screen: .main)
    }
    
    // MARK: - Setup
    private func setupStoreDelegates() {
        trackerStore.delegate = self
        recordStore.delegate = self
        categoryStore.delegate = self
    }
    
    // MARK: - Actions
    @objc
    private func didTapAddButton() {
        analyticsService.reportClick(screen: .main, item: .addTrack)
        
        let newHabitVC = HabitViewController()
        let navController = UINavigationController(rootViewController: newHabitVC)
        newHabitVC.modalPresentationStyle = .formSheet
        
        newHabitVC.onTrackerCreated = { [weak self] tracker, categoryTitle in
            self?.addTracker(tracker, to: categoryTitle)
        }
        
        present(navController, animated: true)
    }
    
    @objc
    private func didTapFilterButton() {
        analyticsService.reportClick(screen: .main, item: .filter)
        
        let filterVC = FilterViewController(selectedFilter: FilterType.from(currentFilter))
        filterVC.delegate = self
        let navController = UINavigationController(rootViewController: filterVC)
        navController.modalPresentationStyle = .formSheet
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
    
    private func updateTracker(_ tracker: Tracker, categoryTitle: String) {
        do {
            try trackerStore.updateTracker(
                id: tracker.id,
                name: tracker.name,
                icon: tracker.icon,
                color: tracker.color,
                schedule: tracker.schedule,
                categoryTitle: categoryTitle
            )
        } catch {
            print("[TrackerViewController]: Failed to update tracker: \(error)")
        }
    }
    
    private func deleteTracker(with trackerId: UUID) {
        do {
            try recordStore.deleteRecord(for: trackerId)
            try trackerStore.deleteTracker(by: trackerId)
        } catch {
            print("[TrackerViewController]: Failed to delete tracker: \(error)")
        }
    }
    
    private func applyFilters() {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: selectedDate)
        let selectedDay = Schedule.from(weekday: weekday)
        
        let allTrackers = trackerStore.allTrackers
        
        var filteredTrackers = allTrackers.filter { tracker in
            tracker.schedule.contains(selectedDay)
        }
        
        if !searchText.isEmpty {
            filteredTrackers = filteredTrackers.filter { tracker in
                tracker.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let currentFilter {
            filteredTrackers = filteredTrackers.filter { tracker in
                let isCompleted = (try? recordStore.isRecordExists(trackerId: tracker.id, date: selectedDate)) ?? false
                switch currentFilter {
                case .completed:    return isCompleted
                case .notCompleted: return !isCompleted
                }
            }
        }
        
        let allCategories = categoryStore.allCategories
        
        var categoryDict: [String: [Tracker]] = [:]
        
        for category in allCategories {
            categoryDict[category.title] = []
        }
        
        for tracker in filteredTrackers {
            if let category = trackerStore.getCategory(for: tracker.id) {
                if categoryDict[category.title] != nil {
                    categoryDict[category.title]?.append(tracker)
                } else {
                    categoryDict[category.title] = [tracker]
                }
            }
        }
        
        filteredCategories = categoryDict
            .filter { !$0.value.isEmpty }
            .map { TrackerCategory(title: $0.key, trackers: $0.value) }
            .sorted { $0.title < $1.title }
        
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
        
        guard !hasTrackers else { return }
        
        if !searchText.isEmpty {
            stubImageView.image = UIImage(resource: .notFound)
            stubLabel.text = String(localized: "Ничего не найдено")
            return
        }
        
        switch currentFilter {
        case .none:
            stubImageView.image = UIImage(resource: .dizzy)
            stubLabel.text = String(localized: "Что будем отслеживать?")
        case .completed:
            stubImageView.image = UIImage(resource: .notFound)
            stubLabel.text = String(localized: "Ничего не найдено")
        case .notCompleted:
            stubImageView.image = UIImage(resource: .notFound)
            stubLabel.text = String(localized: "Ничего не найдено")
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
        collectionView.backgroundColor = .clear
        setupNavigationBar()
        setupCollectionView()
        setupStubContainerViewConstraints()
        setupFilterButton()
    }
    
    private func setupFilterButton() {
        view.addSubview(filterButton)
        NSLayoutConstraint.activate([
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)
        ])
    }
    
    private func setupNavigationBar() {
        title = String(localized: "Трекеры")
        
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
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stubContainerView)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
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
        analyticsService.reportClick(screen: .main, item: .track)
        
        do {
            let isCompletedToday = try recordStore.isRecordExists(trackerId: trackerId, date: selectedDate)
            
            if isCompletedToday {
                try recordStore.deleteRecord(for: trackerId)
            } else {
                try recordStore.addRecord(trackerId: trackerId, date: selectedDate)
            }
            
            applyFilters()
        } catch {
            print("[TrackerViewController.TrackerCellDelegate]: \(error)")
        }
    }
    
    func trackerCellDidRequestEdit(_ cell: TrackerViewCell, trackerId: UUID) {
        analyticsService.reportClick(screen: .main, item: .edit)
        
        guard let tracker = trackerStore.allTrackers.first(where: { $0.id == trackerId }) else { return }
        let category = trackerStore.getCategory(for: trackerId)?.title ?? ""
        
        let editVC = HabitViewController(mode: .edit(tracker, category: category))
        editVC.onTrackerUpdated = { [weak self] updatedTracker, categoryTitle in
            self?.updateTracker(updatedTracker, categoryTitle: categoryTitle)
        }
        
        let navController = UINavigationController(rootViewController: editVC)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true)
    }
    
    func trackerCellDidRequestDelete(_ cell: TrackerViewCell, trackerId: UUID) {
        let alert = UIAlertController(
            title: String(localized: "Уверены что хотите удалить трекер?"),
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(title: String(localized: "Удалить"), style: .destructive) { [weak self] _ in
            self?.deleteTracker(with: trackerId)
        }
        
        let cancelAction = UIAlertAction(title: String(localized: "Отменить"), style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
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

// MARK: - TrackerCategoryStoreDelegate
extension TrackerViewController: TrackerCategoryStoreDelegate {
    func storeDidChange(_ store: TrackerCategoryStore) {
        applyFilters()
    }
}

// MARK: - FilterSelectionDelegate
extension TrackerViewController: FilterSelectionDelegate {
    func didSelectFilter(_ filter: FilterType) {
        if filter.resetsDateToToday {
            selectedDate = Date()
            datePicker.date = selectedDate
        }
        
        currentFilter = filter.trackerFilter
        
        applyFilters()
    }
}

// MARK: - UISearchResultsUpdating
extension TrackerViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchText = searchController.searchBar.text ?? ""
        applyFilters()
    }
}
