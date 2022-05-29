import CoreFoundationLib
import UIKit

public protocol CheckTextLinkViewDelegate: AnyObject {
    func didTouchCheckBox(isSelected: Bool)
    func didTouchLink()
}

public struct CheckTextLinkViewModel {
    public var title: LocalizedStylableText
    public var accessibilityId: String
    public var isSelected: Bool = false
    public var isDeselectingAllowed: Bool = true

    public init(title: LocalizedStylableText, accessibilityId: String, isSelected: Bool, isDeselectingAllowed: Bool) {
        self.title = title
        self.accessibilityId = accessibilityId
        self.isSelected = isSelected
        self.isDeselectingAllowed = isDeselectingAllowed
    }

    static var empty: CheckTextLinkViewModel {
        return CheckTextLinkViewModel(title: LocalizedStylableText(text: "", styles: nil), accessibilityId: "", isSelected: false, isDeselectingAllowed: false)
    }
}

public final class CheckTextLinkView: XibView {
    @IBOutlet private var selectedIndicator: UIButton!
    @IBOutlet private var labelTitle: UILabel!
    @IBOutlet private var containerViewWidth: NSLayoutConstraint!
    @IBOutlet private var containerViewHeight: NSLayoutConstraint!
    @IBOutlet private var viewShadow: UIView!
    @IBOutlet private var viewShadowTop: UIView!
    @IBOutlet private var viewShadowBottom: UIView!

    public var viewModel: CheckTextLinkViewModel
    public weak var delegate: CheckTextLinkViewDelegate?
    private var hasShadow = false

    override public init(frame: CGRect) {
        self.viewModel = CheckTextLinkViewModel.empty
        super.init(frame: frame)
        self.setupView()
    }

    public required init?(coder: NSCoder) {
        self.viewModel = CheckTextLinkViewModel.empty
        super.init(coder: coder)
        self.setupView()
    }

    // MARK: - Public methods

    public func setup(title: LocalizedStylableText, accessibilityId: String, isSelected: Bool, isDeselectingAllowed: Bool, delegate: CheckTextLinkViewDelegate, hasShadow: Bool) {
        self.delegate = delegate
        self.viewModel = CheckTextLinkViewModel(title: title, accessibilityId: accessibilityId, isSelected: isSelected, isDeselectingAllowed: isDeselectingAllowed)
        self.hasShadow = hasShadow
        self.refreshViewModelData()
    }

    public func setup(withViewModel viewModel: CheckTextLinkViewModel) {
        self.viewModel = viewModel
        self.refreshViewModelData()
    }

    public func setCheckBoxEnabled(_ enabled: Bool) {
        self.viewModel.isSelected = enabled
        self.refreshViewModelData()
    }

    func refreshViewModelData() {
        self.labelTitle.text = nil
        self.selectedIndicator.isSelected = viewModel.isSelected
        self.containerViewWidth.constant = super.view?.frame.width ?? 0
        self.labelTitle.configureText(withLocalizedString: localized(self.viewModel.title.text), andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 14)))
        self.labelTitle.sizeToFit()
        self.containerViewHeight.constant = max(self.labelTitle.frame.height, 28) + 40
        self.layoutIfNeeded()
        setAccessibility()
        setShadow()
    }

    @IBAction func didTapCheckButton(_ sender: UIButton) {
        if self.viewModel.isDeselectingAllowed {
            self.viewModel.isSelected.toggle()
            self.delegate?.didTouchCheckBox(isSelected: self.viewModel.isSelected)
        } else if !self.viewModel.isSelected {
            self.viewModel.isSelected = true
            self.delegate?.didTouchCheckBox(isSelected: self.viewModel.isSelected)
        }
        self.selectedIndicator.isSelected = self.viewModel.isSelected
    }

    @objc func didTapLink() {
        self.delegate?.didTouchLink()
    }
}

private extension CheckTextLinkView {
    func setupView() {
        self.labelTitle.setSantanderTextFont(type: .regular, size: 14, color: .brownGray)
        self.labelTitle.text = nil
        self.labelTitle.isUserInteractionEnabled = true
        self.labelTitle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapLink)))
        self.viewShadow.isHidden = true
    }

    func setAccessibility() {
        self.accessibilityIdentifier = self.viewModel.accessibilityId
        self.selectedIndicator.accessibilityIdentifier = AccesibilityCheckTextLinkView.check
        self.labelTitle.accessibilityIdentifier = self.viewModel.title.text
    }

    func setShadow() {
        self.viewShadow.isHidden = !hasShadow
        if hasShadow, viewShadowTop.layer.shadowOpacity == 0 {
            viewShadowTop.addShadow(offset: CGSize(width: 0, height: 1), color: .black, opacity: 0.35, radius: 2)
            viewShadowBottom.addShadow(offset: CGSize(width: 0, height: -1), color: .black, opacity: 0.35, radius: 2)
        }
    }
}
