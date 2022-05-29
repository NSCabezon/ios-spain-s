import CoreFoundationLib
import Foundation
import UI

protocol AdobeTargetOfferViewDelegate: AnyObject {
    func didSelectedAdobeTargetBanner(_ viewModel: AdobeTargetOfferViewModel)
}

final class AdobeTargetOfferView: XibView {
    @IBOutlet private var offerImageView: UIImageView!
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var bigofferButton: UIButton!
    var viewModel: AdobeTargetOfferViewModel?
    private weak var delegate: AdobeTargetOfferViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func setViewModel(_ viewModel: AdobeTargetOfferViewModel, delegate: AdobeTargetOfferViewDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
        self.setImageWithUrl(viewModel.imageURL, on: self.offerImageView)
        self.setAccessibilityIdentifiers()
    }

    @IBAction func didSelectedBanner(_ sender: Any) {
        guard let viewModel = self.viewModel else { return }
        self.delegate?.didSelectedAdobeTargetBanner(viewModel)
    }

    func setAccessibilityIdentifiers() {
        self.containerView.accessibilityIdentifier = AccessibilityFinancingAdobeTargetOffer.financingViewAdobeTarget
    }
}

private extension AdobeTargetOfferView {
    func setupView() {
        backgroundColor = .clear
    }
    
    func setImageWithUrl(_ url: String?, on imageView: UIImageView) {
        guard let urlUnwrapped = url else { return }
        imageView.loadImage(urlString: urlUnwrapped) { [weak self] in
            guard let image = imageView.image else { return }
            let ratioWidth = Double(image.size.width)
            let ratioHeight = Double(image.size.height)
            let ratio = ratioHeight / ratioWidth
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: CGFloat(ratio)).isActive = true
        }
    }
}
