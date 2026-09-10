import UIKit

final class SecondOnboardingContentViewController: UIViewController {
    private lazy var image: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(resource: ._2Onboarding)
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        
        return image
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = "Даже если это\n не литры воды и йога"
        label.textColor = .yBlackDay
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        view.addSubview(image)
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: view.topAnchor),
            image.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            image.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            image.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 432),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
}
