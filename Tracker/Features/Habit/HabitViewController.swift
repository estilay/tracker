import UIKit

enum HabitMode {
    case create
    case edit(Tracker, category: String)
}

final class HabitViewController: UIViewController {
    // MARK: - Properties
    private let mode: HabitMode
    
    private var habitName = String()
    private var selectedCategory: String?
    private var selectedSchedule = String()
    private var selectedDays: [Schedule] = []
    private var selectedIcon: String?
    private var selectedColor: UIColor?
    private var isCharacterLimitExceeded = false
    private var completedDaysCount: Int = 0
    
    var onTrackerCreated: ((Tracker, String) -> Void)?
    var onTrackerUpdated: ((Tracker, String) -> Void)?
    
    // MARK: - Init
    init(mode: HabitMode = .create) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Section
    private enum Section {
        case daysCount
        case name
        case details
        case emoji
        case color
    }
    
    // MARK: - Constants
    private enum Constants {
        static let defaultRowHeight: CGFloat = 75
        static let collectionItemHeight: CGFloat = 52
        static let collectionTopAndBottomInset: CGFloat = 24
        static let collectionHorizontalInset: CGFloat = 19
        
        static var collectionSectionHeight: CGFloat {
            return collectionItemHeight * 3 + collectionTopAndBottomInset * 2 + collectionHorizontalInset
        }
    }
    
    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.register(HabitDetailCell.self, forCellReuseIdentifier: HabitDetailCell.identifier)
        tableView.register(HabitNameCell.self, forCellReuseIdentifier: HabitNameCell.identifier)
        tableView.register(EmojiCollectionCell.self, forCellReuseIdentifier: EmojiCollectionCell.identifier)
        tableView.register(ColorCollectionCell.self, forCellReuseIdentifier: ColorCollectionCell.identifier)
        tableView.register(DaysCountCell.self, forCellReuseIdentifier: DaysCountCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 75
        tableView.separatorStyle = .singleLine
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.setTitle(String(localized: "Создать"), for: .normal)
        button.setTitleColor(.yWhiteDay, for: .normal)
        button.backgroundColor = .yGray
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
        button.isEnabled = false
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle(String(localized: "Отменить"), for: .normal)
        button.setTitleColor(.yRed, for: .normal)
        button.tintColor = .yRed
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.yRed.cgColor
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupHideKeyboardOnTap()
        applyMode()
    }
    
    // MARK: - Mode
    private func applyMode() {
        switch mode {
        case .create:
            title = String(localized: "Новая привычка")
            createButton.setTitle(String(localized: "Создать"), for: .normal)
            
        case .edit(let tracker, let category):
            title = String(localized: "Редактирование привычки")
            createButton.setTitle(String(localized: "Сохранить"), for: .normal)
            
            habitName = tracker.name
            selectedIcon = tracker.icon
            selectedColor = tracker.color
            selectedDays = tracker.schedule
            selectedCategory = category.isEmpty ? nil : category
            selectedSchedule = scheduleText(from: tracker.schedule)
            completedDaysCount = (try? TrackerRecordStore().countRecords(for: tracker.id)) ?? 0
            
            updateCreateButtonState()
            tableView.reloadData()
        }
    }
    
    private func scheduleText(from days: [Schedule]) -> String {
        if days.count == 7 {
            return String(localized: "Каждый день")
        } else if days.isEmpty {
            return ""
        } else {
            return days.map { $0.short }.joined(separator: ", ")
        }
    }
    
    private func currentTrackerId() -> UUID {
        if case .edit(let tracker, _) = mode {
            return tracker.id
        }
        return UUID()
    }
    
    private func adjustedSection(for section: Int) -> Section {
        switch mode {
        case .create:
            switch section {
            case 0: return .name
            case 1: return .details
            case 2: return .emoji
            default: return .color
            }
        case .edit:
            switch section {
            case 0: return .daysCount
            case 1: return .name
            case 2: return .details
            case 3: return .emoji
            default: return .color
            }
        }
    }
    
    // MARK: - Actions
    @objc private func didTapCreateButton() {
        guard !habitName.isEmpty else { return }
        
        let tracker = Tracker(
            id: currentTrackerId(),
            name: habitName,
            icon: selectedIcon ?? "😄",
            color: selectedColor ?? .colorSelection5,
            schedule: selectedDays
        )
        
        switch mode {
        case .create:
            onTrackerCreated?(tracker, selectedCategory ?? "")
        case .edit:
            onTrackerUpdated?(tracker, selectedCategory ?? "")
        }
        
        dismiss(animated: true)
    }
    
    @objc private func didTapCancelButton() {
        dismiss(animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupHideKeyboardOnTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func updateCreateButtonState() {
        let isEnabled = !habitName.isEmpty && !selectedSchedule.isEmpty
        createButton.isEnabled = isEnabled
        createButton.backgroundColor = isEnabled ? .yBlackDay : .yGray
    }
}

// MARK: - UI Methods
extension HabitViewController {
    private func setupUI() {
        view.backgroundColor = .yWhiteDay
        
        view.addSubview(tableView)
        view.addSubview(cancelButton)
        view.addSubview(createButton)
        
        setupNavigationBar()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor(resource: .yBlackDay),
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -16),
            
            cancelButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.widthAnchor.constraint(equalTo: createButton.widthAnchor),
            
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            createButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8)
        ])
    }
}

