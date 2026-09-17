import UIKit

protocol NewCategoryViewCellDelegate: AnyObject {
    func categoryNameDidChange(_ name: String)
}

// MARK: - NewCategoryViewCell
final class NewCategoryViewCell: UITableViewCell {
    static let identifier = "NewCategoryViewCell"
    weak var delegate: NewCategoryViewCellDelegate?
    
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = String(localized: "Введите название категории")
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
    

    @objc private func textFieldDidChange() {
        guard let text = textField.text else { return }
        delegate?.categoryNameDidChange(text)
    }
    
    // MARK: - UI Methods
    private func setupUI() {
        backgroundColor = .cellBackground
        
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
