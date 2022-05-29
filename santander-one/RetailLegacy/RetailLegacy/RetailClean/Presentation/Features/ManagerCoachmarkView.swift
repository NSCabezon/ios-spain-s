import CoreFoundationLib
import UIKit
import UI

protocol CoachmarkPointableView: CoachmarkUIView {
    var coachmarkPoint: CGPoint { get }
}

final class ManagerCoachmarkInfo {
    private (set) var bannerString: String?
    private (set) var offerAction: (() -> Void)?
    var title: LocalizedStylableText
    var subtitle: LocalizedStylableText
    var imageURL: String? {
        didSet {
            guard let imageURL = imageURL else {
                return
            }
            didUpdateImageURL?(imageURL)
        }
    }
    var didUpdateImageURL: ((String) -> Void)?
    
    func setOfferWithBanner(subtitle: String? = nil,
                            bannerString: String,
                            action: @escaping () -> Void) {
        if let subtitle = subtitle {
            self.subtitle = localized(subtitle)
        }
        self.bannerString = bannerString
        self.offerAction = action
    }
    
    init(title: LocalizedStylableText, subtitle: LocalizedStylableText) {
        self.title = title
        self.subtitle = subtitle
    }
}

final class ManagerCoachmarkView: UIView {
    private let imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.setContentCompressionResistancePriority(.required, for: .vertical)

