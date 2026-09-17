import UIKit

protocol FilterSelectionDelegate: AnyObject {
    func didSelectFilter(_ filter: FilterType)
}

// MARK: - FilterViewController
final class FilterViewController: UIViewController {
    // MARK: - Properties
    weak var delegate: FilterSelectionDelegate?
    
    private let filters = FilterType.allCases
    private var selectedFilter: FilterType
    
    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: FilterViewCell.identifier)
        tableView.rowHeight = 75
        tableView.separatorStyle = .singleLine
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    // MARK: - Init
    init(selectedFilter: FilterType = .all) {
        self.selectedFilter = selectedFilter
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - UI Methods
    private func setupUI() {
        view.backgroundColor = .yWhiteDay
        setupNavigationBar()
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        title = "Фильтры"
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor(resource: .yBlackDay),
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
    }
}

// MARK: - UITableViewDataSource
extension FilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FilterViewCell.identifier, for: indexPath)
        let filter = filters[indexPath.row]
        
        cell.textLabel?.text = filter.title
        cell.backgroundColor = .cellGrayBackground
        cell.layer.cornerRadius = 16
        cell.layer.masksToBounds = true
        cell.selectionStyle = .none
        
        let isChecked = (filter == selectedFilter) && filter.showsCheckmark
        cell.accessoryType = isChecked ? .checkmark : .none
        cell.tintColor = .yBlue
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let newFilter = filters[indexPath.row]
        guard newFilter != selectedFilter else { return }
        
        let previousFilter = selectedFilter
        selectedFilter = newFilter
        
        var rowsToReload: [IndexPath] = []
        if previousFilter.showsCheckmark,
           let index = filters.firstIndex(of: previousFilter) {
            rowsToReload.append(IndexPath(row: index, section: 0))
        }
        if newFilter.showsCheckmark,
           let index = filters.firstIndex(of: newFilter) {
            rowsToReload.append(IndexPath(row: index, section: 0))
        }
        tableView.reloadRows(at: rowsToReload, with: .none)
        
        delegate?.didSelectFilter(newFilter)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}
