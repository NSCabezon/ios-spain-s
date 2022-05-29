import CoreFoundationLib
import UIKit
import UI

public protocol OneInputSpecialIBANDelegate: AnyObject {
    func didChangeIBAN(_ text: String?)
    func didEndEditing()
}

public final class OneInputSpecialIBAN: XibView {
    @IBOutlet private weak var oneLabel: OneLabelView!
    @IBOutlet private weak var textField: OneIBANTextField!
    @IBOutlet private weak var bottomStackView: UIStackView!
    @IBOutlet private weak var infoMessageContainerView: UIView!
    @IBOutlet private weak var validableImageContainer: UIView!
    @IBOutlet private weak var validableImageView: UIImageView!
    @IBOutlet private weak var extraMessageLabel: UILabel!
    @IBOutlet private weak var bankImageView: UIImageView!
    @IBOutlet private weak var pasteMessageContainerView: UIView!
    @IBOutlet private weak var topDashedSeparator: DashedLineView!
    @IBOutlet private weak var pasteAlertImageViewContainer: UIView!
    @IBOutlet private weak var pasteAlertImageView: UIImageView!
    @IBOutlet private weak var pasteAlertLabel: UILabel!
    @IBOutlet private weak var bottomDashedSeparator: DashedLineView!
    
    private var didTapToolTip: (() -> Void)?
    private var didTapCountryButton: (() -> Void)?
    public weak var delegate: OneInputSpecialIBANDelegate?
    
    public init(viewModel: OneInputSpecialIBANViewModel) {
        super.init(frame: .zero)
        self.setup()
        self.set(viewModel)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    public func set(_ viewModel: OneInputSpecialIBANViewModel) {
        if let bankingUtils = viewModel.bankingUtils {
            self.textField.setBankingUtils(bankingUtils)
        }
        if let flagImageUrl = viewModel.flagImageUrl {
            self.textField.setFlagImage(url: flagImageUrl)
        }
        self.textField.set(
            viewModel: OneIBANTextFieldViewModel(
                style: viewModel.status,
                filledIban: viewModel.ibanString,
                delegate: self,
                pasteCompletion: didPaste
            )
        )
        self.setupOneLabelViewModel(didTapTooltip: viewModel.didTapTooltip,
                                    didTapCountryButton: viewModel.didTapCountryButton)
        self.setValidableType(with: viewModel.validableType)
    }

    public func setAccessibilitySuffix(_ suffix: String) {
        self.setAccessibilityIdentifiers(suffix)
    }

    public func getIBAN() -> String? {
        return self.textField.getIBAN()
    }
    
    public func setInputText(_ iban: String?) {
        self.textField.setIBAN(iban)
    }
}

private extension OneInputSpecialIBAN {
    func setup() {
        self.backgroundColor = .clear
        self.validableImageContainer.backgroundColor = .clear
        self.setupOneLabelViewModel()
        self.infoMessageContainerView.isHidden = true
        self.extraMessageLabel.isHidden = true
        self.bankImageView.isHidden = true
        self.pasteAlertImageViewContainer.layer.cornerRadius = 48 / 2
        self.pasteAlertImageViewContainer.backgroundColor = .onePaleYellow
        self.pasteAlertLabel.font = .typography(fontName: .oneB300Regular)
        self.pasteAlertLabel.textColor = .oneLisboaGray
        self.pasteAlertLabel.configureText(withKey: "sendMoney_label_helperPastedAccount")
        self.pasteAlertImageView.image = Assets.image(named: "oneIcnHelper")
        self.pasteMessageContainerView.isHidden = true
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
        self.setAccessibilityIdentifiers()
    }
    
    func setupOneLabelViewModel(didTapTooltip: (() -> Void)? = nil,
                                didTapCountryButton: (() -> Void)? = nil) {
        self.didTapToolTip = didTapTooltip
        self.didTapCountryButton = didTapCountryButton
        self.oneLabel.setupViewModel(
            OneLabelViewModel(
                type: .helperAndAction,
                mainTextKey: localized("sendMoney_label_iban"),
                actionTextKey: localized("sendMoney_button_changeCountry"),
                helperAction: self.didTapToolTip,
                action: self.didTapCountryButton,
                accessibilitySuffix: "_iban")
            )
    }
    
    func didPaste() {
        self.pasteMessageContainerView.isHidden = false
        if UIAccessibility.isVoiceOverRunning {
            self.endEditing(true)
            UIAccessibility.post(notification: .layoutChanged, argument: self.pasteAlertLabel)
        }
        self.updateDashedSeparators()
    }
    
