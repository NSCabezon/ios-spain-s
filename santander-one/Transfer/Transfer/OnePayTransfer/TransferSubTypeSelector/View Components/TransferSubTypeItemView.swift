import UIKit
import UI
import CoreFoundationLib

protocol TransferSubTypeItemViewDelegate: AnyObject {
    func transferSubTypeItemViewSelected(_ view: TransferSubTypeItemView, viewModel: TransferSubTypeItemViewModel)
}

final class TransferSubTypeItemView: XibView {
    @IBOutlet weak private var selectedIndicator: UIImageView!
    @IBOutlet weak private var subtypeTitleLabel: UILabel!
    @IBOutlet weak private var subtypeDescriptionLabel: UILabel!
    @IBOutlet weak private var commissionLabel: UILabel!
    @IBOutlet weak private var tooltip: ToolTipButton!
    @IBOutlet weak private var separator: UIView!
    @IBOutlet weak var commissionDescriptionLabel: UILabel!
    private(set) var viewModel: TransferSubTypeItemViewModel
    weak var delegate: TransferSubTypeItemViewDelegate?

    init(frame: CGRect, viewModel: TransferSubTypeItemViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        self.setupView()
        self.setup(with: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Public methods

    func setup(with viewModel: TransferSubTypeItemViewModel) {
        self.viewModel = viewModel
        self.subtypeTitleLabel.text = localized(viewModel.type)
        if !viewModel.commission.isEmpty {
            self.commissionLabel.text = viewModel.commission
            self.commissionDescriptionLabel.isHidden = true
            self.commissionLabel.isHidden = false
        } else {
            self.commissionLabel.isHidden = true
            self.commissionDescriptionLabel.isHidden = false
            self.commissionDescriptionLabel.configureText(withLocalizedString: localized(viewModel.commissionDescription))
        }
        self.tooltip.setup(size: tooltip.frame.size.width,
                           imageEdgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
                           imageContentMode: .scaleAspectFit,
                           withAction: toolTipAction)
        self.tooltip.tintColor = .santanderRed
        if viewModel.isSelected {
            self.setupSelectedStyle()
        } else {
            self.setupUnSelectedStyle()
        }
        self.subtypeDescriptionLabel.configureText(withKey: viewModel.description)
        self.setAccessibilityIdentifier(viewModel.typeAccessibilityId)
        setAccessibility()
    }

    func hideSeparatorView() {
        self.separator.isHidden = true
    }

    // MARK: - Objc methods

    @objc func didSelectView() {
        self.delegate?.transferSubTypeItemViewSelected(self, viewModel: self.viewModel)
    }
}

private extension TransferSubTypeItemView {

    func toolTipAction(_ sender: UIView) {
        BubbleLabelView.startWith(associated: self.tooltip.getInfoImageView() ?? self.tooltip, localizedStyleText: self.viewModel.info, position: .bottom)
    }

    func setupSelectedStyle() {
        self.selectedIndicator.image = Assets.image(named: "icnRadioButtonSelected")
        self.selectedIndicator.accessibilityIdentifier = "icnRadioButtonSelected" + "_" + viewModel.description
        self.subtypeDescriptionLabel.setSantanderTextFont(type: .regular, size: 15, color: .darkTorquoise)
    }

    func setupUnSelectedStyle() {
        self.selectedIndicator.image = Assets.image(named: "icnRadioButtonUnSelected")
        self.selectedIndicator.accessibilityIdentifier = "icnRadioButtonUnSelected" + "_" + viewModel.description
        self.subtypeDescriptionLabel.setSantanderTextFont(type: .regular, size: 15, color: .grafite)
    }

    func setupView() {
        self.commissionDescriptionLabel.setSantanderTextFont(type: .regular, size: 12, color: .grafite)
        self.commissionDescriptionLabel.text = nil
        self.subtypeTitleLabel.setSantanderTextFont(type: .bold, size: 15, color: .lisboaGray)
        self.subtypeTitleLabel.text = nil
        self.subtypeDescriptionLabel.text = nil
        self.commissionLabel.setSantanderTextFont(type: .bold, size: 14, color: .lisboaGray)
        self.commissionLabel.text = nil
        self.separator.backgroundColor = .mediumSkyGray
        self.setupUnSelectedStyle()
        self.view?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectView)))
    }

    func setAccessibilityIdentifier(_ identifier: String) {
        self.tooltip.accessibilityIdentifier = AccessibilityTransferSelector.btnInfo.rawValue + "_" + identifier
        subtypeTitleLabel.accessibilityIdentifier = identifier + "_label_title"
        subtypeDescriptionLabel.accessibilityIdentifier = identifier + "_label_description"
        commissionLabel.accessibilityIdentifier = identifier + "_label_commissionAmount"
        commissionDescriptionLabel.accessibilityIdentifier = identifier + "_label_commissionDescription"
    }

    func setAccessibility() {
        tooltip.accessibilityLabel = "info"
        subtypeTitleLabel.accessibilityLabel = "\(subtypeTitleLabel.text ?? ""). \(subtypeDescriptionLabel.text ?? ""). \(commissionLabel.text ?? "")"
        subtypeDescriptionLabel.accessibilityElementsHidden = true
        commissionLabel.accessibilityElementsHidden = true
    }
}
