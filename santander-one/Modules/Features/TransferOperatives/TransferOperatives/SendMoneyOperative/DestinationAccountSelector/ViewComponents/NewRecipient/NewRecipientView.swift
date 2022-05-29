//
//  NewRecipientView.swift
//  TransferOperatives
//
//  Created by José María Jiménez Pérez on 30/9/21.
//

import UI
import UIOneComponents
import CoreFoundationLib
import CoreDomain

protocol NewRecipientViewDelegate: AnyObject {
    func didSelectView(_ view: UIView)
    func didChangeNewRecipientData(_ iban: String, name: String, alias: String)
}

struct NewRecipientViewConfiguration {
    private let dependenciesResolver: DependenciesResolver
    var defaultIbanHelpImageUrl: String = ""
    var ibanHelpImageUrl: String = ""
    
    init(dependenciesResolver: DependenciesResolver, countryCode: String) {
        self.dependenciesResolver = dependenciesResolver
        let appRepository: AppRepositoryProtocol = dependenciesResolver.resolve()
        let language = appRepository.getCurrentLanguage().rawValue
        let localeRequested: String
        guard let baseUrl = self.dependenciesResolver.resolve(for: BaseURLProvider.self).baseURL else { return }
        self.ibanHelpImageUrl = String(format: "%@RWD/helper/images/%@_%@_ibanHelper.png",
                                       baseUrl,
                                       countryCode.lowercased(),
                                       language)
        self.defaultIbanHelpImageUrl = String(format: "%@RWD/helper/images/xx_%@_ibanHelper.png",
                                              baseUrl,
                                              language)
    }
}

final class NewRecipientView: XibView {
    
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var recipientHeaderContainer: UIView!
    @IBOutlet private weak var newRecipentIcn: UIImageView!
    @IBOutlet private weak var newRecipientLabel: UILabel!
    @IBOutlet private weak var rightImageView: UIImageView!
    @IBOutlet private weak var recipientsDetailContainer: UIView!
    @IBOutlet private weak var oneInputSpecialIBAN: OneInputSpecialIBAN!
    @IBOutlet private weak var oneLabel: OneLabelView!
    @IBOutlet private weak var oneInputRegular: OneInputRegularView!
    @IBOutlet private weak var oneCheckboxView: OneCheckboxView!
    @IBOutlet private weak var aliasRecipientContainer: UIView!
    @IBOutlet private weak var aliasOneLabel: OneLabelView!
    @IBOutlet private weak var aliasOneInputRegular: OneInputRegularView!
    
    private var accessibilitySuffix: String = "_newRecipient"
    
    weak var delegate: NewRecipientViewDelegate?
    
    private var dependenciesResolver: DependenciesResolver?
    private var opened: Bool = false {
        didSet {
            self.updateContent()
            self.updateAccessibility()
        }
    }
    private var showIbanHelp: (() -> Void)?
    private var showAliasHelper: ((NewRecipientAliasHelperViewType) -> Void)?
    private var didTapChangeCountry: (() -> Void)?

    private var ibanViewModel: OneInputSpecialIBANViewModel?
    
    init(dependenciesResolver: DependenciesResolver,
         configuration: NewRecipientViewConfiguration,
         showIbanHelp: @escaping () -> Void,
         showAliasHelper: @escaping (NewRecipientAliasHelperViewType) -> Void,
         didTapChangeCountry: (() -> Void)?) {
        super.init(frame: .zero)
        self.dependenciesResolver = dependenciesResolver
        self.showIbanHelp = showIbanHelp
        self.showAliasHelper = showAliasHelper
        self.didTapChangeCountry = didTapChangeCountry
        self.configureViews()
        self.configureGestures()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureViews()
        self.configureGestures()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureViews()
        self.configureGestures()
    }

    func showBankNameAndLogo(_ iban: IBANRepresentable, name: String) {
        self.oneInputRegular.setupTextField(OneInputRegularViewModel(status: .activated, text: name, placeholder: "sendMoney_label_fullName", accessibilitySuffix: AccessibilitySendMoneyDestination.NewRecipientView.recipientSuffix))
        guard var viewModel = self.ibanViewModel else { return }
        viewModel.dependenciesResolver = self.dependenciesResolver
        viewModel.ibanString = iban.ibanPapel
        viewModel.ibanRepresentable = iban
        viewModel.validableType = .validatedBank(bankName: "", bankUrl: viewModel.bankLogoURL)
        self.oneInputSpecialIBAN.set(viewModel)
    }
    
