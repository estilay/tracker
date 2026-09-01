import UIKit

protocol HabitNameCellDelegate: AnyObject {
    func habitNameDidChange(_ name: String)
    func didExceedCharacterLimit(_ isExceeded: Bool)
}

// MARK: - HabitNameCell
final class HabitNameCell: UITableViewCell {
    static let identifier = "HabitNameCell"
    weak var delegate: HabitNameCellDelegate?
    static let maxCharacterLimit = 38
    
    // MARK: - UI Elements
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.textColor = .yBlackDay
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Private Methods
    @objc private func textFieldDidChange() {
        guard let text = textField.text else { return }
        
        if text.count > HabitNameCell.maxCharacterLimit {
            let trimmedText = String(text.prefix(HabitNameCell.maxCharacterLimit))
            textField.text = trimmedText
            
            delegate?.didExceedCharacterLimit(true)
            delegate?.habitNameDidChange(trimmedText)
        } else {
            delegate?.didExceedCharacterLimit(false)
            delegate?.habitNameDidChange(text)
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .cellGrayBackground
        
        layer.cornerRadius = 16
        layer.masksToBounds = true
        selectionStyle = .none
        
        contentView.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
