import Foundation
import Transfer
import CoreFoundationLib

class OnePayTransferSelectorPresenter: OperativeStepPresenter<OnePayTransferSelectorViewController, OnePayTransferNavigatorProtocol & PullOffersActionsNavigatorProtocol, OnePayTransferSelectorPresenterProtocol> {
    weak var dataEntryView: TransferGenericAmountEntryViewProtocol?
    override var screenId: String? {
        return TrackerPagePrivate.TransferAmountEntry().page
    }   
    private var presenterOffers: [PullOfferLocation: Offer] = [:]
    private var amountEntered: String?
    private var conceptEntered: String?
    var fields: [ValidatableField] = []
    var locations: [PullOfferLocation] {
        return PullOffersLocationsFactory().fxpayDialog //Contains location FXPAY
    }
    var country: String?
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.loadData()
    }
    
    override func loadViewData() {
        super.loadViewData()
        getLocations()
    }
    
    // Pull offers
    private func getLocations() {
        getCandidateOffers { [weak self] candidates in
            self?.presenterOffers = candidates
        }
    }
           
    enum Constants: String {
        case amount
        case concept
    }
    
    private func showAlertInternationalTransfer() {
        self.view.showAlertInternationalTransfer { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.container?.stepFinished(presenter: strongSelf)
        }
    }
}

extension OnePayTransferSelectorPresenter: OnePayTransferSelectorPresenterProtocol {
    var dependenciesResolver: DependenciesResolver {
        return self.dependencies.useCaseProvider.dependenciesResolver
    }

    func validatableFieldChanged() {
        self.dataEntryView?.updateContinueAction(isValidForm)
    }
    
    func changeAccountSelected() {
        let parameter: OnePayTransferOperativeData = containerParameter()
        container?.operativeContainerNavigator.backOnePay(parameter.list)
    }
    
    func didTapBack(amount: String?, concept: String?) {
        self.updateAmount(amount)
        self.updateConcept(concept)
        container?.operativeContainerNavigator.back()
    }
    
    func didTapFaqs() {
        let parameter: OnePayTransferOperativeData = containerParameter()
        let faqModel = parameter.faqs?.map {
            return FaqsItemViewModel(id: $0.id, title: $0.question, description: $0.answer)
        } ?? []
        self.dependencies.trackerManager.trackScreen(screenId: TrackerPagePrivate.TransferFaqs().page, extraParameters: [:])
        self.view.showFaqs(faqModel)
    }
    
    func didTapClose() {
        container?.cancelTouched(completion: nil)
    }
    
    func onContinueButtonClicked() {
        let parameter: OnePayTransferOperativeData = containerParameter()
        guard
            let currency = parameter.currency,
            let country = parameter.country,
            let account = parameter.productSelected
        else {
            return
        }
        self.country = country.name
        let input = DestinationOnePayTransferUseCaseInput(amount: self.amountEntered, currencyInfo: currency, countryInfo: country, account: account )
        let usecase = dependencies.useCaseProvider.getDestinationOnePayTransferUseCase(input: input)
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        UseCaseWrapper(with: usecase, useCaseHandler: dependencies.useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] response in
            self?.hideAllLoadings { [weak self] in
                guard let strongSelf = self else { return }
                let concept = strongSelf.conceptEntered
                let amount = response.amount
                let type = response.type
                let parameter: OnePayTransferOperativeData = strongSelf.containerParameter()
                parameter.type = type
                strongSelf.container?.saveParameter(parameter: parameter)
                strongSelf.container?.rebuildSteps()
                switch type {
                case .national:
                    let parameter: OnePayTransferOperativeData = strongSelf.containerParameter()
                    parameter.amount = amount
                    parameter.concept = concept
                    strongSelf.container?.saveParameter(parameter: parameter)
                case .sepa:
                    let parameter: OnePayTransferOperativeData = strongSelf.containerParameter()
                    parameter.amount = amount
                    parameter.concept = concept
                    strongSelf.container?.saveParameter(parameter: parameter)
                case .noSepa:
                    let noSepaParameter = NoSepaTransferOperativeData(account: account, country: country, currency: currency, amount: amount, concept: concept, favouriteList: parameter.favouriteList ?? [])
                    strongSelf.container?.saveParameter(parameter: noSepaParameter)
                }
                self?.checkFXPay(fxpay: country.fxpay, type: type)
            }
        }, onError: { [weak self] error in
            self?.hideAllLoadings { [weak self] in
                switch error?.error {
                case .invalid?, .empty?, .none:
                    self?.showError(keyTitle: "generic_alert_title_errorData", keyDesc: nil)
                case .zero?:
                    self?.handleAmount()

                }
            }
        })
    }
    
    func updateCountry(_ country: SepaCountryInfoEntity) {
        let parameter: OnePayTransferOperativeData = containerParameter()
        if parameter.country?.code != country.code {
            self.resetBeneficiaryData(country)
        }
    }
    
    func updateCurrency(_ currency: SepaCurrencyInfoEntity) {
        let parameter: OnePayTransferOperativeData = containerParameter()
        parameter.currency = SepaCurrencyInfo.create(currency)
        container?.saveParameter(parameter: parameter)
    }
    
    func updateAmount(_ amount: String?) {
        self.amountEntered = amount
        let parameter: OnePayTransferOperativeData = containerParameter()
        if let amount = amount?.stringToDecimal {
            parameter.amount = Amount.createWith(value: amount)
        } else {
            parameter.amount = nil
        }
        container?.saveParameter(parameter: parameter)
    }
    
    func updateConcept(_ concept: String?) {
        self.conceptEntered = concept
        let parameter: OnePayTransferOperativeData = containerParameter()
        parameter.concept = concept
        container?.saveParameter(parameter: parameter)
    }
            
    private func checkFXPay(fxpay: Bool, type: OnePayTransferType) {
        // Check pull offer and fxpay active
        if type != .national && ( !fxpay || presenterOffers[.FXPAY_DIALOG] == nil ) { // if international and not have fxpay or not have offer
            return showAlertInternationalTransfer()
        } else if fxpay && presenterOffers[.FXPAY_DIALOG] != nil { // if have fxpay
            navigator.goToOnePayFXTransfer(delegate: self)
        } else {
            container?.stepFinished(presenter: self)
        }
    }
        
    func closeLocationBanner(_ offerId: String?) {
        expireOffer(offerId: offerId)
        removeOffer(location: .FXPAY)
        _ = getCandidatesOffersFxPay(completion: { candidates in
            self.dataEntryView?.setLocationsCandidates(candidates)
        })
    }
    
    func selectLocationBanner() {
        guard let offer = presenterOffers[.FXPAY], let offerAction = offer.action else { return }
        executeOffer(action: offerAction, offerId: offer.id, location: PullOfferLocation.FXPAY)
    }

    func handleAmount() {
        self.dataEntryView?.showInvalidAmount(localized(key: "generic_alert_text_errorData_amount").text)
        self.dataEntryView?.updateContinueAction(false)
    }
    
    func trackFaqEvent(_ question: String, url: URL?) {
        var dic: [String: String] = ["faq_question":question]
        if let link = url?.absoluteString {
            dic["faq_link"] = link
        }
        NotificationCenter.default.post(name: .transfersFaqsAnalytics, object: nil, userInfo: ["parameters": dic])
    }
}