    func showAliasRecipient(saveToFavourite: Bool, alias: String?) {
        self.setFavoriteCheckBox(status: saveToFavourite ? .activated : .inactive)
        self.aliasOneInputRegular.setupTextField(OneInputRegularViewModel(status: .activated,
                                                                          text: alias,
                                                                          placeholder: "sendMoney_label_recipientAlias",
                                                                          accessibilitySuffix: AccessibilitySendMoneyDestination.NewRecipientView.aliasSuffix))
    }
    
    func setInputText(_ iban: String?, name: String?, alias: String?) {
        self.oneInputSpecialIBAN.setInputText(iban)
        self.oneInputRegular.setInputText(name)
        self.aliasOneInputRegular.setInputText(alias)
    }
    
    func setIBANError() {
        guard var viewModel = self.ibanViewModel else { return }
        viewModel.status = .error
        viewModel.validableType = .alert(errorMessageKey: "sendMoney_alert_valueIban")
        self.oneInputSpecialIBAN.set(viewModel)
    }
    
    func toggleView(opened: Bool) {
        self.opened = opened
    }
    
    @objc func didTapOnView() {
        self.delegate?.didSelectView(self)
    }
    
    func reloadSpecialIBANForCountry() {
        self.loadSpecialIBANForCountry()
        self.oneInputSpecialIBAN.setInputText(nil)
    }
    
    func resetInputSpecialIBAN() {
        guard var viewModel = self.ibanViewModel,
              let dependenciesResolver = self.dependenciesResolver else {
                  return
              }
        viewModel.validableType = .empty
        let bankingUtils: BankingUtilsProtocol = dependenciesResolver.resolve()
        viewModel.flagImageUrl = self.getCountryFlag(bankingUtils)
        self.oneInputSpecialIBAN.set(viewModel)
    }
    
    func setFavoriteCheckBox(status: OneStatus) {
        self.checkbox.setStatus(status)
        self.updateAliasRecipientContainer()
    }
}

private extension NewRecipientView {
    enum Constants {
        static let relativeURL = "RWD/country/icons/"
        static let fileExtension = ".png"
    }
    
    func configureViews() {
        self.newRecipentIcn.image = Assets.image(named: "icnPlusOne")
        self.newRecipientLabel.font = .typography(fontName: .oneB400Bold)
        self.newRecipientLabel.textColor = .oneLisboaGray
        self.newRecipientLabel.text = localized("sendMoney_label_newRecipient")
        self.rightImageView.image = Assets.image(named: "icnArrowDown")
        self.loadSpecialIBANForCountry()
        self.oneInputSpecialIBAN.delegate = self
        self.oneInputRegular.delegate = self
        self.oneInputRegular.setupTextField(
            OneInputRegularViewModel(status: .activated, placeholder: "sendMoney_label_fullName")
        )
        self.oneInputRegular.maxCounter = 140
        self.oneLabel.setupViewModel(
            OneLabelViewModel(type: .normal, mainTextKey: "sendMoney_label_recipients")
        )
        self.oneCheckboxView.setViewModel(
            OneCheckboxViewModel(status: .inactive, titleKey: "sendMoney_label_checkFavouriteRecipient", accessibilityActivatedLabel: localized("sendMoney_label_checkFavouriteRecipient"), accessibilityNoActivatedLabel: localized("sendMoney_label_checkFavouriteRecipient"))
        )
        self.updateAliasRecipientContainer()
        self.aliasOneLabel.setupViewModel(
            OneLabelViewModel(
                type: .helper,
                mainTextKey: "sendMoney_label_alias",
                helperAction: {
                    self.showAliasHelper?(.aliasInfo)
                })
        )
        self.aliasOneInputRegular.delegate = self
        self.aliasOneInputRegular.setupTextField(
            OneInputRegularViewModel(status: .activated,
                                     placeholder: "sendMoney_label_recipientAlias",
                                     accessibilitySuffix: AccessibilitySendMoneyDestination.NewRecipientView.aliasSuffix)
        )
        self.aliasOneInputRegular.maxCounter = 20
        self.aliasOneInputRegular.regularExpression = try? NSRegularExpression(pattern: "[a-zA-Z0-9ąćęłńóśźżĄĆĘŁŃÓŚŹŻçáéíóúü]+$")
        self.setAccessibilityIdentifiers()
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
    }
    
