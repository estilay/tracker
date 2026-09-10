import UIKit

protocol CategorySelectionDelegate: AnyObject {
    func didSelectCategory(_ category: String)
}

// MARK: - CategoryViewController
final class CategoryViewController: UIViewController {
    // MARK: - Properties
    weak var delegate: CategorySelectionDelegate?
    private var selectedCategory: String?
    var preselectedCategory: String?
    
    private let categoryStore = TrackerCategoryStore()
    private var categories: [String] = []
    
    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CategoryViewCell.identifier)
        tableView.rowHeight = 75
        tableView.separatorStyle = .singleLine
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.yWhiteDay, for: .normal)
        button.backgroundColor = .yBlackDay
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(didTapAddCategory), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadCategories()
        
        selectedCategory = preselectedCategory
    }
    
    // MARK: - Actions
    @objc private func didTapAddCategory() {
        let newCategoryVC = NewCategoryViewController()
        newCategoryVC.onCategoryCreated = { [weak self] category in
            self?.saveCategory(category)
        }
        
        let navController = UINavigationController(rootViewController: newCategoryVC)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true)
    }
    
    // MARK: - Private Methods
    private func loadCategories() {
        categories = categoryStore.allCategories.map { $0.title }
        tableView.reloadData()
    }
    
    private func saveCategory(_ title: String) {
        do {
            try categoryStore.createCategory(title: title)
            loadCategories()
        } catch {
            print("[CategoryViewController]: Failed to save category: \(error)")
        }
    }
    
    // MARK: - UI Methods
    private func setupUI() {
        view.backgroundColor = .yWhiteDay
        setupNavigationBar()
        
        view.addSubview(tableView)
        view.addSubview(addCategoryButton)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -16),
            
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupNavigationBar() {
        title = "Категории"
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor(resource: .yBlackDay),
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
    }
}

// MARK: - UITableViewDataSource
extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryViewCell.identifier, for: indexPath)
        let category = categories[indexPath.row]
        
        cell.textLabel?.text = category
        cell.backgroundColor = .cellGrayBackground
        cell.layer.cornerRadius = 16
        cell.layer.masksToBounds = true
        
        if category == selectedCategory {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let category = categories[indexPath.row]
        selectedCategory = category
        delegate?.didSelectCategory(category)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}
