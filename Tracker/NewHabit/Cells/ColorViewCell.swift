import UIKit

// MARK: - ColorViewCell
final class ColorViewCell: UICollectionViewCell {
    static let identifier = "ColorCell"
    
    lazy var pickedColorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 0
        view.layer.borderColor = UIColor.clear.cgColor
        view.layer.masksToBounds = true
        
        return view
    }()
    
    lazy var colorRectangleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.backgroundColor = .clear
        
        return view
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
        contentView.addSubview(pickedColorView)
        pickedColorView.addSubview(colorRectangleView)
        
        NSLayoutConstraint.activate([
            pickedColorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            pickedColorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            pickedColorView.widthAnchor.constraint(equalToConstant: 52),
            pickedColorView.heightAnchor.constraint(equalToConstant: 52),
            
            colorRectangleView.widthAnchor.constraint(equalToConstant: 40),
            colorRectangleView.heightAnchor.constraint(equalToConstant: 40),
            colorRectangleView.centerXAnchor.constraint(equalTo: pickedColorView.centerXAnchor),
            colorRectangleView.centerYAnchor.constraint(equalTo: pickedColorView.centerYAnchor)
        ])
    }
}