    func setValidableType(with validableType: OneInputSpecialIBANViewModel.ValidableType?) {
        guard let validableType = validableType else { return }
        switch validableType {
        case .alert(let errorMessageKey):
            self.configureValidationForAlert(errorMessageKey)
        case .validatedBank(let bankName, let bankUrl):
            self.configureValidationForBank(bankName, bankUrl)
        case .validatedCustom(let titleKey, let imageKey):
            self.configureValidationForCustom(titleKey, imageKey)
        case .empty:
            self.infoMessageContainerView.isHidden = true
            return
        }
        UIAccessibility.post(notification: .layoutChanged, argument: self.extraMessageLabel)
    }
    
    func configureValidationForAlert(_ errorMessageKey: String) {
        self.validableImageView.image = Assets.image(named: "oneIcnAlert")
        self.validableImageView.isHidden = false
        self.extraMessageLabel.configureText(withKey: errorMessageKey)
        self.extraMessageLabel.font = .typography(fontName: .oneB300Regular)
        self.extraMessageLabel.textColor = .oneSantanderRed
        self.extraMessageLabel.isHidden = false
        self.bankImageView.isHidden = true
        self.infoMessageContainerView.isHidden = false
    }
    
    func configureValidationForBank(_ bankName: String, _ bankUrl: String?) {
        self.validableImageView.image = Assets.image(named: "oneIcnCheckOthers")
        self.validableImageView.isHidden = false
        self.extraMessageLabel.text = bankName
        self.extraMessageLabel.font = .typography(fontName: .oneB300Bold)
        self.extraMessageLabel.textColor = .oneLisboaGray
        self.extraMessageLabel.isHidden = false
        if let bankUrl = bankUrl {
            self.bankImageView.loadImage(urlString: bankUrl)
        }
        self.bankImageView.isHidden = bankUrl == nil
        self.infoMessageContainerView.isHidden = false
    }
    
    func configureValidationForCustom(_ titleKey: String, _ imageKey: String) {
        self.validableImageView.image = Assets.image(named: "oneIcnCheckOthers")
        self.validableImageView.isHidden = false
        self.extraMessageLabel.configureText(withKey: titleKey)
        self.extraMessageLabel.font = .typography(fontName: .oneB300Bold)
        self.extraMessageLabel.textColor = .oneLisboaGray
        self.extraMessageLabel.isHidden = false
        self.bankImageView.image = Assets.image(named: imageKey)
        self.bankImageView.isHidden = false
        self.infoMessageContainerView.isHidden = false
    }
    
    func updateDashedSeparators() {
        self.topDashedSeparator.strokeColor = .mediumSkyGray
        self.bottomDashedSeparator.strokeColor = .mediumSkyGray
    }
    
    func setAccessibilityIdentifiers(_ suffix: String? = nil) {
        self.oneLabel.setAccessibilitySuffix("_iban" + (suffix ?? ""))
        self.view?.accessibilityIdentifier = AccessibilityOneComponents.oneInputIBANView + (suffix ?? "")
        self.validableImageView.accessibilityIdentifier = AccessibilityOneComponents.oneInputIBANValidationIcn + (suffix ?? "")
        self.extraMessageLabel.accessibilityIdentifier = AccessibilityOneComponents.oneInputIBANValidationText + (suffix ?? "")
        self.bankImageView.accessibilityIdentifier = AccessibilityOneComponents.oneInputIBANValidationBankLogo + (suffix ?? "")
        self.pasteAlertImageView.accessibilityIdentifier = AccessibilityOneComponents.oneInputIBANPastedValidationIcn + (suffix ?? "")
        self.pasteAlertLabel.accessibilityIdentifier = AccessibilityOneComponents.oneInputIBANPastedValidationText + (suffix ?? "")
    }
    
    func setAccessibilityInfo() {
        self.isAccessibilityElement = false
        self.oneLabel.setAccessibilityLabel(accessibilityLabel: localized("voiceover_title_enterIban").text)
        self.textField.accessibilityLabel = localized("voiceover_hint_enterIban", [.init(.value, self.textField.getCountryCode()), .init(.value, "")]).text
    }
}

extension OneInputSpecialIBAN: OneIBANTextFieldDelegate {
    public func didEndEditing() {
        self.delegate?.didEndEditing()
    }
    
    public func didBeginEditing() {
        self.set(OneInputSpecialIBANViewModel(
            validableType: .empty,
            didTapTooltip: self.didTapToolTip,
            didTapCountryButton: self.didTapCountryButton
        ))
    }
    
    public func didChangeIBAN(_ text: String?) {
        self.delegate?.didChangeIBAN(text)
    }
}

extension OneInputSpecialIBAN: AccessibilityCapable {}
