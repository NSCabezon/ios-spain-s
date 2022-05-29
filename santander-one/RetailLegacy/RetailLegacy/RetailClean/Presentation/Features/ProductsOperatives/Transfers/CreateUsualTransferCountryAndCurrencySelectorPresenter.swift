import CoreFoundationLib

class CreateUsualTransferCountryCurrencySelectorPresenter: OperativeStepPresenter<UpdateUsualTransferCountryCurrencyViewController, UsualTransferNavigatorProtocol, UpdateUsualTransferCountryCurrencyPresenterProtocol> {

    private var countryModel: OnePayTransferSelectorViewModel?
    private var currencyModel: OnePayTransferSelectorViewModel?

    override var screenId: String? {
        return TrackerPagePrivate.CreateUsualTransferCountrySelector().page
    }

    override func loadViewData() {
        super.loadViewData()
        view.styledTitle = stringLoader.getString("toolbar_title_newFavoriteRecipients")
        view.progressBarBackgroundColorFromPresenter = .uiBackground
        view.continueButton.set(localizedStylableText: stringLoader.getString("generic_button_continue"), state: .normal)
        self.view.continueButton.accessibilityIdentifier = AccessibilityOthers.btnContinue.rawValue
        infoObtained()
    }

    private func updateCountry(country: SepaCountryInfo) {
        countryModel?.leftText = country.name
        view.reloadCountrySection()
        let parameter: CreateUsualTransferOperativeData = containerParameter()
        parameter.country = country
        parameter.iban = nil
        container?.saveParameter(parameter: parameter)
    }

    private func updateCurrency(currency: SepaCurrencyInfo) {
        currencyModel?.leftText = currency.name
        currencyModel?.rightText = "(\(currency.code))"
        view.reloadCurrencySection()
        let parameter: CreateUsualTransferOperativeData = containerParameter()
        parameter.currency = currency
        container?.saveParameter(parameter: parameter)
    }

    private func infoObtained() {
        let parameter: CreateUsualTransferOperativeData = containerParameter()
        guard let currentCurrency = parameter.currency, let currentCountry = parameter.country else {
            return
        }

        let sectionCountry = TableModelViewSection()
        let countryTitle = TitledTableModelViewHeader(insets: Insets(left: 11, right: 10, top: CreateUsualTransferOperative.Constants.firstCellExtraTopInset, bottom: 6))
        countryTitle.title = stringLoader.getString("sendMoney_label_destinationCountry")
        sectionCountry.setHeader(modelViewHeader: countryTitle)
        let countryModel = OnePayTransferSelectorViewModel(leftText: currentCountry.name, shouldBeNavigatable: true, dependencies: dependencies)
        countryModel.accessibilityIdentifier = AccessibilityUsualTransfer.destinationCountryLabel.rawValue
        sectionCountry.add(item: countryModel)
        self.countryModel = countryModel

        let sectionCurrency = TableModelViewSection()
        let currencyTitle = TitledTableModelViewHeader()
        currencyTitle.title = stringLoader.getString("sendMoney_label_currency")
        sectionCurrency.setHeader(modelViewHeader: currencyTitle)
        let currencyModel = OnePayTransferSelectorViewModel(leftText: currentCurrency.name, rightText: "(\(currentCurrency.code))", shouldBeNavigatable: true, dependencies: dependencies)
        currencyModel.accessibilityIdentifier = AccessibilityUsualTransfer.currencyLabel.rawValue
        sectionCurrency.add(item: currencyModel)
        self.currencyModel = currencyModel
        
        container?.saveParameter(parameter: parameter)
        view.sections = [sectionCountry, sectionCurrency]
    }
}

extension CreateUsualTransferCountryCurrencySelectorPresenter: UpdateUsualTransferCountryCurrencyPresenterProtocol {
    func onContinueButtonClicked() {
        let parameter: CreateUsualTransferOperativeData = containerParameter()
        guard let currency = parameter.currency, let country = parameter.country else {
            return
        }
        if parameter.isNoSepa {
            let noSepaParameter = CreateNoSepaUsualTransferOperativeData(country: country, currency: currency, favouriteList: parameter.favouriteList ?? [])
            noSepaParameter.sepaList = parameter.sepaList
            container?.saveParameter(parameter: noSepaParameter)
        }
        container?.rebuildSteps()
        container?.stepFinished(presenter: self)
    }

    func onCountryButtonClicked() {
        let parameter: CreateUsualTransferOperativeData = containerParameter()
        guard let sepaList = parameter.sepaList else {
            return
        }
        navigator.goToSelection(list: sepaList.allCountries, selected: parameter.country, delegate: self)
    }

    func onCurrencyButtonClicked() {
        let parameter: CreateUsualTransferOperativeData = containerParameter()
        guard let sepaList = parameter.sepaList else {
            return
        }
        navigator.goToSelection(list: sepaList.allCurrencies, selected: parameter.currency, delegate: self)
    }
}

extension CreateUsualTransferCountryCurrencySelectorPresenter: TransferSearchableConfigurationSelectionPresenterDelegate {
    func closeButton() {
        container?.cancelTouched(completion: nil)
    }

    func didSelect<Item>(_ item: Item) {
        if let country = item as? SepaCountryInfo {
            updateCountry(country: country)
            let parameter: CreateUsualTransferOperativeData = containerParameter()
            
            let currencies = parameter.sepaList?.allCurrencies
            if let currency = currencies?.first(where: { $0.code == country.currency }) ?? currencies?.first {
                updateCurrency(currency: currency)
            }
            
            navigator.goBack()
        } else if let currency = item as? SepaCurrencyInfo {
            updateCurrency(currency: currency)
            navigator.goBack()
        }
    }
}
