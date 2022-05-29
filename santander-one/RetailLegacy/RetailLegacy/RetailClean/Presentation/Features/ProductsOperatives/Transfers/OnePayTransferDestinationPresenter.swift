import TransferOperatives
import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain
import Foundation
import Transfer

protocol OnePayTransferDestinationDelegate: class {
    func selectedFavourite(item: FavoriteType)
}

class OnePayTransferDestinationPresenter: OperativeStepPresenter<OnePayTransferDestinationViewController, OnePayTransferNavigatorProtocol, OnePayTransferDestinationPresenterProtocol> {
    weak var dataEntryView: TransferDestinationViewProtocol?
    override var screenId: String? {
        let parameter: OnePayTransferOperativeData = containerParameter()
        switch parameter.type {
        case .national?: return TrackerPagePrivate.NationalTransferDestinationAccount().page
        case .sepa?: return TrackerPagePrivate.InternationalTransferDestinationAccount().page
        default: return nil
        }
    }
    private var isSpanishResident = true
    private var isFavourite = false
    private var transferTime: OnePayTransferTime = .now
    private var transferDetailList: [TransfersEntityViewModel] = []
    private var isFavouritesCarrouselEnabled: Bool = false
    private var baseUrl: String = ""
    private lazy var emittedSuperUseCase: LoadEmittedTransferListSuperUseCase = {
        let superUseCase = useCaseProvider.getLoadEmittedTransfersSuperUseCase(useCaseHandler: useCaseHandler)
        superUseCase.delegate = self
        return superUseCase
    }()
    private var controlDigitDelegate: IbanCccTransferControlDigitDelegate? {
        self.dependenciesResolver.resolve(firstOptionalTypeOf: IbanCccTransferControlDigitDelegate.self)
    }
    // MARK: Input textfields
    private var newAlias: String?
    private var newIban: String?
    private var newDestinationName: String?
    var fields: [ValidatableField] = []
    
    override func viewWillAppear() {
        super.viewWillAppear()
        // Workaround to avoid bug with the progress (we have to recalculate the number of steps when we go back)
        let parameter: OnePayTransferOperativeData = containerParameter()
        parameter.time = nil
        container?.saveParameter(parameter: parameter)
        container?.rebuildSteps()
        container?.operative.updateProgress(of: self)
        self.validatableFieldChanged()        
        self.setListFavourites()
        if let name = parameter.name, let iban = parameter.iban?.ibanString {
            self.dataEntryView?.updateBeneficiaryInfo(name, iban: iban, alias: parameter.alias, isFavouriteSelected: parameter.isFavouriteSelected)
        }
        self.disableEditingDestinationIfNeeded()
    }
    
    override func loadViewData() {
        super.loadViewData()
        view.styledTitle = stringLoader.getString("toolbar_title_sendMoney")
    }
}

// MARK: - OnePayTransferDestinationPresenterProtocol

extension OnePayTransferDestinationPresenter: OnePayTransferDestinationPresenterProtocol {
    
    var bankingUtils: BankingUtilsProtocol {
        dependenciesResolver.resolve()
    }
    
    var dependenciesResolver: DependenciesResolver {
        return self.dependencies.useCaseProvider.dependenciesResolver
    }
    
    func didChangeSpanishCheck(_ state: Bool) {
        self.isSpanishResident = state
    }
    
    func didChangeAliasCheck(_ state: Bool) {
        self.isFavourite = state
        if self.isFavourite {
            let parameter: OnePayTransferOperativeData = self.containerParameter()
            switch parameter.type {
            case .national?:
                self.trackEvent(eventId: TrackerPagePrivate.NationalTransferDestinationAccount.Action.isFavourite.rawValue, parameters: [:])
            case .sepa?:
                self.trackEvent(eventId: TrackerPagePrivate.InternationalTransferDestinationAccount.Action.isFavourite.rawValue, parameters: [:])
            default:
                break
            }
            self.dataEntryView?.addAliasTextValidation()
        } else {
            self.dataEntryView?.removeAliasTextValidation()
        }
    }
    
    func updateInfo(_ ibanText: String?, nameText: String?, aliasText: String?, transferTime: SendMoneyDateTypeFilledViewModel, isFavouriteSelected: Bool) {
        let parameter: OnePayTransferOperativeData = containerParameter()
        self.newIban = ibanText
        self.newDestinationName = nameText
        self.newAlias = aliasText
        self.transferTime = OnePayTransferTime.parserOnePayTransferTime(transferTime)
        parameter.name = nameText
        parameter.alias = aliasText
        parameter.iban = IBAN(dto: IBANDTO(ibanString: ibanText ?? ""))
        parameter.isFavouriteSelected = isFavouriteSelected
        parameter.dateTypeModel = transferTime
        self.container?.saveParameter(parameter: parameter)
    }
    
