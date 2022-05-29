import CoreFoundationLib
import UIKit
import UI
import OpenCombine
import CoreDomain

public protocol ManagerCoachmarkInfoRepresentable {
    var showsManagerCoach: Bool { get }
    var title: LocalizedStylableText? { get }
    var subtitle: LocalizedStylableText? { get }
    var offerRepresentable: OfferRepresentable? { get }
    var thumbnailData: Data? { get }
}

final class ManagerCoachmarkView: UIView {
    private enum Constants {
        static let cornerIcon: CGFloat = 32.0
        static let spacingImageStack: CGFloat = 5.0
        static let spacingDialogStack: CGFloat = 4.0
        static let shadowOffset: CGSize = CGSize(width: 0, height: 4)
        static let shadowRadius: CGFloat = 2
        static let shadowOpacity: Float = 0.5
        static let titleFont: UIFont = .santander(family: .text, type: .light, size: 20.0)
        static let subtitleFont: UIFont = .santander(family: .text, type: .light, size: 16.0)
        static let subtitleColor = UIColor(white: 77.0 / 255.0, alpha: 1.0)
        static let padding: CGFloat = 20.0
        static let multiplierScroll: CGFloat = 1
        static let multiplierDialogView: CGFloat = 1.3
        static let constraintDialogStackView: CGFloat = 20.0
        static let constraintImageViewHeight: CGFloat = 64.0
        static let dialogViewLeftAnchor: CGFloat = 4
        static let dialogViewRightAnchor: CGFloat = -10
        static let dialogViewTopAnchor: CGFloat = 50
        static let closeButtonTopAnchor: CGFloat =  8
        static let closeButtonRightAnchor: CGFloat = -8
    }
    
    let subject = PassthroughSubject<ManagerCoachmarkInfoRepresentable, Never>()
    private var anySubscriptions = Set<AnyCancellable>()
    let tapCloseSubject = PassthroughSubject<Void, Never>()
    let tapOfferSubject = PassthroughSubject<Void, Never>()
    
    private let imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.masksToBounds = true
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = Constants.cornerIcon
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
        stack.spacing = Constants.spacingImageStack
        stack.setContentCompressionResistancePriority(.required, for: .vertical)
        return stack
    }()
    
    private let dialogStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = Constants.spacingDialogStack
        stack.setContentCompressionResistancePriority(.required, for: .vertical)
        return stack
    }()
    
    private let title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = .zero
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    private let subtitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = .zero
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
    
    fileprivate func setupShadows(arrow: UIImageView, dialog: UIView) {
        arrow.layer.shadowColor = UIColor.gray.cgColor
        arrow.layer.shadowOffset = Constants.shadowOffset
        arrow.layer.shadowRadius = Constants.shadowRadius
        arrow.layer.shadowOpacity = Constants.shadowOpacity
        dialog.layer.shadowColor = UIColor.gray.cgColor
        dialog.layer.shadowOffset = Constants.shadowOffset
        dialog.layer.shadowRadius = Constants.shadowRadius
        dialog.layer.shadowOpacity = Constants.shadowOpacity
    }
    
    func setCoachmarkInfo(_ info: ManagerCoachmarkInfoRepresentable) {
        if let title = info.title {
            self.title.configureText(withLocalizedString: title)
        }
        if let subtitle = info.subtitle {
            self.subtitle.configureText(withLocalizedString: subtitle)
        }
        if let image = info.thumbnailData {
            imageView.image = UIImage(data: image)
        } else {
            imageView.image = Assets.image(named: "icnMyManagerDefaultBig")
        }
        if let urlString = info.offerRepresentable?.bannerRepresentable?.url,
            let url = URL(string: urlString) {
            addOffer(url: url)
        }
    }
}

private extension ManagerCoachmarkView {
    func bind() {
        subject
            .sink { [unowned self] info in
                setCoachmarkInfo(info)
            }.store(in: &anySubscriptions)
    }
    
    func setupViews() {
        setupLabels()
        setupButton()
        setupScrollView()
        setupDialogStackView()
        setupArrowImageView()
        self.setAccessibilityIdentifiers()
        bind()
    }
    
    func setupLabels() {
        title.applyStyle(LabelStylist(textColor: .lisboaGray,
                                      font: Constants.titleFont))
        subtitle.applyStyle(LabelStylist(textColor:
                                            Constants.subtitleColor,
                                         font: Constants.subtitleFont))
    }
    
