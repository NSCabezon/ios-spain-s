import Foundation
import CoreFoundationLib

class UpdateUsualTransferCountryCurrencySelectorPresenter: OperativeStepPresenter<UpdateUsualTransferCountryCurrencyViewController, UsualTransferNavigatorProtocol, UpdateUsualTransferCountryCurrencyPresenterProtocol> {
    
    private var countryModel: OnePayTransferSelectorViewModel?
    private var currencyModel: OnePayTransferSelectorViewModel?
    
    override var screenId: String? {
        return TrackerPagePrivate.UpdateUsualTransfer().countrySelector
    }
    
    override func loadViewData() {
        super.loadViewData()
        view.styledTitle = stringLoader.getString("toolbar_title_editFavoriteRecipients")
        view.continueButton.set(localizedStylableText: stringLoader.getString("generic_button_continue"), state: .normal)

        infoObtained()
    }
    
    private func updateCountry(country: SepaCountryInfo) {
        countryModel?.leftText = country.name
        view.reloadCountrySection()
        let parameter: UpdateUsualTransferOperativeData = containerParameter()
        parameter.newCountry = country
        container?.saveParameter(parameter: parameter)
    }
    
    private func updateCurrency(currency: SepaCurrencyInfo) {
        currencyModel?.leftText = currency.name
        currencyModel?.rightText = "(\(currency.code))"
        view.reloadCurrencySection()
        let parameter: UpdateUsualTransferOperativeData = containerParameter()
        parameter.newCurrency = currency
        container?.saveParameter(parameter: parameter)
    }
    
    private func infoObtained() {
        let parameter: UpdateUsualTransferOperativeData = containerParameter()
        guard let currentCurrency = parameter.currentCurrency, let currentCountry = parameter.currentCountry else {
            return
        }
        
        let sectionCountry = TableModelViewSection()
        let countryTitle = TitledTableModelViewHeader(insets: Insets(left: 11, right: 10, top: 30, bottom: 6))
        countryTitle.title = stringLoader.getString("sendMoney_label_destinationCountry")
        sectionCountry.setHeader(modelViewHeader: countryTitle)
        let countryModel = OnePayTransferSelectorViewModel(
            leftText: currentCountry.name,
            accessibilityIdentifierLeft: AccessibilityEditFavorite.countryStepLabelCountry,
            shouldBeNavigatable: true,
            dependencies: dependencies
        )
        countryModel.accessibilityIdentifier = currentCountry.name
        sectionCountry.add(item: countryModel)
        self.countryModel = countryModel
        parameter.currentCountry = currentCountry
        parameter.newCountry = currentCountry
        
        let sectionCurrency = TableModelViewSection()
        let currencyTitle = TitledTableModelViewHeader()
        currencyTitle.title = stringLoader.getString("sendMoney_label_currency")
        sectionCurrency.setHeader(modelViewHeader: currencyTitle)
        let currencyModel = OnePayTransferSelectorViewModel(
            leftText: currentCurrency.name,
            rightText: "(\(currentCurrency.code))",
            accessibilityIdentifierLeft: AccessibilityEditFavorite.countryStepLabelCurrencyName,
            accessibilityIdentifierRight: AccessibilityEditFavorite.countryStepLabelCurrencyCode,
            shouldBeNavigatable: false,
            dependencies: dependencies
        )
        sectionCurrency.add(item: currencyModel)
        currencyModel.accessibilityIdentifier = currentCurrency.name
        self.currencyModel = currencyModel
        parameter.currentCurrency = currentCurrency
        parameter.newCurrency = currentCurrency
        container?.saveParameter(parameter: parameter)
        view.sections = [sectionCountry, sectionCurrency]
    }
}

extension UpdateUsualTransferCountryCurrencySelectorPresenter: UpdateUsualTransferCountryCurrencyPresenterProtocol {
    func onContinueButtonClicked() {
        container?.stepFinished(presenter: self)
    }
    
    func onCountryButtonClicked() {
        let parameter: UpdateUsualTransferOperativeData = containerParameter()
        guard let sepaList = parameter.sepaList else {
            return
        }
        navigator.goToSelection(list: sepaList.allCountries, selected: parameter.newCountry, delegate: self)
    }
    
    func onCurrencyButtonClicked() {}
}

extension UpdateUsualTransferCountryCurrencySelectorPresenter: TransferSearchableConfigurationSelectionPresenterDelegate {
    func closeButton() {
        container?.cancelTouched(completion: nil)
    }
    
    func didSelect<Item>(_ item: Item) {
        if let country = item as? SepaCountryInfo {
            updateCountry(country: country)
            navigator.goBack()
        } else if let currency = item as? SepaCurrencyInfo {
            updateCurrency(currency: currency)
            navigator.goBack()
        }
    }
}
