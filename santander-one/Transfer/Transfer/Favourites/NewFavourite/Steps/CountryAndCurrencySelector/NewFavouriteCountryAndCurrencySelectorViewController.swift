//
//  CountryAndCurrencySelectorViewController.swift
//  Transfer
//
//  Created by Luis Escámez Sánchez on 27/5/21.
//

import UIKit
import UI
import Operative
import CoreFoundationLib
import IQKeyboardManagerSwift

protocol NewFavouriteCountryAndCurrencySelectorViewProtocol: OperativeView {
    func setCountryAndCurrencyInfo(_ sepaInfoList: SepaInfoListEntity, countrySelected: SepaCountryInfoEntity, currencySelected: SepaCurrencyInfoEntity)
}

final class NewFavouriteCountryAndCurrencySelectorViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var separatorButtonView: UIView!
    @IBOutlet weak var continueButton: WhiteLisboaButton! {
        didSet {
            self.continueButton.accessibilityIdentifier = AccessibilityTransfers.btnContinue
        }
    }
    @IBOutlet weak var destinationCountryTextField: ActionLisboaTextField! {
        didSet {
            self.destinationCountryTextField.accessibilityIdentifier = AccessibilityTransfers.inputDestinationCountry.rawValue
        }
    }
    @IBOutlet weak var currencyTextField: ActionLisboaTextField! {
        didSet {
            self.currencyTextField.accessibilityIdentifier = AccessibilityTransfers.btnCurrency.rawValue
        }
    }
    
    let keyboardManager: KeyboardManager = KeyboardManager()
    var lisboaErrorViews: [LisboaTextFieldWithErrorView] = []
    private var countrySelected: SepaCountryInfoEntity?
    private var sepaInfoList: SepaInfoListEntity?
    private var currencySelected: SepaCurrencyInfoEntity?
    private var pullOfferCandidates: [PullOfferLocation: OfferEntity] = [:]
    let presenter: NewFavouriteCountryAndCurrencySelectorPresenterProtocol
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: NewFavouriteCountryAndCurrencySelectorPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.viewWillAppear()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
        self.setupView()
    }
}

private extension NewFavouriteCountryAndCurrencySelectorViewController {
    
    func setupView() {
        self.view.backgroundColor = UIColor.white
        self.descriptionLabel.numberOfLines = 0
        self.descriptionLabel.font = .santander(family: .text, type: .regular, size: 18.0)
        self.descriptionLabel.configureText(withKey: "favoriteRecipients_label_savedSelect")
        self.descriptionLabel.textColor = .lisboaGray
        self.separatorButtonView.backgroundColor = .mediumSkyGray
        self.continueButton.setTitle(localized("generic_button_continue"), for: .normal)
        self.continueButton.addSelectorAction(target: self, #selector(didSelectContinue))
        self.setupDestinationTextField()
        self.setupCurrencyTextField()
    }
    
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .titleWithHeader(titleKey: "pt_toolbar_title_createFavorite",
                                    header: .title(key: "share_title_transfers", style: .default))
        )
        builder.build(on: self, with: nil)
    }
    
    @objc func didSelectContinue() {
        self.presenter.didSelectContinue()
    }
    
    func setupDestinationTextField() {
        self.destinationCountryTextField.configure(with: nil, actionViewStyle: .arrow, title: localized("sendMoney_label_destinationCountry"), disabledActions: TextFieldActions.usuallyDisabledActions)
        self.destinationCountryTextField.disableTextFieldEditing()
        self.destinationCountryTextField.addExtraAction { [weak self] in
            self?.comingSoon()
            /* uncomment when the country selection is available
             guard let countrySelected = self?.countrySelected else { return }
             self?.showSearchForOperation(.countries, itemSelected: countrySelected)
             */
        }
    }
    
    func setupCurrencyTextField() {
        self.currencyTextField.configure(with: nil, actionViewStyle: .arrow, title: localized("sendMoney_label_currency"))
        self.currencyTextField.hideArrowStyleImage()
        self.currencyTextField.isUserInteractionEnabled = false    }
    
    func showSearchForOperation(_ operation: SepaSearchOperation, itemSelected: CountryCurrencyItemConformable?) {
        guard
            let sepaInfoList = self.sepaInfoList,
            let itemSelected = itemSelected
        else { return }
        let presenter = CurrencyCountryFinderPresenter(operation: operation, sepaInfoList: sepaInfoList, itemSelected: itemSelected, pullOfferCandidates: self.pullOfferCandidates)
        let countryCurrencyFilterViewController = CurrencyCountryFinderViewController(presenter: presenter)
        countryCurrencyFilterViewController.delegate = self
        presenter.view = countryCurrencyFilterViewController
        countryCurrencyFilterViewController.modalPresentationStyle = .fullScreen
        self.present(countryCurrencyFilterViewController, animated: true, completion: nil)
    }
    
    func updateCountryTextField(_ country: SepaCountryInfoEntity) {
        self.destinationCountryTextField.updateActionLabel(country.code)
        self.destinationCountryTextField.updateData(text: country.name)
    }
    
    func updateCurrencyTextField(_ currency: SepaCurrencyInfoEntity) {
        self.currencyTextField.updateActionLabel(currency.code)
        self.currencyTextField.updateData(text: currency.name)
    }
    
    func comingSoon() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
}

extension NewFavouriteCountryAndCurrencySelectorViewController: NewFavouriteCountryAndCurrencySelectorViewProtocol {
    
    func setCountryAndCurrencyInfo(_ sepaInfoList: SepaInfoListEntity, countrySelected: SepaCountryInfoEntity, currencySelected: SepaCurrencyInfoEntity) {
        self.sepaInfoList = sepaInfoList
        self.countrySelected = countrySelected
        self.currencySelected = currencySelected
        self.updateCountryTextField(countrySelected)
        self.updateCurrencyTextField(currencySelected)
    }
    
    func updateContinueAction(_ enable: Bool) {
        self.continueButton.setIsEnabled(enable)
    }
    
    var operativePresenter: OperativeStepPresenterProtocol {
        return self.presenter
    }
}

extension NewFavouriteCountryAndCurrencySelectorViewController: CurrencyCountryFinderViewControllerDelegate {
    func didSelectCloseBanner(_ offerId: String?) {}
    
    func didSelectBanner() {}
    
    func didSelectCurrency(_ currency: SepaCurrencyInfoEntity) {
        self.currencySelected = currency
        self.updateCurrencyTextField(currency)
    }
    
    func didSelectCountry(_ country: SepaCountryInfoEntity, currency: SepaCurrencyInfoEntity) {
        self.countrySelected = country
        self.updateCountryTextField(country)
        self.presenter.updateCountryAndCurrency(country, currency)
        self.didSelectCurrency(currency)
        self.continueButton.setIsEnabled(true)
    }
}
