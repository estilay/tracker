import UIKit

final class NewHabitViewController: UIViewController {
    // MARK: - Properties
    private var habitName = String()
    private let selectedCategory: String = "Важное"
    private var selectedSchedule = String()
    private var selectedDays: [Schedule] = []
    private var selectedIcon: String?
    private var selectedColor: UIColor?
    private var isCharacterLimitExceeded = false
    
    var onTrackerCreated: ((Tracker, String) -> Void)?
    
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
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 75
        tableView.separatorStyle = .singleLine
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать", for: .normal)
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
        button.setTitle("Отменить", for: .normal)
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
    }
    
    // MARK: - Actions
    @objc private func didTapCreateButton() {
        guard !habitName.isEmpty else { return }
        
        let tracker = Tracker(
            name: habitName,
            icon: selectedIcon ?? "😄",
            color: selectedColor ?? .colorSelection5,
            schedule: selectedDays
        )
        
        onTrackerCreated?(tracker, selectedCategory)
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
extension NewHabitViewController {
    private func setupUI() {
        view.backgroundColor = .yWhiteDay
        
        view.addSubview(tableView)
        view.addSubview(cancelButton)
        view.addSubview(createButton)
        
        setupNavigationBar()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        title = "Новая привычка"
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
extension NewHabitViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 2
        case 2:
            return 1
        case 3:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
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
            
        case 1:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: HabitDetailCell.identifier,
                for: indexPath
            ) as? HabitDetailCell else {
                return UITableViewCell()
            }
            
            switch indexPath.row {
            case 0:
                cell.configure(title: "Категория", value: selectedCategory)
                cell.selectionStyle = .none
            case 1:
                cell.configure(title: "Расписание", value: selectedSchedule)
            default:
                break
            }
            
            return cell
            
        case 2:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: EmojiCollectionCell.identifier,
                for: indexPath
            ) as? EmojiCollectionCell else {
                return UITableViewCell()
            }
            
            cell.onEmojiSelected = { [weak self] emoji in
                self?.selectedIcon = emoji
                self?.updateCreateButtonState()
            }
            cell.selectionStyle = .none
            
            return cell
            
        case 3:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ColorCollectionCell.identifier,
                for: indexPath
            ) as? ColorCollectionCell else {
                return UITableViewCell()
            }
            
            cell.onColorSelected = { [weak self] color in
                self?.selectedColor = color
                self?.updateCreateButtonState()
            }
            cell.selectionStyle = .none
            
            return cell
            
        default:
            return UITableViewCell()
        }
    }
}

// MARK: - UITableViewDelegate
extension NewHabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 75
        case 1:
            return 75
        case 2:
            return 52 * 3 + 48 + 19
        case 3:
            return 52 * 3 + 48 + 19
        default:
            return 75
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                break
            case 1:
                showScheduleSelection()
            default:
                break
            }
        }
    }
    
    // MARK: - Header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        case 1:
            return 24
        case 2:
            return 32
        case 3:
            return 16
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }
    
    // MARK: - Footer
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 && isCharacterLimitExceeded {
            return 38
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 && isCharacterLimitExceeded {
            let footerView = UIView()
            footerView.backgroundColor = .clear
            
            let errorLabel = UILabel()
            errorLabel.text = "Ограничение 38 символов"
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
        
        return nil
    }
    
    // MARK: - Navigation
    private func showScheduleSelection() {
        let scheduleVC = ScheduleViewController()
        scheduleVC.preselectedDays = selectedDays
        
        scheduleVC.onSave = { [weak self] days in
            self?.selectedDays = days
            
            if days.count == 7 {
                self?.selectedSchedule = "Каждый день"
            } else if days.isEmpty {
                self?.selectedSchedule = ""
            } else {
                self?.selectedSchedule = days.map { $0.short }.joined(separator: ", ")
            }
            
            self?.updateScheduleCell()
            self?.updateCreateButtonState()
        }
        
        let navController = UINavigationController(rootViewController: scheduleVC)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true)
    }
    
    private func updateScheduleCell() {
        let indexPath = IndexPath(row: 1, section: 1)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - HabitNameCellDelegate
extension NewHabitViewController: HabitNameCellDelegate {
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
