import UIKit
import UI
import CoreFoundationLib
import OpenCombine
import CoreDomain

final class PressFXView: UIView {
    private var roundedIcon: Bool?
    private let iconSize: CGFloat = 32.0
    private var anySubscriptions = Set<AnyCancellable>()
    private var option: FooterOptionType?
    let setOptionValueSubject = PassthroughSubject<PrivateMenuFooterOption, Never>()
    let tapSubject = PassthroughSubject<FooterOptionType, Never>()

    private let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 0
        
        return stack
    }()
    
    let imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .center
        image.clipsToBounds = true
        return image
    }()
    
    private let labelContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .clear
        return container
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.numberOfLines = 2
        label.textColor = .lisboaGray
        return label
    }()
    
    private lazy var pressView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        
        return view
    }()
    
    private lazy var badgeView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.santanderRed
        view.layer.borderColor = UIColor.bg.cgColor
        view.layer.borderWidth = 1.0
        view.isHidden = true
        addSubview(view)
        view.layer.cornerRadius = 5.5
        view.heightAnchor.constraint(equalToConstant: 11.0).isActive = true
        view.widthAnchor.constraint(equalToConstant: 11.0).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0).isActive = true
        view.centerYAnchor.constraint(equalTo: imageView.topAnchor, constant: 2).isActive = true
        view.accessibilityIdentifier = "PrivateMenuViewNotificationBadge"
        return view
    }()
    
    var pressFXColor: UIColor = .lightSky {
        didSet {
            pressView.backgroundColor = pressFXColor
        }
    }
    
    var contentTopAnchor: NSLayoutYAxisAnchor {
        return containerStackView.topAnchor
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    func showNotificationBadge(_ show: Bool) {
        badgeView.isHidden = !show
    }
    
    func getOption() -> FooterOptionType? {
        return option
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        pressView.isHidden = false
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        pressView.isHidden = true
        guard let option = self.option else { return }
        self.tapSubject.send(option)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        pressView.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pressView.layer.cornerRadius = 4
    }
    
    func updateManagerImage(_ image: UIImage) {
        roundedIcon = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = iconSize / 2
        imageView.image = image
    }
}

private extension PressFXView {
    func setupViews() {
        pressView.embedInto(container: self)
        addSubview(containerStackView)
        NSLayoutConstraint.activate([
            containerStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                       constant: -4),
            containerStackView.topAnchor.constraint(equalTo: topAnchor,
                                                    constant: 4)
        ])
        containerStackView.addArrangedSubview(imageView)
        containerStackView.addArrangedSubview(label)
        NSLayoutConstraint.activate([imageView.widthAnchor.constraint(equalToConstant: iconSize),
                                     imageView.heightAnchor.constraint(equalToConstant: iconSize)
                                    ])
        label.widthAnchor.constraint(equalTo: pressView.widthAnchor).isActive = true
        clipsToBounds = false
        bind()
    }
    func setTitle(_ titleKey: String) {
        let font = UIFont.santander(family: .text, type: .regular, size: 14.0)
        let configuration = LocalizedStylableTextConfiguration(font: font,
                                                               alignment: .center,
                                                               lineHeightMultiple: 0.75,
                                                               lineBreakMode: .byWordWrapping)
        label.configureText(withKey: titleKey, andConfiguration: configuration)
    }
    
    func setIcon(_ iconKey: String?) {
        guard let iconKey = iconKey else {
            return
        }
        imageView.image = Assets.image(named: iconKey)
    }
    
    func setLabelAccessibilityIdentifier(with option: PrivateMenuFooterOptionRepresentable) {
        imageView.isAccessibilityElement = true
        label.accessibilityIdentifier = option.title
        imageView.accessibilityIdentifier = option.imageName
        if let imageUrl = option.imageURL {
            imageView.accessibilityIdentifier = imageUrl
        }
        self.accessibilityIdentifier = option.accessibilityIdentifier
    }
    
    func bind() {
        setOptionValueSubject.sink { [unowned self] option in
            self.option = option.optionType
            self.setTitle(option.title)
            self.setIcon(option.imageName)
            if let imageUrl = option.imageURL {
                self.imageView.loadImage(urlString: imageUrl)
            }
            self.setLabelAccessibilityIdentifier(with: option)
        }.store(in: &anySubscriptions)
    }
}