// MARK: - UITableViewDataSource
extension HabitViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        switch mode {
        case .create: return 4
        case .edit:   return 5
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch adjustedSection(for: section) {
        case .daysCount: return 1
        case .name:      return 1
        case .details:   return 2
        case .emoji:     return 1
        case .color:     return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch adjustedSection(for: indexPath.section) {
        case .daysCount:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: DaysCountCell.identifier,
                for: indexPath
            ) as? DaysCountCell else {
                return UITableViewCell()
            }
            cell.configure(with: completedDaysCount)
            return cell
            
        case .name:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: HabitNameCell.identifier,
                for: indexPath
            ) as? HabitNameCell else {
                return UITableViewCell()
            }
            cell.textField.text = habitName
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
            
        case .details:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: HabitDetailCell.identifier,
                for: indexPath
            ) as? HabitDetailCell else {
                return UITableViewCell()
            }
            switch indexPath.row {
            case 0:
                cell.configure(title: String(localized: "Категория"), value: selectedCategory ?? "")
                cell.selectionStyle = .none
            case 1:
                cell.configure(title: String(localized: "Расписание"), value: selectedSchedule)
            default:
                break
            }
            return cell
            
        case .emoji:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: EmojiCollectionCell.identifier,
                for: indexPath
            ) as? EmojiCollectionCell else {
                return UITableViewCell()
            }
            cell.setSelectedEmoji(selectedIcon)
            cell.onEmojiSelected = { [weak self] emoji in
                self?.selectedIcon = emoji
                self?.updateCreateButtonState()
            }
            cell.selectionStyle = .none
            return cell
            
        case .color:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ColorCollectionCell.identifier,
                for: indexPath
            ) as? ColorCollectionCell else {
                return UITableViewCell()
            }
            cell.setSelectedColor(selectedColor)
            cell.onColorSelected = { [weak self] color in
                self?.selectedColor = color
                self?.updateCreateButtonState()
            }
            cell.selectionStyle = .none
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension HabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch adjustedSection(for: indexPath.section) {
        case .daysCount:
            return UITableView.automaticDimension
        case .name, .details:
            return Constants.defaultRowHeight
        case .emoji, .color:
            return Constants.collectionSectionHeight
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard adjustedSection(for: indexPath.section) == .details else { return }
        
        switch indexPath.row {
        case 0:
            showCategorySelection()
        case 1:
            showScheduleSelection()
        default:
            break
        }
    }
    
    // MARK: - Header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch adjustedSection(for: section) {
        case .daysCount: return 0
        case .name:      return 0
        case .details:   return 24
        case .emoji:     return 32
        case .color:     return 16
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }
    
    // MARK: - Footer
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if adjustedSection(for: section) == .name && isCharacterLimitExceeded {
            return 38
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard adjustedSection(for: section) == .name && isCharacterLimitExceeded else {
            return nil
        }
        
        let footerView = UIView()
        footerView.backgroundColor = .clear
        
        let errorLabel = UILabel()
        errorLabel.text = String(localized: "Ограничение 38 символов")
        errorLabel.textColor = .yRed
        errorLabel.font = .systemFont(ofSize: 17, weight: .regular)
        errorLabel.numberOfLines = 1
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        footerView.addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            errorLabel.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: footerView.centerYAnchor)
        ])
        
        return footerView
    }
    
    // MARK: - Navigation
    private func showCategorySelection() {
        let viewModel = CategoryViewModel(preselectedCategory: selectedCategory)
        let categoryVC = CategoryViewController(viewModel: viewModel)
        categoryVC.delegate = self
        
        let navController = UINavigationController(rootViewController: categoryVC)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true)
    }
    
    private func showScheduleSelection() {
        let scheduleVC = ScheduleViewController()
        scheduleVC.preselectedDays = selectedDays
        
        scheduleVC.onSave = { [weak self] days in
            self?.selectedDays = days
            self?.selectedSchedule = self?.scheduleText(from: days) ?? ""
            self?.updateScheduleCell()
            self?.updateCreateButtonState()
        }
        
        let navController = UINavigationController(rootViewController: scheduleVC)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true)
    }
    
    private func updateScheduleCell() {
        let section: Int
        switch mode {
        case .create: section = 1
        case .edit:   section = 2
        }
        let indexPath = IndexPath(row: 1, section: section)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - HabitNameCellDelegate
extension HabitViewController: HabitNameCellDelegate {
    func habitNameDidChange(_ name: String) {
        habitName = name
        updateCreateButtonState()
    }
    
    func didExceedCharacterLimit(_ isExceeded: Bool) {
        isCharacterLimitExceeded = isExceeded
        updateCreateButtonState()
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

// MARK: - CategorySelectionDelegate
extension HabitViewController: CategorySelectionDelegate {
    func didSelectCategory(_ category: String) {
        selectedCategory = category
        
        let section: Int
        switch mode {
        case .create: section = 1
        case .edit:   section = 2
        }
        let indexPath = IndexPath(row: 0, section: section)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
