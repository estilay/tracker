import UIKit

// MARK: - EmojiViewCell
final class EmojiViewCell: UICollectionViewCell {
    static let identifier = "EmojiViewCell"
    
    lazy var emojiView: UILabel  = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.numberOfLines = 1
        label.layer.cornerRadius = 16
        label.layer.masksToBounds = true
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    private func setupUI() {
        contentView.addSubview(emojiView)
        
        NSLayoutConstraint.activate([
            emojiView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emojiView.heightAnchor.constraint(equalToConstant: 52),
            emojiView.widthAnchor.constraint(equalToConstant: 52)
        ])
    }
}
