import UIKit

final class TrackerViewCell: UICollectionViewCell {
    static let identifier: String = "TrackerCell"
    
    
    // MARK: - UI Elements
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .colorSelection5
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(resource: .borderCard).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .yWhiteDay
        label.numberOfLines = 2
        label.textAlignment = .left
        label.contentMode = .bottom
        label.baselineAdjustment = .alignBaselines
        label.translatesAutoresizingMaskIntoConstraints = false

        
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 1
        label.textAlignment = .left
        label.textColor = .yBlackDay
        label.backgroundColor = .clear
        label.text = "0 дней"
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton()
        let image = UIImage(resource: .property1Plus).withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .colorSelection5
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(cardView)
        cardView.addSubview(titleLabel)
        contentView.addSubview(actionButton)
        contentView.addSubview(valueLabel)
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 44),
            
            valueLabel.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 16),
            valueLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            valueLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            valueLabel.trailingAnchor.constraint(equalTo: actionButton.leadingAnchor, constant: -8),
            
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            actionButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            actionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    
}

