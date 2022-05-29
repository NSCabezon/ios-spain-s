
import UIKit
import OpenCombine
import CoreDomain
import UI

final class BannerView: UIView {
    var tapSubject = PassthroughSubject<OfferRepresentable, Never>()
    private var model: OfferBanner?
    private enum Constants {
        static let opacity: Float = 0.9
        static let radius: CGFloat = 5.0
        static let containerLeadingConstraint = 32.0
        static let containerTrailingConstraint = -23.0
        static let imageViewLeadingConstraint = 10.0
        static let titleLabelLeadingConstraint = -8.0
        static let imageViewAnchorConstraint = 13.0
        static let titleLabelTrailingConstraint = 4.0
        static let labelFontSize = 18.0
    }

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleToFill
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    private lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.clipsToBounds = true
        containerView.backgroundColor = .clear
        return containerView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .santander(family: .text, type: .regular, size: Constants.labelFontSize)
        label.textColor = .lisboaGray
        return label
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateViewLayout() {
        setNeedsLayout()
        layoutIfNeeded()
        layoutSubviews()
    }

    func setModel(_ model: OfferBanner?) {
        self.model = model
        containerViewLayout()
        if let modelImage = model?.image {
            formatBanner()
            self.containerView.addSubview(imageView)
            self.imageView.setImage(modelImage)
            self.setViewWithImage()
        } else {
            formatNotBanner()
            containerView.addSubview(titleLabel)
            containerView.addSubview(imageView)
            setViewFromOption()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let model = self.model else { return }
        self.tapSubject.send(model)
    }
}

private extension BannerView {
    func formatNotBanner() {
        containerView.drawBorder(color: .mediumSkyGray)
        imageView.image = Assets.image(named: model?.notBannerIcon ?? "")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .botonRedLight
        titleLabel.configureText(withKey: model?.notBannerTitle ?? "")
    }
    
    func formatBanner() {
        imageView.contentMode = .scaleAspectFit
        imageView.layoutIfNeeded()
    }
    
    func containerViewLayout() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.containerLeadingConstraint),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: Constants.containerTrailingConstraint)
        ])
    }
    
    func setupViews() {
        self.addSubview(containerView)
    }
    
    func setViewWithImage() {
        guard let image = self.imageView.image else { return }
        self.updateViewLayout()
        let imageViewWidth = frame.width
        let originalHeight = Float(image.size.height)
        let originalWidth = Float(image.size.width)
        let newHeight = (originalHeight / originalWidth) * Float(imageViewWidth)
        self.heightAnchor.constraint(equalToConstant: CGFloat(newHeight)).isActive = true
        imageView.fullFit()
        self.updateViewLayout()
    }
    
    func setViewFromOption() {
        updateViewLayout()
        imageView.widthAnchor.constraint(equalToConstant: Constants.containerLeadingConstraint).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: Constants.containerLeadingConstraint).isActive = true
        imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.imageViewLeadingConstraint).isActive = true
        imageView.trailingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: Constants.titleLabelLeadingConstraint).isActive = true
        imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constants.imageViewAnchorConstraint).isActive = true
        imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constants.imageViewAnchorConstraint).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: Constants.titleLabelTrailingConstraint).isActive = true
        updateViewLayout()
    }
}