    func didSelectBeneficiary(_ transferEmitted: TransferEmittedEntity?) {
        self.isFavourite = false
        if let transferEmitted = transferEmitted {
            self.getEmittedTransferDetail(TransferEmitted.create(transferEmitted))
        } else {
            let parameter: OnePayTransferOperativeData = containerParameter()
            parameter.name = nil
            parameter.iban = nil
        }
    }
    
    func viewDidLoad() {
        //init data information in Transfer module
        if let onePayTransferModifier = self.dependenciesResolver.resolve(forOptionalType: OnePayTransferModifierProtocol.self) {
            let isEnableResidenceView = onePayTransferModifier.isEnabledResidenceView
            let isEnabledSelectorBusinessDateView = onePayTransferModifier.isEnabledSelectorBusinessDateView
            self.dataEntryView?.hideDestinationViews(isEnableResidence: isEnableResidenceView, isEnabledSelectorBusinessDateView: isEnabledSelectorBusinessDateView)
        }   
        self.emittedSuperUseCase.execute()
        let parameter: OnePayTransferOperativeData = containerParameter()
        guard let account = parameter.productSelected, let country = parameter.country else { return }
        let accountViewModel = SelectedAccountHeaderViewModel(account: account.accountEntity, action: self.changeAccountSelected, dependenciesResolver: self.dependenciesResolver)
        self.dataEntryView?.setAccountInfo(accountViewModel)
        self.bankingUtils.setCountryCode(country.code)
        self.dataEntryView?.configureIbanWithBankingUtils(self.bankingUtils,
                                                          controlDigitDelegate: self.controlDigitDelegate)
        self.setListFavourites()
        self.isFavouritesCarrouselEnabled = parameter.enabledFavouritesCarrusel ?? false
        if !self.isFavouritesCarrouselEnabled {
            self.dataEntryView?.setHiddenLastTransfers()
        }
        let preciodicityModel = SendMoneyPeriodicityViewModel(dependenciesResolver: self.dependenciesResolver)
        self.dataEntryView?.setupPeriodicityModel(with: preciodicityModel)
        if let dateTypeModel = parameter.dateTypeModel {
            self.dataEntryView?.setDateTypeSaved(dateTypeModel: dateTypeModel)
        }
    }
    
    func didTapBack() {
        self.dataEntryView?.updateInfo()
        container?.operativeContainerNavigator.back()
    }
    
    func didTapClose() {
        container?.cancelTouched(completion: nil)
    }
    
    func didTapFaqs() {
        let parameter: OnePayTransferOperativeData = containerParameter()
        let faqModel = parameter.faqs?.map {
            return FaqsItemViewModel(id: $0.id, title: $0.question, description: $0.answer)
            } ?? []
        self.dependencies.trackerManager.trackScreen(screenId: TrackerPagePrivate.TransferFaqs().page, extraParameters: [:])
        self.view.showFaqs(faqModel)
    }
    
    func changeAccountSelected() {
        let parameter: OnePayTransferOperativeData = containerParameter()
        container?.operativeContainerNavigator.backOnePay(parameter.list)
    }
    
