import CoreFoundationLib
import UIKit

public protocol RadioTooltipItemViewDelegate: class {
    func radioItemViewSelected(_ view: RadioTooltipItemView, viewModel: RadioTooltipItemViewModel)
}

public struct RadioTooltipItemViewModel {
    public var title: String
    public var tooltipInfo: LocalizedStylableText
    public var accessibilityId: String
    public var isSelected: Bool = false
    public var isDeselectingAllowed: Bool = true

    public init(title: String, tooltipInfo: LocalizedStylableText, accessibilityId: String, isSelected: Bool, isDeselectingAllowed: Bool) {
        self.title = title
        self.tooltipInfo = tooltipInfo
        self.accessibilityId = accessibilityId
        self.isSelected = isSelected
        self.isDeselectingAllowed = isDeselectingAllowed
    }

    static var empty: RadioTooltipItemViewModel {
        return RadioTooltipItemViewModel(title: "", tooltipInfo: LocalizedStylableText(text: "", styles: nil), accessibilityId: "", isSelected: false, isDeselectingAllowed: false)
    }
}

public final class RadioTooltipItemView: XibView {
    @IBOutlet private var selectedIndicator: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var tooltip: ToolTipButton!

    public var viewModel: RadioTooltipItemViewModel {
        didSet {
            self.refreshViewModelData()
        }
    }

    public weak var delegate: RadioTooltipItemViewDelegate?

    override public init(frame: CGRect) {
        self.viewModel = RadioTooltipItemViewModel.empty
        super.init(frame: frame)
        self.setupView()
    }

    public required init?(coder: NSCoder) {
        self.viewModel = RadioTooltipItemViewModel.empty
        super.init(coder: coder)
        self.setupView()
    }

    // MARK: - Public methods

    public func setup(with viewModel: RadioTooltipItemViewModel) {
        self.viewModel = viewModel
    }

    func refreshViewModelData() {
        self.titleLabel.configureText(withKey: self.viewModel.title)
        self.tooltip.setup(size: self.tooltip.frame.size.width,
                           imageEdgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
                           imageContentMode: .scaleAspectFit,
                           withAction: toolTipAction)
        self.tooltip.tintColor = .santanderRed
        self.tooltip.accessibilityIdentifier = AccessibilityTransferSelector.btnInfo.rawValue
        if self.viewModel.isSelected {
            self.setupSelectedStyle()
        } else {
            self.setupUnSelectedStyle()
        }
        setAccessibility()
    }

    @objc func didSelectView() {
        if self.viewModel.isDeselectingAllowed {
            self.viewModel.isSelected.toggle()
        } else if !self.viewModel.isSelected {
            self.viewModel.isSelected = true
        }
        if self.viewModel.isSelected {
            setupSelectedStyle()
        } else {
            setupUnSelectedStyle()
        }
        self.delegate?.radioItemViewSelected(self, viewModel: self.viewModel)
    }
}

private extension RadioTooltipItemView {
    func toolTipAction(_ sender: UIView) {
        let bubble = BubbleLabelView.startWith(
            associated: self.tooltip.getInfoImageView() ?? self.tooltip,
            text: self.viewModel.tooltipInfo.text,
            position: .bottom)
    }

    func setupSelectedStyle() {
        self.selectedIndicator.image = Assets.image(named: "icnRadioButtonSelected")
    }

    func setupUnSelectedStyle() {
        self.selectedIndicator.image = Assets.image(named: "icnRadioButtonUnSelected")
    }

    func setupView() {
        self.titleLabel.setSantanderTextFont(type: .bold, size: 15, color: .lisboaGray)
        self.titleLabel.text = nil
        self.setupUnSelectedStyle()
        self.view?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didSelectView)))
    }

    func setAccessibilityIdentifier(_ identifier: String) {
        self.titleLabel.accessibilityIdentifier = identifier + "_label_title"
    }

    func setAccessibility() {
        self.tooltip.accessibilityLabel = "info"
        self.titleLabel.accessibilityLabel = "\(self.titleLabel.text ?? "")"
        self.selectedIndicator.accessibilityIdentifier = AccessibilityRadioTooltipView.check
        self.titleLabel.accessibilityIdentifier = viewModel.accessibilityId
        self.tooltip.accessibilityIdentifier = AccessibilityRadioTooltipView.tooltipButton
    }
}
