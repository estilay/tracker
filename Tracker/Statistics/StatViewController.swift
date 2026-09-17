import UIKit

// MARK: - StatViewController
final class StatViewController: UIViewController {
    
    // MARK: - Constants
    private enum Constants {
        static let cellHeight: CGFloat = 90
        static let tableTopInset: CGFloat = 24
        static let tableHorizontalInset: CGFloat = 16
    }
    
    // MARK: - Properties
    private var statItems: [(record: String, title: String)] = []
    
    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.register(StatViewCell.self, forCellReuseIdentifier: StatViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.sectionHeaderTopPadding = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isHidden = true
        return tableView
    }()
    
    private lazy var stubImageView: UIImageView = {
        let stubImage = UIImage(resource: .statisticsStub)
        let stubImageView = UIImageView(image: stubImage)
        stubImageView.translatesAutoresizingMaskIntoConstraints = false
        return stubImageView
    }()
    
    private lazy var stubLabel: UILabel = {
        let stubLabel = UILabel()
        stubLabel.textColor = .yBlackDay
        stubLabel.text = String(localized: "Анализировать пока нечего")
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadStatistics()
        updateContentVisibility(hasData: !statItems.isEmpty)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadStatistics()
        tableView.reloadData()
        updateContentVisibility(hasData: !statItems.isEmpty)
    }
    
    // MARK: - Statistics
    private func loadStatistics() {
        let stats = StatisticsService.shared.statistics
        guard stats.completedTrackers > 0 else {
            statItems = []
            return
        }
        statItems = [
            (record: "\(stats.completedTrackers)", title: String(localized: "Трекеров завершено"))
        ]
    }
    
    // MARK: - UI Methods
    private func setupUI() {
        view.backgroundColor = .yWhiteDay
        setupNavigationBar()
        setupTableView()
        setupStubContainerUI()
    }
    
    private func setupNavigationBar() {
        title = String(localized: "Статистика")
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: UIColor.yBlackDay,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.tableTopInset),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.tableHorizontalInset),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.tableHorizontalInset),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupStubContainerUI() {
        view.addSubview(stubContainerView)
        
        NSLayoutConstraint.activate([
            stubContainerView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stubContainerView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    
    private func updateContentVisibility(hasData: Bool) {
        tableView.isHidden = !hasData
        stubContainerView.isHidden = hasData
    }
}

// MARK: - UITableViewDataSource
extension StatViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return statItems.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: StatViewCell.identifier,
            for: indexPath
        ) as? StatViewCell else {
            return UITableViewCell()
        }
        
        let item = statItems[indexPath.section]
        cell.configure(record: item.record, title: item.title)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension StatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellHeight
    }
}
