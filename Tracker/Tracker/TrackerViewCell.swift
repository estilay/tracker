import UIKit

protocol TrackerCellDelegate: AnyObject {
    func trackerCellDidTapAction(_ cell: TrackerViewCell, trackerId: UUID)
}

final class TrackerViewCell: UICollectionViewCell {
    static let identifier: String = "TrackerCell"
    weak var delegate: TrackerCellDelegate?
    
    // MARK: - Properties
    private var trackerId: UUID?
    private var trackerColor: UIColor?
    private var dayCount: Int = 0 {
        didSet {
            valueLabel.text = "\(dayCount) день"
        }
    }
    
    // MARK: - UI Elements
    private let cardView: UIView = {
        let view = UIView()
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
    
    private let emojiView: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.backgroundColor = .yWhiteDay.withAlphaComponent(0.3)
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.contentMode = .center
        label.baselineAdjustment = .alignCenters
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
    
    private lazy var actionButton: UIButton = {
        let button = UIButton()
        let image = UIImage(resource: .property1Plus).withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = cardView.backgroundColor
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Actions
    @objc private func actionButtonTapped() {
        guard let trackerId else { return }
        
        dayCount += 1
        
        let doneImage = UIImage(resource: .property1Done).withTintColor(trackerColor ?? .colorSelection5)
        actionButton.setImage(doneImage, for: .normal)
        actionButton.isEnabled = false
        
        delegate?.trackerCellDidTapAction(self, trackerId: trackerId)
    }
    
    // MARK: - Configuration
    func configure(with tracker: Tracker, completedDays: Int, isCompletedToday: Bool, selectedDate: Date) {
        trackerId = tracker.id
        trackerColor = tracker.color
        titleLabel.text = tracker.name
        emojiView.text = tracker.icon
        cardView.backgroundColor = tracker.color
        dayCount = completedDays
        
        let calendar = Calendar.current
        let isFutureDate = calendar.isDate(selectedDate, inSameDayAs: Date()) ? false : selectedDate > Date()
        
        if isFutureDate {
            actionButton.isHidden = true
            actionButton.isEnabled = false
        } else if isCompletedToday {
            let doneImage = UIImage(resource: .property1Done).withTintColor(tracker.color)
            actionButton.setImage(doneImage, for: .normal)
            actionButton.isEnabled = false
            actionButton.isHidden = false
        } else {
            let plusImage = UIImage(resource: .property1Plus).withRenderingMode(.alwaysTemplate)
            actionButton.setImage(plusImage, for: .normal)
            actionButton.tintColor = tracker.color
            actionButton.isHidden = false
            actionButton.isEnabled = true
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        contentView.addSubview(cardView)
        cardView.addSubview(emojiView)
        cardView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        contentView.addSubview(actionButton)
        
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
            
            emojiView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiView.widthAnchor.constraint(equalToConstant: 24),
            emojiView.heightAnchor.constraint(equalToConstant: 24),
            
            valueLabel.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 16),
            valueLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            valueLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            valueLabel.trailingAnchor.constraint(equalTo: actionButton.leadingAnchor, constant: -8),
            
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            actionButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            actionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            actionButton.widthAnchor.constraint(equalToConstant: 42),
            actionButton.heightAnchor.constraint(equalToConstant: 42)
        ])
    }
}

