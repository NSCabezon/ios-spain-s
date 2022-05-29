import UIKit
import UI

final class PressFXView: UIView {
    
    var action: (() -> Void)?
    
    private var roundedIcon: Bool?
    private let iconSize: CGFloat = 32.0
    
    private let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 0
        
        return stack
    }()
    
    private let imageView: UIImageView = {
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
        
        return label
    }()
    
    private lazy var pressView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = pressFXColor
        
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
    
    var coachmarkId: CoachmarkIdentifier?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    private func setupViews() {
        label.applyStyle(LabelStylist(textColor: .lisboaGrayNew, font: UIFont.santanderTextRegular(size: 14), textAlignment: .center))
        pressView.isHidden = true
        pressView.embedInto(container: self)
        addSubview(containerStackView)
        containerStackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        containerStackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        containerStackView.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 2).isActive = true
        containerStackView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 2).isActive = true
        containerStackView.addArrangedSubview(imageView)
        containerStackView.addArrangedSubview(labelContainer)
        imageView.widthAnchor.constraint(equalToConstant: iconSize).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: iconSize).isActive = true
        labelContainer.addSubview(label)
        label.topAnchor.constraint(equalTo: labelContainer.topAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: labelContainer.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: labelContainer.trailingAnchor).isActive = true
        label.bottomAnchor.constraint(greaterThanOrEqualTo: labelContainer.bottomAnchor).isActive = true
        clipsToBounds = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        pressView.isHidden = false
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        pressView.isHidden = true
        action?()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        pressView.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pressView.layer.cornerRadius = 4
        if roundedIcon == true {
            imageView.layer.cornerRadius = iconSize / 2
        }
    }
    
    func setTitle(_ title: LocalizedStylableText) {
        label.set(localizedStylableText: title)
    }
    
    func setIcon(_ iconKey: String?) {
        guard let iconKey = iconKey else {
            return
        }
        imageView.image = Assets.image(named: iconKey)
    }
    
    func setCoachmarkId(_ id: CoachmarkIdentifier?) {
        self.coachmarkId = id
    }
    
    func setLabelAccessibilityIdentifier(_ accessibilityID: String) {
        self.label.accessibilityIdentifier = accessibilityID
    }
    
    func updateImageWith(_ url: URL, rounded: Bool = true) {
        imageView.setImage(url: url.absoluteString,
                              placeholder: imageView.image,
                              options: [.transitionCrossDissolve]) { [weak self] image in
            guard let image = image, let strongSelf = self else {
                return
            }
            strongSelf.roundedIcon = rounded
            if rounded {
                strongSelf.imageView.layer.cornerRadius = strongSelf.iconSize / 2
                strongSelf.imageView.clipsToBounds = true
            }
            strongSelf.imageView.contentMode = .scaleAspectFill
            strongSelf.imageView.setNeedsLayout()
        }
    }
    
    func showNotificationBadge(_ show: Bool) {
        badgeView.isHidden = !show
    }
}

extension PressFXView: CoachmarkPointableView {
    
    var coachmarkPoint: CGPoint {
        return CGPoint(x: imageView.frame.midX, y: imageView.frame.midY)
    }
    
}
