import UIKit

// MARK: - HabitDetailCell
final class HabitDetailCell: UITableViewCell {
    static let identifier = "HabitDetailCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    private func setupUI() {
        backgroundColor = .cellGrayBackground
        
        layer.cornerRadius = 16
        layer.masksToBounds = true
        
        textLabel?.textColor = .yBlackDay
        textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        
        detailTextLabel?.textColor = .yGray
        detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        
        accessoryType = .disclosureIndicator
        selectionStyle = .default
    }
    
    func configure(title: String, value: String) {
        textLabel?.text = title
        detailTextLabel?.text = value
    }
}
