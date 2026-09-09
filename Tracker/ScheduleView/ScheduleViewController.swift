import UIKit

// MARK: - ScheduleViewController
final class ScheduleViewController: UIViewController {
    // MARK: - Properties
    struct SwitchItem {
        let day: Schedule
        var isOn: Bool
    }
    
    private var items: [SwitchItem] = []
    var preselectedDays: [Schedule] = []
    
    var onSave: (([Schedule]) -> Void)?
    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(ScheduleViewCell.self, forCellReuseIdentifier: ScheduleViewCell.identifier)
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        
        return tableView
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.tintColor = .yWhiteDay
        button.backgroundColor = .yBlackDay
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeItems()
        applyPreselectedDays()
        setupUI()
    }
    
    @objc
    private func didTapDoneButton() {
        let selectedDays = items.filter { $0.isOn }.map { $0.day }
        onSave?(selectedDays)
        dismiss(animated: true)
    }
    
    private func initializeItems() {
        items = Schedule.allCases.map { day in
            SwitchItem(day: day, isOn: false)
        }
    }
    
    private func applyPreselectedDays() {
        for i in 0..<items.count {
            if preselectedDays.contains(items[i].day) {
                items[i].isOn = true
            }
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .yWhiteDay
        view.addSubview(tableView)
        view.addSubview(doneButton)
        
        
        setupNavigationBar()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        title = "Расписание"
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor(resource: .yBlackDay),
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

// MARK: - UITableViewDataSource
extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleViewCell.identifier, for: indexPath) as? ScheduleViewCell else {
            return UITableViewCell()
        }
        
        let item = items[indexPath.row]
        cell.configure(title: item.day.rawValue, isOn: item.isOn)
        
        cell.switchControl.tag = indexPath.row
        cell.switchControl.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        
        return cell
    }
    
    @objc func switchChanged(_ sender: UISwitch) {
        items[sender.tag].isOn = sender.isOn
    }
}

// MARK: - UITableViewDelegate
extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}
