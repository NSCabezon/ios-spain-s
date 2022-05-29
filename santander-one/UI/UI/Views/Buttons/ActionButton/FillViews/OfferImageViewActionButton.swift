import UIKit
import CoreFoundationLib

final class OfferImageViewActionButton: UIView {
    private var view: UIView!
    @IBOutlet private weak var offerImageView: UIImageView!
    @IBOutlet private weak var dragIcon: UIImageView!
    
    private var style: ActionButtonStyle = ActionButtonStyle.defaultStyleWithGrayBorder
    
    init(viewModel: OfferImageViewActionButtonViewModel) {
        super.init(frame: .zero)
        self.setupView()
        self.setViewModel(viewModel)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
}

// MARK: - Private extension
extension OfferImageViewActionButton {
    private func setupView() {
        self.xibSetup()
        self.applyEnabledStyle()
        self.setDragIcon()
        self.setAppearance(withStyle: self.style)
    }

    private func xibSetup() {
        self.backgroundColor = .clear
        self.view = loadViewFromNib()
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.view)
        self.view?.fullFit()
    }

    private func loadViewFromNib() -> UIView {
        let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
    
    private func setViewModel(_ viewModel: OfferImageViewActionButtonViewModel) {
        switch viewModel.image {
        case .image(let image):
            offerImageView.image = image
        case .imageURL(let url):
            offerImageView.loadImage(urlString: url)
        case .none:
            break
        }
        setAccessibilityIdentifier(identifier: viewModel.identifier)
    }
    
    private func setDragIcon() {
        self.dragIcon.image = Assets.image(named: "icnDrag")
        self.dragIcon.isHidden = true
    }
    
    private func setAccessibilityIdentifier(identifier: String? = nil) {
        self.offerImageView.accessibilityIdentifier = identifier
    }
}

// MARK: - ActionButtonFillViewProtocol
extension OfferImageViewActionButton: ActionButtonFillViewProtocol {
    func setAppearance(withStyle style: ActionButtonStyle) {
        self.style = style
        self.view.backgroundColor = .clear
        self.offerImageView.layer.cornerRadius = 5
    }
    
    func setDragIconVisibility(isHidden: Bool) {
        self.dragIcon.isHidden = isHidden
    }
    
    func applyDisabledStyle() {}
    func applyEnabledStyle() {}
}
