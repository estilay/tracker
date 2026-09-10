import UIKit

// MARK: - NewCategoryViewController
final class NewCategoryViewController: UIViewController {
    // MARK: - Properties
    private var categoryName = String()
    var onCategoryCreated: ((String) -> Void)?
    
    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.register(NewCategoryViewCell.self, forCellReuseIdentifier: NewCategoryViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 75
        tableView.separatorStyle = .singleLine
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.yWhiteDay, for: .normal)
        button.backgroundColor = .yGray
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        button.isEnabled = false
        
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
    @objc private func didTapDoneButton() {
        guard !categoryName.isEmpty else { return }
        onCategoryCreated?(categoryName)
        dismiss(animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    // MARK: - Private Methods
    private func setupHideKeyboardOnTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func updateDoneButtonState() {
        let isEnabled = !categoryName.isEmpty
        doneButton.isEnabled = isEnabled
        doneButton.backgroundColor = isEnabled ? .yBlackDay : .yGray
    }
    
    // MARK: - UI Methods
    private func setupUI() {
        view.backgroundColor = .yWhiteDay
        
        view.addSubview(tableView)
        view.addSubview(doneButton)
        
        setupNavigationBar()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        title = "Новая категория"
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
            tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -16),
            
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}

// MARK: - UITableViewDataSource
extension NewCategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NewCategoryViewCell.identifier,
            for: indexPath
        ) as? NewCategoryViewCell else {
            return UITableViewCell()
        }
        
        cell.textField.text = categoryName
        cell.delegate = self
        cell.selectionStyle = .none
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension NewCategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}

// MARK: - NewCategoryViewCellDelegate
extension NewCategoryViewController: NewCategoryViewCellDelegate {
    func categoryNameDidChange(_ name: String) {
        categoryName = name
        updateDoneButtonState()
    }
}