        return image
    }()
    
    @objc private let closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        return scroll
    }()
    
    private let imageStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 5
        stack.setContentCompressionResistancePriority(.required, for: .vertical)
        
        return stack
    }()
    
    private let dialogStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 4
        stack.setContentCompressionResistancePriority(.required, for: .vertical)
        
        return stack
    }()
    
    private let title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        
        return label
    }()
    
    private let subtitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        
        return label
    }()
    
    private let dialogView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        
        return view
    }()
    
    private var dialogStackViewHeight: NSLayoutConstraint?
    
    private var offerAction: (() -> Void)?
    var onCloseAction: (() -> Void)?
    var relativeCenterXAnchor: NSLayoutXAxisAnchor {
        return imageView.centerXAnchor
    }
    var relativeCenterYAnchor: NSLayoutYAxisAnchor {
        return imageView.centerYAnchor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return subviews.contains(where: { !$0.isHidden && $0.point(inside: self.convert(point, to: $0), with: event) })
    }
    
    private func setupViews() {
        title.applyStyle(LabelStylist(textColor: UIColor.lisboaGrayNew, font: .santanderTextLight(size: 20)))
        subtitle.applyStyle(LabelStylist(textColor: UIColor(white: 77.0 / 255.0, alpha: 1.0), font: .santanderTextLight(size: 16)))
        closeButton.setImage(Assets.image(named: "icnClose"), for: .normal)
        closeButton.addTarget(self, action: #selector(closePressed), for: .touchUpInside)
        scrollView.embedInto(container: dialogView, padding: 20.0)
        scrollView.addSubview(dialogStackView)
        dialogStackView.addArrangedSubview(title)
        dialogStackView.addArrangedSubview(subtitle)
        addSubview(dialogView)
        let arrowImageView = UIImageView(image: Assets.image(named: "icn_triangle_bubble"))
        arrowImageView.setContentCompressionResistancePriority(.required, for: .vertical)
        imageStackView.addArrangedSubview(arrowImageView)
        imageStackView.addArrangedSubview(imageView)
        addSubview(imageStackView)
        dialogView.addSubview(closeButton)
        setupConstraints()
        setupShadows(arrow: arrowImageView, dialog: dialogView)
        self.setAccessibilityIdentifiers()
    }
    
    fileprivate func setupShadows(arrow: UIImageView, dialog: UIView) {
        arrow.layer.shadowColor = UIColor.gray.cgColor
        arrow.layer.shadowOffset = CGSize(width: 0, height: 4)
        arrow.layer.shadowRadius = 2
        arrow.layer.shadowOpacity = 0.5
        
        dialog.layer.shadowColor = UIColor.gray.cgColor
        dialog.layer.shadowOffset = CGSize(width: 0, height: 4)
        dialog.layer.shadowRadius = 2
        dialog.layer.shadowOpacity = 0.5
    }
    
    @objc func closePressed() {
        onCloseAction?()
    }
    
    private func setupConstraints() {
        dialogStackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        dialogStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        dialogStackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
        dialogStackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        
        let scrollHeight = scrollView.heightAnchor.constraint(equalTo: dialogStackView.heightAnchor, multiplier: 1)
        scrollHeight.priority = .defaultLow
        scrollHeight.isActive = true
        
        dialogStackView.leftAnchor.constraint(equalTo: dialogView.leftAnchor, constant: 20.0).isActive = true
        dialogStackView.rightAnchor.constraint(equalTo: dialogView.rightAnchor, constant: -20.0).isActive = true
        let stackHeight = dialogView.heightAnchor.constraint(equalTo: dialogStackView.heightAnchor, multiplier: 1.3)
        stackHeight.priority = .defaultLow
        stackHeight.isActive = true
        dialogStackViewHeight = stackHeight
        
        imageStackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imageStackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 64.0).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 64.0).isActive = true
        dialogView.bottomAnchor.constraint(equalTo: imageStackView.topAnchor).isActive = true
        dialogView.leftAnchor.constraint(equalTo: leftAnchor, constant: 4).isActive = true
        dialogView.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        dialogView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 50).isActive = true

        closeButton.topAnchor.constraint(equalTo: dialogView.topAnchor, constant: 8).isActive = true
        closeButton.rightAnchor.constraint(equalTo: dialogView.rightAnchor, constant: -8).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = imageView.bounds.height / 2
    }
    
    func setTitle(_ title: LocalizedStylableText?) {
        guard let title = title else {
            return
        }
        self.title.set(localizedStylableText: title)
    }
    
    func setSubtitle(_ text: LocalizedStylableText?) {
        guard let text = text else {
            return
        }
        subtitle.set(localizedStylableText: text)
    }
    
    func setImage(_ image: UIImage?) {
        imageView.image = image
    }
    
    func setCoachmarkInfo(_ info: ManagerCoachmarkInfo) {
        setTitle(info.title)
        setSubtitle(info.subtitle)
        setImage(Assets.image(named: "icnMyManagerDefaultBig"))
        info.didUpdateImageURL = { [weak self] stringURL in
            guard let url = URL(string: stringURL) else {
                return
            }
            self?.updateImageWith(url)
        }
        if let urlString = info.bannerString, let url = URL(string: urlString), let action = info.offerAction {
            addOffer(url: url, action: action)
        }
    }
    
    @objc func offerPressed() {
        offerAction?()
    }
    private func addOffer(url: URL, action: @escaping (() -> Void)) {
        let wrapperView = UIView()
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        let bannerImage = UIImageView()
        bannerImage.translatesAutoresizingMaskIntoConstraints = false
        bannerImage.backgroundColor = .white
        bannerImage.isAccessibilityElement = true
        bannerImage.accessibilityIdentifier = AccessibilityCoachmark.managerCoachmarkBannerImageView.rawValue
        offerAction = action
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(offerPressed))
        wrapperView.addGestureRecognizer(tapGesture)
        bannerImage.embedInto(container: wrapperView)
        
        dialogStackView.addArrangedSubview(wrapperView)
        bannerImage.setImage(url: url.absoluteString, placeholder: bannerImage.image, options: []) { [weak self] image in
            guard let image = image else {
                return
            }
            let width = image.size.width
            let height = image.size.height 
            bannerImage.widthAnchor.constraint(equalTo: bannerImage.heightAnchor, multiplier: width/height).isActive = true
            guard let self = self else { return }
            self.dialogStackViewHeight?.isActive = false
            let stackHeight = self.dialogView.heightAnchor.constraint(equalTo: self.dialogStackView.heightAnchor, multiplier: 1.3)
            stackHeight.priority = .defaultLow
            stackHeight.isActive = true
            self.dialogStackViewHeight = stackHeight
            self.setNeedsLayout()
        }
    }
    
    func updateImageWith(_ url: URL) {
        imageView.setImage(url: url.absoluteString, placeholder: imageView.image, options: [.transitionCrossDissolve]) { [weak self] image  in
            guard let image = image, let strongSelf = self else {
                return
            }
            strongSelf.imageView.contentMode = .scaleAspectFill
            strongSelf.imageView.clipsToBounds = true
            strongSelf.imageView.layer.cornerRadius = strongSelf.imageView.bounds.height / 2
        }
    }
    
    func setAccessibilityIdentifiers() {
        self.closeButton.isAccessibilityElement = true
        self.closeButton.accessibilityIdentifier = AccessibilityCoachmark.managerCoachmarkBtnExit.rawValue
        self.closeButton.imageView?.isAccessibilityElement = true
        self.closeButton.imageView?.accessibilityIdentifier = AccessibilityCoachmark.managerCoachmarkBtnExit.rawValue
        self.title.accessibilityIdentifier = AccessibilityCoachmark.managerCoachmarkTitleLabel.rawValue
        self.subtitle.accessibilityIdentifier = AccessibilityCoachmark.managerCoachmarkSubtitleLabel.rawValue
        self.imageView.isAccessibilityElement = true
        self.imageView.accessibilityIdentifier = AccessibilityCoachmark.managerCoachmarkManagerImageView.rawValue
    }
}
