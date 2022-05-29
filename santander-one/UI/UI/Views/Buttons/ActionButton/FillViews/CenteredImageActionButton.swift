import UIKit
import CoreFoundationLib

final class CenteredImageActionButton: UIView {
    private var view: UIView!
    @IBOutlet private weak var imageIcon: UIImageView!
    @IBOutlet private weak var imageIconWidth: NSLayoutConstraint!
    @IBOutlet private weak var imageIconHeight: NSLayoutConstraint!
    @IBOutlet private weak var dragIcon: UIImageView!
    
    private var style: ActionButtonStyle = ActionButtonStyle.defaultStyleWithGrayBorder
    
    init(viewModel: CenteredImageActionButtonViewModel) {
        super.init(frame: .zero)
        self.setupView()
        setViewModel(viewModel)
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
extension CenteredImageActionButton {
    private func setupView() {
        self.xibSetup()
        self.setDragIcon()
        self.setAppearance(withStyle: self.style)
    }
    
    private func xibSetup() {
        self.backgroundColor = .clear
        self.view = loadViewFromNib()
        self.view.frame = bounds
        self.view.backgroundColor = .clear
        self.view.translatesAutoresizingMaskIntoConstraints = true
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view)
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
    
    private func setViewModel(_ viewModel: CenteredImageActionButtonViewModel) {
        setImageIcon(viewModel.imageKey, viewModel.renderingMode)
        imageIcon.accessibilityIdentifier = viewModel.imageAccessibilityIdentifier
    }
    
    private func setImageIcon(_ imageKey: String, _ renderingMode: UIImage.RenderingMode) {
        let image = Assets.image(named: imageKey)
        imageIcon.image = image?.withRenderingMode(renderingMode)
    }
    
    private func setDragIcon() {
        self.dragIcon.image = Assets.image(named: "icnDrag")
        self.dragIcon.isHidden = true
    }
}

// MARK: - ActionButtonFillViewProtocol
extension CenteredImageActionButton: ActionButtonFillViewProtocol {
    func setAppearance(withStyle style: ActionButtonStyle) {
        self.style = style
        self.imageIcon.tintColor = style.imageTintColor
        if let imageIconSize = style.imageIconSize {
            self.imageIconWidth.constant = imageIconSize.width
            self.imageIconHeight.constant = imageIconSize.height
        }
    }
    
    func setDragIconVisibility(isHidden: Bool) {
        self.dragIcon.isHidden = isHidden
    }
    
    func applyDisabledStyle() {}
    func applyEnabledStyle() {}
}