    func onContinueButtonClicked() {
        let parameter: OnePayTransferOperativeData = containerParameter()
        guard
            let list = parameter.favouriteList,
            let country = parameter.country,
            let type = parameter.type,
            let amount = parameter.amount,
            let originAccount = parameter.productSelected
            else { return }
        
        let input = DestinationAccountOnePayTransferUseCaseInput(iban: self.newIban,
                                                                 name: self.newDestinationName,
                                                                 alias: self.newAlias,
                                                                 saveFavorites: isFavourite,
                                                                 isSpanishResident: isSpanishResident,
                                                                 time: self.transferTime,
                                                                 favouriteList: list.map { $0.favorite },
                                                                 country: country,
                                                                 type: type,
                                                                 concept: parameter.concept,
                                                                 amount: amount,
                                                                 originAccount: originAccount,
                                                                 scheduledTransfer: parameter.scheduledTransfer)
        let useCase = dependencies.useCaseProvider.getDestinationAccountOnePayTransferUseCase(input: input)
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        UseCaseWrapper( with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] response in
            self?.hideAllLoadings { [weak self] in
                guard let strongSelf = self else { return }
                let parameter: OnePayTransferOperativeData = strongSelf.containerParameter()
                parameter.name = response.name
                parameter.iban = response.iban
                parameter.spainResident = strongSelf.isSpanishResident
                parameter.saveToFavorites = response.saveFavorites
                parameter.alias = response.alias
                parameter.time = response.time
                parameter.transferNational = response.transferNational
                parameter.scheduledTransfer = response.scheduledTransfer
                if parameter.type != .national {
                    parameter.subType = .standard
                } else {
                    switch strongSelf.transferTime {
                    case .periodic: parameter.subType = .standard
                    case .day: parameter.subType = .standard
                    case .now: break
                    }
                }
                strongSelf.container?.saveParameter(parameter: parameter)
                strongSelf.container?.rebuildSteps()
                strongSelf.container?.stepFinished(presenter: strongSelf)
            }
            }, onError: { [weak self] error in
                self?.hideAllLoadings { [weak self] in
                    guard let strongSelf = self else { return }
                    switch error?.error {
                    case .ibanInvalid?:
                        strongSelf.ibanWasInvalid()
                    case .noToName?:
                        strongSelf.showError(keyTitle: "generic_alert_title_errorData", keyDesc: "onePay_alert_nameRecipients")
                    case .noAlias?:
                        strongSelf.showError(keyTitle: "generic_alert_title_errorData", keyDesc: "onePay_alert_alias")
                    case .duplicateAlias(let alias)?:
                        let acceptComponents = DialogButtonComponents(titled: strongSelf.localized(key: "generic_button_accept"), does: nil)
                        Dialog.alert(title: strongSelf.localized(key: "generic_alert_title_errorData"), body: strongSelf.localized(key: "onePay_alert_valueAlias", stringPlaceHolder: [StringPlaceholder(.value, alias)]), withAcceptComponent: acceptComponents, withCancelComponent: nil, source: strongSelf.view)
                    case .serviceError(let errorDesc)?:
                        strongSelf.showError(keyDesc: errorDesc)
                    case .none:
                        break
                    }
                }
        })
    }
    
    func validatableFieldChanged() {
        self.dataEntryView?.updateContinueAction(isValidForm)
    }
    
    func getEmittedTransferDetail(_ transfer: TransferEmitted) {
        let input = GetEmittedTransferDetailUseCaseInput(transfer: transfer)
        let useCase = useCaseProvider.getEmittedTransferDetailUseCase(input: input)
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        CoreFoundationLib.UseCaseWrapper( with: useCase, useCaseHandler: useCaseHandler, onSuccess: { [weak self] (response) in
            self?.hideAllLoadings { [weak self] in
                guard let self = self else { return }
                self.changeTranferTypeIfNeeded(response: response)
                guard let name = response.transferEmittedDetail?.beneficiaryName?.capitalized, let iban = response.transferEmittedDetail?.beneficiary?.ibanPapel else { return }
                self.dataEntryView?.updateBeneficiaryInfo(name, iban: iban, alias: nil, isFavouriteSelected: false)
                self.setListFavourites()
            }
            }, onError: { [weak self] error in
                self?.hideAllLoadings {
                    self?.showError(keyDesc: error.getErrorDesc())
                }
        })
    }
    
    private func ibanWasInvalid() {
        self.dataEntryView?.updateContinueAction(false)
        self.dataEntryView?.showInvalidIban("onePay_alert_valueIban")
    }
    
    func trackFaqEvent(_ question: String, url: URL?) {
        var dic: [String: String] = ["faq_question":question]
        if let link = url?.absoluteString {
            dic["faq_link"] = link
        }
        NotificationCenter.default.post(name: .transfersFaqsAnalytics, object: nil, userInfo: ["parameters": dic])
    }
    
    func getMaxLengthAlias() -> Int {
        guard let onePayModifier = self.dependenciesResolver.resolve(forOptionalType: OnePayTransferModifierProtocol.self) else {
            return 50
        }
        return onePayModifier.getMaxLengthAliasFavorite()
    }
    
    func differenceOfDaysToDeferredTransfers() -> Int {
        guard let onePayTransferModifier = self.dependenciesResolver.resolve(forOptionalType: OnePayTransferModifierProtocol.self) else {
            return 2
        }
        return onePayTransferModifier.differenceOfDaysToDeferredTransfers
    }
}