    func configureGestures() {
        self.recipientHeaderContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOnView)))
    }
    
    func updateContent() {
        let rotation = self.opened ? self.transform.rotated(by: CGFloat.pi) : CGAffineTransform.identity
        self.recipientsDetailContainer.isHidden = !self.opened
        self.updateAliasRecipientContainer()
        self.rightImageView.transform = rotation
        self.updateAccessibilityIdentifiers()
    }

    func setAccessibilityIdentifiers() {
        self.newRecipentIcn.accessibilityIdentifier = AccessibilitySendMoneyDestination.Carousels.NewRecipient.leftIcon
        self.newRecipientLabel.accessibilityIdentifier = AccessibilitySendMoneyDestination.Carousels.NewRecipient.title
        self.oneLabel.setAccessibilitySuffix(AccessibilitySendMoneyDestination.NewRecipientView.recipientSuffix)
        self.oneInputRegular.setAccessibilitySuffix(AccessibilitySendMoneyDestination.NewRecipientView.recipientSuffix)
        self.oneCheckboxView.setAccessibilitySuffix(AccessibilitySendMoneyDestination.NewRecipientView.checkFavouriteRecipientSuffix)
        self.aliasOneLabel.setAccessibilitySuffix(AccessibilitySendMoneyDestination.NewRecipientView.aliasSuffix)
        self.aliasOneInputRegular.setAccessibilitySuffix(AccessibilitySendMoneyDestination.NewRecipientView.aliasSuffix)
    }

    func updateAccessibilityIdentifiers() {
        self.rightImageView.accessibilityIdentifier = self.opened ?
            AccessibilitySendMoneyDestination.Carousels.Common.rightIconUp + self.accessibilitySuffix :
            AccessibilitySendMoneyDestination.Carousels.Common.rightIconDown + self.accessibilitySuffix
    }
    
    func setAccessibilityInfo() {
        self.recipientHeaderContainer.isAccessibilityElement = true
        self.recipientHeaderContainer.accessibilityLabel = localized("voiceover_viewNewRecipient").text
        self.recipientHeaderContainer.accessibilityHint = "Tap twice to open"
        self.oneLabel.setAccessibilityLabel(accessibilityLabel: localized("voiceover_title_enterRecipientName").text)
        self.updateAccessibility()
    }
    
    func updateAccessibility() {
        let tapTwiceTo: String = localized("voiceover_tapTwiceTo")
        let open: String = localized("voiceover_open")
        self.recipientHeaderContainer.accessibilityHint = self.opened ? nil : "\(tapTwiceTo) \(open)"
    }
    
    func loadSpecialIBANForCountry() {
        guard let dependenciesResolver = self.dependenciesResolver else { return }
        let bankingUtils: BankingUtilsProtocol = dependenciesResolver.resolve()
        let flagImageUrl = self.getCountryFlag(bankingUtils)
        self.ibanViewModel = OneInputSpecialIBANViewModel(bankingUtils: bankingUtils,
                                                          status: .activated,
                                                          validableType: nil,
                                                          didTapTooltip: self.showIbanHelp,
                                                          didTapCountryButton: self.didTapChangeCountry,
                                                          flagImageUrl: flagImageUrl)
        guard let viewModel = self.ibanViewModel else { return }
        self.oneInputSpecialIBAN.set(viewModel)
    }
    
    func updateAliasRecipientContainer() {
        self.aliasRecipientContainer.isHidden = !(self.opened && (self.checkbox.status == .activated ? true : false))
    }
    
    func getCountryFlag(_ bankingUtils: BankingUtilsProtocol) -> String? {
        guard let baseUrl = self.dependenciesResolver?.resolve(for: BaseURLProvider.self).baseURL else {
            return nil
        }
        return String(format: "%@%@%@%@",
                      baseUrl,
                      Constants.relativeURL,
                      bankingUtils.countryCode?.lowercased() ?? "",
                      Constants.fileExtension)
    }
}

extension NewRecipientView {
    var checkbox: OneCheckboxView {
        return self.oneCheckboxView
    }
    
    func hideSaveFavourite() {
        self.oneCheckboxView.isHidden = true
        self.aliasRecipientContainer.isHidden = true
    }
}

extension NewRecipientView: OneInputRegularViewDelegate {
    func textDidChange(_ text: String) {
        guard let iban = self.oneInputSpecialIBAN.getIBAN(),
              let name = self.oneInputRegular.getInputText(),
              let alias = self.aliasOneInputRegular.getInputText() else {
            return
        }
        self.delegate?.didChangeNewRecipientData(iban, name: name, alias: alias)
    }
    
    func shouldReturn() {
        return
    }
}

extension NewRecipientView: OneInputSpecialIBANDelegate {
    func didChangeIBAN(_ text: String?) {
        guard let name = self.oneInputRegular.getInputText(),
              let alias = self.aliasOneInputRegular.getInputText(),
              let iban = text else {
            return
        }
        self.delegate?.didChangeNewRecipientData(iban, name: name, alias: alias)
    }
    
    func didEndEditing() {
        UIAccessibility.post(notification: .layoutChanged, argument: self.oneLabel)
    }
}

extension NewRecipientView: AccessibilityCapable {}
