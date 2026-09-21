import UIKit

// MARK: - StatViewCell
final class StatViewCell: UITableViewCell {
    static let identifier = "StatViewCell"
    
    // MARK: - Constants
    private enum Constants {
        static let cornerRadius: CGFloat = 16
        static let borderWidth: CGFloat = 1
    }
    
    // MARK: - UI Elements
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(resource: .colorSelection1).cgColor,
            UIColor(resource: .colorSelection5).cgColor,
            UIColor(resource: .colorSelection3).cgColor
        ]
        layer.locations = [0.0, 0.5, 1.0]
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        return layer
    }()
    
    private let borderMaskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.black.cgColor
        layer.lineWidth = Constants.borderWidth
        return layer
    }()
    
    private let containerView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 7
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let recordLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .yBlackDay
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .yBlackDay
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradientFrame()
    }
    
    // MARK: - Configuration
    func configure(record: String, title: String) {
        recordLabel.text = record
        titleLabel.text = title
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        layer.cornerRadius = Constants.cornerRadius
        layer.masksToBounds = true
        
        containerView.addArrangedSubview(recordLabel)
        containerView.addArrangedSubview(titleLabel)
        
        contentView.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            recordLabel.heightAnchor.constraint(equalToConstant: 41),
            titleLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
        
        setupGradientBorder()
    }
    
    private func setupGradientBorder() {
        gradientLayer.mask = borderMaskLayer
        layer.addSublayer(gradientLayer)
    }
    
    private func updateGradientFrame() {
        gradientLayer.frame = bounds
        
        let inset = Constants.borderWidth / 2
        let rect = bounds.insetBy(dx: inset, dy: inset)
        let path = UIBezierPath(
            roundedRect: rect,
            cornerRadius: Constants.cornerRadius
        )
        borderMaskLayer.path = path.cgPath
        borderMaskLayer.frame = bounds
    }
}
