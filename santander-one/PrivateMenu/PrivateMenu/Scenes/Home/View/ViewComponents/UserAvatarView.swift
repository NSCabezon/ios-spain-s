import UIKit
import CoreFoundationLib
import OpenCombine
import CoreDomain

class UserAvatarView: ResponsiveView {
    private var anySubscriptions = Set<AnyCancellable>()
    let nameSubject = PassthroughSubject<NameRepresentable, Never>()
    let avatarImageSubject = PassthroughSubject<Data, Never>()
    let tapSubject = PassthroughSubject<Void, Never>()
    private var name: NameRepresentable?
    
    private let imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.isHidden = true
        image.layer.borderColor = UIColor.botonRedLight.cgColor
        image.layer.borderWidth = 1.4
        
        return image
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .horizontal)
        
        return label
    }()
    
    private let roundedView: UIView = {
        let roundedView = UIView()
        roundedView.translatesAutoresizingMaskIntoConstraints = false
        roundedView.backgroundColor = .white
        roundedView.layer.borderColor = UIColor.botonRedLight.cgColor
        roundedView.layer.borderWidth = 1.4
        
        return roundedView
    }()
    
    private lazy var viewTapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handlePersonalAreaTap(_:)))
        return tap
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    private func setupViews() {
        addSubview(roundedView)
        addSubview(imageView)
        setupConstraints()
        titleLabel.font = UIFont(name: "SantanderHeadline-Regular", size: 17)
        titleLabel.textColor = .santanderRed
        self.setAccessibilityIdentifiers()
        self.bind()
        self.addGestureRecognizer(self.viewTapGesture)
    }
    
    private func setupConstraints() {
        imageView.heightAnchor.constraint(equalToConstant: 64).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 64).isActive = true
        imageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16.0).isActive = true
        imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14.0).isActive = true
        roundedView.heightAnchor.constraint(equalToConstant: 64).isActive = true
        roundedView.widthAnchor.constraint(equalToConstant: 64).isActive = true
        roundedView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16.0).isActive = true
        roundedView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        roundedView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        roundedView.addSubview(titleLabel)
        titleLabel.centerXAnchor.constraint(equalTo: roundedView.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: roundedView.centerYAnchor).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = imageView.bounds.height / 2
        imageView.clipsToBounds = true
        roundedView.layer.cornerRadius = roundedView.bounds.height / 2
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func setImage(_ image: UIImage?) {
        imageView.isHidden = image == nil
        roundedView.isHidden = image != nil
        imageView.image = image
    }
    
    func setAccessibilityIdentifiers() {
        self.roundedView.isAccessibilityElement = true
        self.roundedView.accessibilityIdentifier = AccessibilitySideMenu.avatarRoundedView
    }
    
    func bind() {
        nameSubject
            .sink { [unowned self] name in
                setTitle(name.initials ?? "")
                self.name = name
            }.store(in: &anySubscriptions)
        avatarImageSubject
            .sink { [unowned self] image in
                self.setImage(UIImage(data: image))
            }.store(in: &anySubscriptions)
    }
    
    @objc func handlePersonalAreaTap(_ sender: UITapGestureRecognizer) {
        tapSubject.send()
    }
}
