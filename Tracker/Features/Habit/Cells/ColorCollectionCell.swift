import UIKit

// MARK: - ColorCollectionCell
final class ColorCollectionCell: UITableViewCell {
    static let identifier = "ColorCollectionCell"
    
    var onColorSelected: ((UIColor) -> Void)?
    
    private var selectedColor: UIColor?
    
    private var colors: [UIColor] = [
        .colorSelection1, .colorSelection2, .colorSelection3, .colorSelection4, .colorSelection5, .colorSelection6, .colorSelection7, .colorSelection8, .colorSelection9, .colorSelection10, .colorSelection11, .colorSelection12, .colorSelection13, .colorSelection14, .colorSelection15, .colorSelection16, .colorSelection17, .colorSelection18
    ]
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ColorViewCell.self, forCellWithReuseIdentifier: ColorViewCell.identifier)
        collectionView.register(HabitHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HabitHeaderView.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = false
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    func setSelectedColor(_ color: UIColor?) {
        selectedColor = color
        collectionView.reloadData()
    }
    
    private func setupUI() {
        contentView.addSubview(collectionView)
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
        ])
    }
    
    // MARK: - Color Comparison
    private func isSameColor(_ lhs: UIColor, _ rhs: UIColor) -> Bool {
        guard let lhsComponents = lhs.cgColor.components,
              let rhsComponents = rhs.cgColor.components,
              lhsComponents.count == rhsComponents.count else {
            return false
        }
        return zip(lhsComponents, rhsComponents).allSatisfy { abs($0 - $1) < 0.001 }
    }
}

// MARK: - UICollectionViewDataSource
extension ColorCollectionCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorViewCell.identifier, for: indexPath) as? ColorViewCell else { return UICollectionViewCell() }
        
        let color = colors[indexPath.row]
        cell.colorRectangleView.backgroundColor = color
        
        let isSelected = selectedColor.map { isSameColor($0, color) } ?? false
        cell.pickedColorView.layer.borderWidth = isSelected ? 3 : 0
        cell.pickedColorView.layer.borderColor = isSelected ? color.withAlphaComponent(0.3).cgColor : UIColor.clear.cgColor
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
        
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HabitHeaderView.identifier, for: indexPath) as? HabitHeaderView else { return UICollectionReusableView() }
        
        header.titleLabel.text = String(localized: "Цвет")
        header.titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ColorCollectionCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 6, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let color = colors[indexPath.row]
        selectedColor = color
        collectionView.reloadData()
        onColorSelected?(color)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 19)
    }
}
