//
//  SendMoneyTransferTypeCostView.swift
//  Santander
//
//  Created by Angel Abad Perez on 25/11/21.
//

import CoreFoundationLib
import CoreDomain
import UI
import UIOneComponents

protocol SendMoneyTransferTypeCostViewDelegate: AnyObject {
    func didTapSelectOptionButton(at index: Int)
}

final class SendMoneyTransferTypeCostView: UIView {
    private enum Constants {
        static let zeroFormatted: String = Decimal.zero.getSmartFormattedValue(with: 2)
        enum SelectOptionButton {
            static let textKey: String = "sendMoney_button_selectOption"
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var selectOptionButton: OneFloatingButton!
    
    weak var delegate: SendMoneyTransferTypeCostViewDelegate?
    private var view: UIView?
    private var index: Int = -1
    private var viewModel: SendMoneyTransferTypeCostViewModel?
    
    convenience init(viewModel: SendMoneyTransferTypeCostViewModel) {
        self.init()
        self.setLabelsText(viewModel)
        self.viewModel = viewModel
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setViewModel(_ viewModel: SendMoneyTransferTypeCostViewModel) {
        self.setLabelsText(viewModel)
        self.viewModel = viewModel
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
    }
    
    func setIndex(index: Int) {
        self.index = index
    }
}

private extension SendMoneyTransferTypeCostView {
    func setupView() {
        self.xibSetup()
        self.configureLabels()
        self.configureButton()
    }
    
    func xibSetup() {
        self.view = self.loadViewFromNib()
        self.addSubview(self.view ?? UIView())
        self.view?.fullFit()
    }
    
    func loadViewFromNib() -> UIView {
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: Bundle.main)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
    
    func configureLabels() {
        self.titleLabel.font = .typography(fontName: .oneH300Bold)
        self.titleLabel.textColor = .oneLisboaGray
        self.subtitleLabel.applyStyle(LabelStylist(textColor: UIColor.oneLisboaGray,
                                                   font: .typography(fontName: .oneB400Regular),
                                                   textAlignment: .center))
    }
    
    func configureButton() {
        self.selectOptionButton.isEnabled = true
        self.selectOptionButton.configureWith(type: .primary,
                                              size: .medium(
                                                OneFloatingButton.ButtonSize.MediumButtonConfig(
                                                    title: localized(Constants.SelectOptionButton.textKey),
                                                    icons: .none,
                                                    fullWidth: false
                                                )
                                              ),
                                              status: .ready)
        self.selectOptionButton.addTarget(self, action: #selector(didTapSelectOptionButton), for: .touchUpInside)
    }
    
    func setLabelsText(_ viewModel: SendMoneyTransferTypeCostViewModel) {
        self.titleLabel.configureText(withKey: viewModel.type.costViewTitle ?? "")
        self.titleLabel.sizeToFit()
        if let instantMaxAmount = viewModel.instantMaxAmount {
            let decorator = AmountRepresentableDecorator(instantMaxAmount, font: .typography(fontName: .oneB400Regular))
            self.subtitleLabel.configureText(withLocalizedString: localized(viewModel.type.costViewSubtitle ?? "",
                                                                            [StringPlaceholder(.value, decorator.formatAsMillionsWithoutDecimals()?.string ?? "")]))
        } else {
            self.subtitleLabel.configureText(withKey: viewModel.type.costViewSubtitle ?? "")
        }
        self.subtitleLabel.sizeToFit()
        self.setNeedsLayout()
        self.layoutIfNeeded()
        self.setAccessibilityIdentifiers(titleKey: viewModel.type.costViewTitle, subtitleKey: viewModel.type.costViewSubtitle)
    }

    func setAccessibilityIdentifiers(titleKey: String?, subtitleKey: String?) {
        self.titleLabel.accessibilityIdentifier = titleKey
        self.subtitleLabel.accessibilityIdentifier = subtitleKey
    }
    
    func setAccessibilityInfo() {
        guard let selectOptionButonLabel = self.viewModel?.type.costViewSelectButton else { return }
        self.selectOptionButton.accessibilityLabel = localized(selectOptionButonLabel)
    }
    
    @objc func didTapSelectOptionButton() {
        self.delegate?.didTapSelectOptionButton(at: self.index)
    }
}

extension SendMoneyTransferTypeCostView: AccessibilityCapable {}