extension OnePayTransferSelectorPresenter: DialogOnePayDelegate {
    func goToOnePayFXTransfer(option: OnePayFXOption) {
        let parameter: OnePayTransferOperativeData = containerParameter()
        let type = parameter.type
        if type == .national {
            container?.stepFinished(presenter: self)
        } else {
            switch option {
            case .standard:
                return showAlertInternationalTransfer()
            case .immediate:
                guard let offer = presenterOffers[.FXPAY_DIALOG] else { return }
                executeOffer(action: offer.action, offerId: offer.id, location: PullOfferLocation.FXPAY_DIALOG)
            case .none:
                break
            }
        }
    }
}

private extension OnePayTransferSelectorPresenter {
    func loadData() {
        //init data information in Transfer module
        let parameter: OnePayTransferOperativeData = containerParameter()
        guard
            let account = parameter.productSelected,
            let sepaInfoList = parameter.sepaList?.getSepaInfoListEntity(),
            let countryEntity = parameter.country?.entity,
            let currencyEntity = parameter.currency?.entity else { return }
        let amount = parameter.amount?.amountDTO.value
        let concept = parameter.concept
        let viewModel = SelectedAccountHeaderViewModel(account: account.accountEntity, action: self.changeAccountSelected, dependenciesResolver: self.dependenciesResolver)
        self.dataEntryView?.setAccountInfo(viewModel)
        self.dataEntryView?.setAmountAndConcept(amount: amount, concept: concept)
        self.dataEntryView?.setCountryAndCurrencyInfo(sepaInfoList, countrySelected: countryEntity, currencySelected: currencyEntity)
        _ = getCandidatesOffersFxPay(completion: { candidates in
            self.dataEntryView?.setLocationsCandidates(candidates)
        })
        self.validatableFieldChanged()
        self.disableCountrySelectionIfNeeded()
        self.disableAmountSelectionIfNeeded()
    }
    
    // Pull offer FXPAY in CountrySelector
    private func getCandidatesOffersFxPay(completion: @escaping ([PullOfferLocation: OfferEntity]) -> Void) {
        getCandidateOffers { candidates in
            var candidatesEntity: [PullOfferLocation: OfferEntity] = [:]
            for (key, value) in candidates {
                candidatesEntity[key] = OfferEntity(value.dto)
            }
            completion(candidatesEntity)
        }
    }
    
    func resetBeneficiaryData(_ country: SepaCountryInfoEntity) {
        let parameter: OnePayTransferOperativeData = containerParameter()
        parameter.country = SepaCountryInfo.create(country)
        parameter.iban = nil
        parameter.name = nil
        parameter.alias = nil
        parameter.isFavouriteSelected = false
        container?.saveParameter(parameter: parameter)
    }
    
    func disableCountrySelectionIfNeeded() {
        let parameter: OnePayTransferOperativeData = containerParameter()
        guard !parameter.isEnableCountrySelection else { return }
        self.dataEntryView?.disableDestinationCountrySelection()
    }
    
    func disableAmountSelectionIfNeeded() {
        let parameter: OnePayTransferOperativeData = containerParameter()
        guard !parameter.isEnableCurrencySelection else { return }
        self.dataEntryView?.disableAmountSelection()
    }
}
extension OnePayTransferSelectorPresenter: LocationsResolver { }

extension OnePayTransferSelectorPresenter: PullOfferActionsPresenter {
    var presentationView: ViewControllerProxy {
        return view
    }
    var pullOffersActionsNavigator: PullOffersActionsNavigatorProtocol {
        return navigator
    }
}