private extension OnePayTransferDestinationPresenter {
    func setListFavourites() {
        let parameter: OnePayTransferOperativeData = containerParameter()
        guard
            let favouriteList = parameter.favouriteListFiltered,
            let baseUrl = parameter.baseUrl,
            let sepaInfoList = parameter.sepaList?.getSepaInfoListEntity() else { return }
        let colorsEngine = ColorsByNameEngine()
        let favoriteListSorted = getFavoriteContactsSorted(favouriteList: favouriteList, favoriteContacts: parameter.favoriteContacts)
        let contactViewModels: [ContactEntityViewModel] = favoriteListSorted.map { favType in
            let colorType = colorsEngine.get(favType.alias ?? "")
            let colorsByNameViewModel = ColorsByNameViewModel(colorType)
            return ContactEntityViewModel(contact: favType.favorite.representable, baseUrl: baseUrl, colorsByNameViewModel: colorsByNameViewModel)
        }
        self.dataEntryView?.setListFavourites(contactViewModels, sepaInfoList: sepaInfoList)
        self.dataEntryView?.setCountry(parameter.country?.name ?? "")
    }
    
    func getFavoriteContactsSorted(favouriteList: [FavoriteType], favoriteContacts: [String]?) -> [FavoriteType] {
        guard let favoriteContacts = favoriteContacts else { return favouriteList }
        let sortedFavorites = favoriteContacts.compactMap { (contact) -> FavoriteType? in
            return favouriteList.first { contact == $0.alias }
        }
        let restFavorites = favouriteList.compactMap { (favorite) -> FavoriteType? in
            guard let alias = favorite.alias,
                !favoriteContacts.contains(alias) else {
                    return nil
            }
            return favorite
        }
        return sortedFavorites + restFavorites
    }
    
    func changeTranferTypeIfNeeded(response: GetEmittedTransferDetailUseCaseOkOutput) {
        let parameter: OnePayTransferOperativeData = self.containerParameter()
        guard let countryCode = response.transferEmittedDetail?.beneficiary?.countryCode,
            countryCode != parameter.country?.code else {
                return
        }
        let countryInfo = response.sepaList.getSepaCountryInfo(countryCode)
        let localCountryCodeEvaluation = dependencies.navigatorProvider.dependenciesEngine.resolve(forOptionalType: OnePayTransferModifierProtocol.self)?.updateCountry
        parameter.updateCountry(countryInfo: countryInfo, countryCode: localCountryCodeEvaluation)
        self.container?.saveParameter(parameter: parameter)
        self.bankingUtils.setCountryCode(countryInfo.code)
        self.dataEntryView?.configureIbanWithBankingUtils(self.bankingUtils,
                                                          controlDigitDelegate: self.controlDigitDelegate)
    }

    func disableEditingDestinationIfNeeded() {
        let parameter: OnePayTransferOperativeData = containerParameter()
        guard !parameter.isEnableEditingDestination else { return }
        self.dataEntryView?.disableEditingDestinationInformation()
    }
}

extension OnePayTransferDestinationPresenter: LoadEmittedTransferListDelegate {
    func didReceiveEmittedTransfers(_ transfers: [(data: TransferEmitted, account: Account)]) {
        let urlProvider = dependenciesResolver.resolve(for: BaseURLProvider.self)
        if self.isFavouritesCarrouselEnabled {
            let colorsEngine = ColorsByNameEngine()
            transfers.forEach { (transfer) in
                guard let name = transfer.data.beneficiary?.capitalized,
                      let baseUrl = urlProvider.baseURL else {
                    return
                }
                let colorType = colorsEngine.get(name)
                let colorsByNameViewModel = ColorsByNameViewModel(colorType)
                let bankIconUrl = transfer.account.accountEntity.buildImageRelativeUrl()
                let iconUrl = baseUrl + bankIconUrl
                let detail = TransfersEntityViewModel(beneficiaryName: name,
                                                      accountIban: transfer.account.getIBANShortLisboaStyle(),
                                                      colorsByNameViewModel: colorsByNameViewModel,
                                                      transferEmitted: transfer.data.entity,
                                                      bankIconUrl: iconUrl)
                if transfer.data.type == .sepa {
                    self.transferDetailList.append(detail)
                }
            }
            self.dataEntryView?.setLastTransfers(self.transferDetailList, isFavouritesCarrouselEnabled: self.isFavouritesCarrouselEnabled)
        }
    }
}

struct ContactEntityViewModel: ContactViewModel {
    func getShareableInfo() -> String {
        return contact.formattedAccount ?? ""
    }
    
    let contact: PayeeRepresentable
    let baseUrl: String?
    let colorsByNameViewModel: ColorsByNameViewModel
}

struct TransfersEntityViewModel: EmittedSepaTransferViewModel {
    var beneficiaryName: String
    var accountIban: String
    var colorsByNameViewModel: ColorsByNameViewModel
    var transferEmitted: TransferEmittedEntity
    var bankIconUrl: String
}