    func setupButton() {
        closeButton.setImage(Assets.image(named: "icnClose"), for: .normal)
        closeButton.addTarget(self, action: #selector(closePressed), for: .touchUpInside)
    }
    
    func setupScrollView() {
        scrollView.embedInto(container: dialogView, padding: Constants.padding)
        scrollView.addSubview(dialogStackView)
    }
    
    func setupDialogStackView() {
        dialogStackView.addArrangedSubview(title)
        dialogStackView.addArrangedSubview(subtitle)
        addSubview(dialogView)
    }
    
    func setupArrowImageView() {
        let arrowImageView = UIImageView(image: Assets.image(named: "icn_triangle_bubble"))
        arrowImageView.setContentCompressionResistancePriority(.required, for: .vertical)
        imageStackView.addArrangedSubview(arrowImageView)
        imageStackView.addArrangedSubview(imageView)
        addSubview(imageStackView)
        dialogView.addSubview(closeButton)
        setupConstraints()
        setupShadows(arrow: arrowImageView, dialog: dialogView)
    }
    
    @objc func closePressed() {
        tapCloseSubject.send()
    }
    
    @objc func offerPressed() {
        tapOfferSubject.send()
    }
    
    func setupConstraints() {
        setupConstraintsDialogStack()
        setupConstraintsDialog()
    }
    
    func setupConstraintsDialogStack() {
        dialogStackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        dialogStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        dialogStackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
        dialogStackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        let scrollHeight = scrollView.heightAnchor.constraint(equalTo: dialogStackView.heightAnchor,
                                                              multiplier: Constants.multiplierScroll)
        scrollHeight.priority = .defaultLow
        scrollHeight.isActive = true
        dialogStackView.leftAnchor.constraint(equalTo: dialogView.leftAnchor,
                                              constant: Constants.constraintDialogStackView).isActive = true
        dialogStackView.rightAnchor.constraint(equalTo: dialogView.rightAnchor,
                                               constant: -Constants.constraintDialogStackView).isActive = true
        let stackHeight = dialogView.heightAnchor.constraint(equalTo: dialogStackView.heightAnchor,
                                                             multiplier: Constants.multiplierDialogView)
        stackHeight.priority = .defaultLow
        stackHeight.isActive = true
        dialogStackViewHeight = stackHeight
    }
    
    func setupConstraintsDialog() {
        imageStackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imageStackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: Constants.constraintImageViewHeight).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: Constants.constraintImageViewHeight).isActive = true
        dialogView.bottomAnchor.constraint(equalTo: imageStackView.topAnchor).isActive = true
        dialogView.leftAnchor.constraint(equalTo: leftAnchor,
                                         constant: Constants.dialogViewLeftAnchor).isActive = true
        dialogView.rightAnchor.constraint(equalTo: rightAnchor, constant: Constants.dialogViewRightAnchor).isActive = true
        dialogView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor,
                                        constant: Constants.dialogViewTopAnchor).isActive = true
        closeButton.topAnchor.constraint(equalTo: dialogView.topAnchor,
                                         constant: Constants.closeButtonTopAnchor).isActive = true
        closeButton.rightAnchor.constraint(equalTo: dialogView.rightAnchor,
                                           constant: Constants.closeButtonRightAnchor).isActive = true
    }
    
    func addOffer(url: URL) {
        let wrapperView = UIView()
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        let bannerImage = UIImageView()
        bannerImage.translatesAutoresizingMaskIntoConstraints = false
        bannerImage.backgroundColor = .white
        bannerImage.isAccessibilityElement = true
        bannerImage.accessibilityIdentifier = AccessibilityCoachmark.managerCoachmarkBannerImageView.rawValue
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(offerPressed))
        wrapperView.addGestureRecognizer(tapGesture)
        bannerImage.embedInto(container: wrapperView)
        dialogStackView.addArrangedSubview(wrapperView)
        bannerImage.setImage(url: url.absoluteString, placeholder: bannerImage.image, options: []) { [weak self] image in
            guard let image = image else {
                return
            }
            guard let self = self else { return }
            self.bannerImageSetup(bannerImage, image: image)
        }
    }
    
    func bannerImageSetup(_ bannerImage: UIImageView, image: UIImage) {
        let width = image.size.width
        let height = image.size.height
        bannerImage.widthAnchor.constraint(equalTo: bannerImage.heightAnchor,
                                           multiplier: width/height).isActive = true
        self.dialogStackViewHeight?.isActive = false
        let stackHeight = self.dialogView.heightAnchor.constraint(
            equalTo: self.dialogStackView.heightAnchor, multiplier: Constants.multiplierDialogView)
        stackHeight.priority = .defaultLow
        stackHeight.isActive = true
        self.dialogStackViewHeight = stackHeight
        self.setNeedsLayout()
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
