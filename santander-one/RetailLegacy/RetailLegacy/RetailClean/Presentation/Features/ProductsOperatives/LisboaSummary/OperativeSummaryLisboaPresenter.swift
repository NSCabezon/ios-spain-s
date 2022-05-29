import CoreFoundationLib
import Foundation
import Operative
import UI
import PdfCommons
import Transfer
import TransferOperatives

protocol OperativeSummaryLisboaPresenterProtocol: Presenter {
    func didTapCloseButton()
    func didTapSendMoney()
    func didTapGoToHome()
    func didTapHelpUsToImprove()
    func didTapPdfButton()
    func didTapShareButton()
    func extraViewModels() -> [OperativeSummaryLisboaDetailViewModel]
}

final class OperativeSummaryLisboaPresenter: OperativeStepPresenter<OperativeSummaryLisboaViewController, OperativeSummaryNavigatorProtocol, OperativeSummaryLisboaPresenterProtocol> {
    
    private let numberOfExpandedItems = 3
    private var detailViewModels = [OperativeSummaryLisboaDetailViewModel]()
    private let pdfCreator = PDFCreator()
    private var sharingText = ""
    private var candidateLocations: [PullOfferLocation: Offer] = [:]
    private var offerConditions: [PullOfferLocation: Bool] = [:]
    private lazy var onePayTransferModifier: OnePayTransferModifierProtocol? = {
        self.dependencies.navigatorProvider.dependenciesEngine.resolve(forOptionalType: OnePayTransferModifierProtocol.self)
    }()

    var locations: [PullOfferLocation] {
        let container: OnePayTransferOperativeData = containerParameter()
        switch container.type {
        case .national, .none:
            return PullOffersLocationsFactoryEntity.transferSummary(pageForMetrics: TrackerPagePrivate.NationalTransferSummary().page)
        case .sepa, .noSepa:
            return PullOffersLocationsFactoryEntity.transferSummary(pageForMetrics: TrackerPagePrivate.InternationalTransferSummary().page)
        }
    }
    
    private var baseURLProvider: BaseURLProvider {
        return self.dependencies.navigatorProvider.dependenciesEngine.resolve(for: BaseURLProvider.self)
    }
    
    override func loadViewData() {
        super.loadViewData()
        setupOffers()
        checkState()
        setupSharedText()
    }
    
    override var isProgressBarVisible: Bool {
        false
    }
    
    override var isBackable: Bool {
        false
    }
    
    // MARK: - Tracks
    override var screenId: String? {
        return container?.operative.screenIdSummary
    }
    
    override func getTrackParameters() -> [String: String]? {
        return container?.operative.getTrackParametersSummary()
    }
}

private extension OperativeSummaryLisboaPresenter {
    func checkState() {
        switch container?.operative.getSummaryState() {
        case .success:
            configureDetail()
        case .error:
            configureErrorView()
        case .pending:
            configurePendingView()
        default:
            break
        }
    }
    
    func setupSharedText() {
        var info = [SummaryItemData]()
        if let data = container?.operative.getSummaryInfo() {
            info = data
        }
        sharingText = info.reduce("", { (text, data) in
            if data.isShareable {
                return text + data.description + "\n"
            } else {
                return text
            }
        })
        let title = container?.operative.getSummaryTitle().text ?? ""
        if let subtitle = container?.operative.getSummarySubtitle() {
            sharingText = title + "\n" + subtitle.text + "\n\n" + sharingText
        } else {
            sharingText = title + "\n\n" + sharingText
        }
    }
    
    func configureDetail() {
        setupHeader()
        setupAmount()
        setupInfo()
    }
    
    func configureErrorView() {
        view.addErrorView()
    }
    
    func configurePendingView() {
        view.addPendingView()
    }
    
    func setupHeader() {
        let container: OnePayTransferOperativeData = containerParameter()
        var description: String
        if showDescriptionHeaderSummaryScreen() {
            switch container.subType {
            case .immediate:
                description = "summary_subtitle_immediateOnePay"
            case .standard:
                switch container.time {
                case .periodic?, .day?:
                    description = "summary_subtitle_paidOnePay"
                default:
                    description = self.container?.operative.getSummarySubtitle()?.text ?? ""
                }
            default:
                description = "summary_subtitle_standardOnePay"
            }
        } else {
            description = ""
        }
        view.setupHeader(OperativeSummaryLisboaHeaderViewModel(imageName: "icnCheckOval",
                                                               title: localized(key: "summe_title_perfect").text,
                                                               subtitleKey: "summary_label_sentMoneyOk",
                                                               descriptionKey: description,
                                                               isOk: true))
    }
    
    func setupAmount() {
        let container: OnePayTransferOperativeData = containerParameter()
        view.setupDetailHeader(OperativeSummaryLisboaDetailHeaderViewModel(title: localized(key: "summary_item_amount").text,
                                                                           total: container.amount?.getFormattedAmountUI() ?? ""))
    }
    
    func setupInfo() {
        var viewModels = [OperativeSummaryLisboaDetailViewModel]()
        viewModels.append(info())
        viewModels.append(origin())
        viewModels.append(sendType())
        viewModels.append(destination())
        viewModels.append(destinationCountry())
        let container: OnePayTransferOperativeData = containerParameter()
        switch container.time {
        case .now?:
            viewModels.append(mailExpenses())
            viewModels.append(netAmount())
            if hideNetAmount() { viewModels.removeLast() }
            viewModels.append(transactionDate())
        case .day?:
            manageCommissions(&viewModels)
            viewModels.append(issuanceDate())
        case .periodic(let startDate, let endDate, _, _)?:
            manageCommissions(&viewModels)
            viewModels.append(startAndEndDate(startDate: startDate, endDate: endDate))
        case .none:
            break
        }
        detailViewModels = viewModels
        view.setupDetail(Array(viewModels.prefix(upTo: numberOfExpandedItems)))
    }
    
    func buildLocations() -> [OperativeSummaryStandardLocationViewModel] {
        var entityOffers: [PullOfferLocation: OfferEntity] = [:]
        for (location, offer) in candidateLocations {
            entityOffers[location] = OfferEntity(offer.dto, location: location)
        }
        let builder = OperativeSummaryStandardLocationBuilder(offers: entityOffers,
                                                              offerConditions: offerConditions)
        builder.addPaymentLocation(executeOfferAction: { [weak self] offer in
            self?.executeOffer(action: offer.action, offerId: offer.id, location: offer.location)
        })
        return builder.build()
    }
    
    func setupOffers() {
        let operativeData: OnePayTransferOperativeData = containerParameter()
        getCandidateOffers { [weak self] offers in
            guard let strongSelf = self else { return }
            switch operativeData.easyPayFundableType {
            case .low where offers[.EASY_PAY_LOW_AMOUNT_SUMMARY] != nil:
                strongSelf.view.addExtraAction("transaction_buttom_installments", icon: "icnFractionate", action: strongSelf.finance)
            case .high where offers[.EASY_PAY_HIGH_AMOUNT_SUMMARY] != nil:
                strongSelf.view.addExtraAction("transaction_buttom_installments", icon: "icnFractionate", action: strongSelf.finance)
            default:
                break
            }
            strongSelf.candidateLocations = offers
            strongSelf.evaluateLocations()
        }
    }
    
    func finance() {
        let operativeData: OnePayTransferOperativeData = containerParameter()
        switch operativeData.easyPayFundableType {
        case .low:
            let offer = candidateLocations[.EASY_PAY_LOW_AMOUNT_SUMMARY]
            executeOffer(action: offer?.action, offerId: offer?.id, location: PullOfferLocation.EASY_PAY_LOW_AMOUNT_SUMMARY)
            trackEvent(eventId: TrackerPagePrivate.NationalTransferSummary.Action.easyPay.rawValue, parameters: [:])
        case .high:
            let offer = candidateLocations[.EASY_PAY_HIGH_AMOUNT_SUMMARY]
            executeOffer(action: offer?.action, offerId: offer?.id, location: PullOfferLocation.EASY_PAY_HIGH_AMOUNT_SUMMARY)
            trackEvent(eventId: TrackerPagePrivate.NationalTransferSummary.Action.easyPay.rawValue, parameters: [:])
        case .notAllowed:
            trackEvent(eventId: TrackerPagePrivate.NationalTransferSummary.Action.easyPayError.rawValue, parameters: [:])
        }
    }
}

extension OperativeSummaryLisboaPresenter: OperativeSummaryLisboaPresenterProtocol {
    func extraViewModels() -> [OperativeSummaryLisboaDetailViewModel] {
        Array(detailViewModels.suffix(from: numberOfExpandedItems - 1))
    }
    
    func didTapCloseButton() {
        let containerParam: OnePayTransferOperativeData = containerParameter()
        containerParam.finishType = .home
        container?.stepFinished(presenter: self)
    }
    
    func didTapSendMoney() {
        let containerParam: OnePayTransferOperativeData = containerParameter()
        containerParam.finishType = .home
        container?.stepFinished(presenter: self)
    }
    
    func didTapGoToHome() {
        let containerParam: OnePayTransferOperativeData = containerParameter()
        containerParam.finishType = .pg
        container?.stepFinished(presenter: self)
    }
    
    func didTapHelpUsToImprove() {
        guard let container = container, let opinatorPage = container.operative.opinatorPage else {
            return
        }
        self.dependencies.trackerManager.trackEvent(screenId: TrackerPagePrivate.NationalTransferSummary().page, eventId: TrackerPagePrivate.NationalTransferSummary.Action.helpToImprove.rawValue, extraParameters: [:])
        openOpinator(forRegularPage: opinatorPage, onError: { [weak self] errorDescription in
            self?.showError(keyDesc: errorDescription)
        })
    }
    
    func didTapPdfButton() {
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        guard let html = container?.operative.pdfContent, let title = container?.operative.pdfTitle else {
            return
        }
        let parameters = container?.operative.getExtraTrackShareParametersSummary() ?? [:]
        trackEvent(eventId: TrackerPagePrivate.Generic.Action.pdf.rawValue, parameters: parameters)
        let pdfSource: PdfSource = container?.operative.pdfSource ?? .summary
        pdfCreator.createPDF(html: html, completion: { [weak self]  data in
            self?.hideAllLoadings {
                self?.navigator.goToPdf(with: data, title: title, pdfSource: pdfSource)
            }
            }, failed: { [weak self] in
                self?.hideAllLoadings {
                    self?.showError(keyDesc: nil)
                }
        })
    }
    
    func didTapShareButton() {
        let parameters = container?.operative.getExtraTrackShareParametersSummary() ?? [:]
        self.dependencies.trackerManager.trackEvent(screenId: TrackerPagePrivate.NationalTransferSummary().page, eventId: TrackerPagePrivate.NationalTransferSummary.Action.share.rawValue, extraParameters: parameters)
        guard let sharingType = container?.operative.sharingType else { return }
        switch sharingType {
        case .text: self.shareByText()
        case .image: self.shareByImage()
        }
    }
}

private extension OperativeSummaryLisboaPresenter {
    func evaluateLocations() {
        guard let (location, _) = self.candidateLocations.location(key: TransferPullOffers.paymentSummary) else {
            self.view.addLocations(models: self.buildLocations())
            return
        }
        hasPaymentOneProduct { [weak self] result in
            guard let self = self else { return }
            self.offerConditions[location] = result
            self.view.addLocations(models: self.buildLocations())
        }
    }
    
    func hasPaymentOneProduct(_ completion: @escaping (Bool) -> Void) {
        let input = GetHasOneProductsUseCaseInput(product: \.paymentOneProducts)
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getHasOneProductsUseCase(input: input),
            useCaseHandler: useCaseHandler,
            onSuccess: { result in
                completion(result.hasOneProduct)
            }, onError: { _ in
                completion(false)
        })
    }
    
    func info() -> OperativeSummaryLisboaDetailViewModel {
        let concept = self.concept()
        let attributedString = NSMutableAttributedString(string: concept, attributes: [.font: UIFont.santanderTextBold(size: 14)])
        return OperativeSummaryLisboaDetailViewModel(title: localized(key: "summary_item_concept").text, subtitle: attributedString, accessibilityIdentifier: "summary_item_concept")
    }
    
    func origin() -> OperativeSummaryLisboaDetailViewModel {
        let container: OnePayTransferOperativeData = containerParameter()
        let alias = container.productSelected?.accountEntity.alias ?? ""
        var amountString = ""
        if let amount = container.productSelected?.getAmountUI() {
            amountString = " (\(amount))"
        }
        let attributedString = NSMutableAttributedString(string: alias, attributes: [.font: UIFont.santanderTextBold(size: 14)])
        if hideAvailableAmount() {
            return OperativeSummaryLisboaDetailViewModel(title: localized(key: "summary_item_originAccount").text, subtitle: attributedString, accessibilityIdentifier: "summary_item_originAccount")
        }
        let string = NSMutableAttributedString(string: amountString, attributes: [NSAttributedString.Key.font: UIFont.santanderTextRegular(size: 14)])
        attributedString.append(string)
        return OperativeSummaryLisboaDetailViewModel(title: localized(key: "summary_item_originAccount").text, subtitle: attributedString, accessibilityIdentifier: "summary_item_originAccount")
    }
    
    func sendType() -> OperativeSummaryLisboaDetailViewModel {
        let container: OnePayTransferOperativeData = containerParameter()
        var type = ""
        switch container.subType {
        case .immediate:
            type = localized(key: "summary_label_immediate").text
        case .urgent:
            type = localized(key: "summary_label_express").text
        default:
            switch container.time {
            case .day?:
                type = localized(key: "summary_label_programmed").text
            case .periodic?:
                type = localized(key: "summary_label_periodic").text
            default:
                type = localized(key: "summary_label_standar").text
            }
        }
        var chargeAmountString = localized(key: "summary_label_noCommission").text
        if let value = container.bankChargeAmount?.value, value != 0, let chargeAmount = container.bankChargeAmount?.getFormattedAmountUI() {
            chargeAmountString = localized(key: "summary_label_commission", stringPlaceHolder: [StringPlaceholder(.value, chargeAmount)]).text
        }
        if hideSummaryCommissions() {
            return OperativeSummaryLisboaDetailViewModel(title: localized(key: "summary_item_sendType").text, subtitle: NSMutableAttributedString(string: type), accessibilityIdentifier: "summary_item_sendType")
        }
        return OperativeSummaryLisboaDetailViewModel(title: localized(key: "summary_item_sendType").text, subtitle: NSMutableAttributedString(string: type + " - " + chargeAmountString), accessibilityIdentifier: "summary_item_sendType")
    }
    
    func destination() -> OperativeSummaryLisboaDetailViewModel {
        let container: OnePayTransferOperativeData = containerParameter()
        let destination = container.name ?? ""
        return OperativeSummaryLisboaDetailViewModel(title: localized(key: "summary_label_destination").text,
                                                     subtitle: NSMutableAttributedString(string: destination),
                                                     accessibilityIdentifier: "summary_label_destination",
                                                     info: container.iban?.description,
                                                     baseUrl: self.baseURLProvider.baseURL)
    }
    
    func destinationCountry() -> OperativeSummaryLisboaDetailViewModel {
        let container: OnePayTransferOperativeData = containerParameter()
        let countryText: String = (container.country?.name ?? "") + " - " + (container.country?.currency ?? "")
        return OperativeSummaryLisboaDetailViewModel(title: localized(key: "summary_item_destinationCountry").text, subtitle: NSMutableAttributedString(string: countryText), accessibilityIdentifier: "summary_item_destinationCountry")
    }
    
    func mailExpenses() -> OperativeSummaryLisboaDetailViewModel {
        let container: OnePayTransferOperativeData = containerParameter()
        let mailExpenses = container.expensesAmount?.getFormattedAmountUI() ?? ""
        return OperativeSummaryLisboaDetailViewModel(title: localized(key: "summary_item_mailExpenses").text,
                                                     subtitle: NSMutableAttributedString(string: mailExpenses),
                                                     accessibilityIdentifier: "summary_item_mailExpenses")
    }
    
    func netAmount() -> OperativeSummaryLisboaDetailViewModel {
        let container: OnePayTransferOperativeData = containerParameter()
        let netAmount = container.netAmount?.getFormattedAmountUI() ?? ""
        return OperativeSummaryLisboaDetailViewModel(title: localized(key: "summary_item_amountToDebt").text,
                                                     subtitle: NSMutableAttributedString(string: netAmount),
                                                     accessibilityIdentifier: "summary_item_amountToDebt")
    }
    
    func transactionDate() -> OperativeSummaryLisboaDetailViewModel {
        let container: OnePayTransferOperativeData = containerParameter()
        let date = dependencies.timeManager.toString(date: container.issueDate, outputFormat: .dd_MMM_yyyy) ?? ""
        if showExecutionDateTitle() {
            return OperativeSummaryLisboaDetailViewModel(title: localized(key: "summary_item_executionDate").text,
                                                         subtitle: NSMutableAttributedString(string: date),
                                                         accessibilityIdentifier: "summary_item_issuerDate")
        }
        return OperativeSummaryLisboaDetailViewModel(title: localized(key: "summary_item_transactionDate").text,
                                                     subtitle: NSMutableAttributedString(string: date),
                                                     accessibilityIdentifier: "summary_item_issuerDate")
    }
    
    func issuanceDate() -> OperativeSummaryLisboaDetailViewModel {
        let container: OnePayTransferOperativeData = containerParameter()
        let date = dependencies.timeManager.toString(date: container.issueDate, outputFormat: .dd_MMM_yyyy) ?? ""
        return OperativeSummaryLisboaDetailViewModel(title: localized(key: "summary_item_issuanceDate").text,
                                                     subtitle: NSMutableAttributedString(string: date),
                                                     accessibilityIdentifier: "summary_item_issuerDate")
    }
    
    func startAndEndDate(startDate: Date, endDate: OnePayTransferTimeEndDate) -> OperativeSummaryLisboaDetailViewModel {
        let issueDate = dependencies.timeManager.toString(date: startDate, outputFormat: .dd_MMM_yyyy) ?? ""
        let endDateValue: String
        switch endDate {
        case .date(let date):
            endDateValue = dependencies.timeManager.toString(date: date, outputFormat: .dd_MMM_yyyy) ?? ""
        case .never:
            endDateValue = localized(key: "summary_label_indefinite").text
        }
        let attributedString = NSMutableAttributedString(string: periodicity() + "\n", attributes: [.font: UIFont.santanderTextBold(size: 14)])
        let string = NSMutableAttributedString(string: issueDate + " - " + endDateValue, attributes: [NSAttributedString.Key.font: UIFont.santanderTextRegular(size: 14),
                                                                                                      NSAttributedString.Key.foregroundColor: UIColor.grafite])
        attributedString.append(string)
        return OperativeSummaryLisboaDetailViewModel(title: localized(key: "summary_item_periodicity").text,
                                                     subtitle: attributedString,
                                                     accessibilityIdentifier: "summary_item_periodicity")
    }
    
    func concept() -> String {
        let container: OnePayTransferOperativeData = containerParameter()
        if let transferConcept = container.concept, !transferConcept.isEmpty {
            return transferConcept
        } else {
            switch container.time {
            case .day?, .periodic?:
                return localized(key: "onePay_label_genericProgrammed").text
            case .now?, nil:
                return localized(key: "onePay_label_notConcept").text
            }
        }
    }
    
    func periodicity() -> String {
        let container: OnePayTransferOperativeData = containerParameter()
        let periodicity: String
        switch container.time {
        case .day?:
            periodicity = localized(key: "summary_label_delayed").text
        case .periodic(_, _, let periodicityValue, _)?:
            switch periodicityValue {
            case .monthly: periodicity = localized(key: "summary_label_monthly").text
            case .quarterly: periodicity = localized(key: "summary_label_quarterly").text
            case .biannual: periodicity = localized(key: "summary_label_sixMonthly").text
            case .weekly: periodicity = localized(key: "summary_label_weekly").text
            case .bimonthly: periodicity = localized(key: "summary_label_bimonthly").text
            case .annual: periodicity = localized(key: "summary_label_annual").text
            }
        case .now?:
            periodicity = localized(key: "summary_label_timely").text
        default:
            periodicity = localized(key: "summary_label_standar").text
        }
        return periodicity
    }
        
    private func shareByText() {
        let share: ShareCase = .share(content: sharingText)
        share.show(from: view)
    }
    
    private func shareByImage() {
        guard let shareView = container?.operative.getSummaryImage() else { return }
        let share: ShareCase = .shareImage(content: shareView)
        share.show(from: view)
    }
    
    func manageCommissions(_ viewModels: inout [OperativeSummaryLisboaDetailViewModel]) {
        if let showCosts = self.dependencies.navigatorProvider.dependenciesEngine.resolve(forOptionalType: OnePayTransferModifierProtocol.self)?.showCostsForStandingOrders,
           showCosts,
           haveCommissions() {
            viewModels.append(mailExpenses())
        }
    }
    
    func haveCommissions() -> Bool {
        let operativeData: OnePayTransferOperativeData = containerParameter()
        guard let _ = operativeData.expensesAmount else {
            return false
        }
        return true
    }
}

extension OperativeSummaryLisboaPresenter: OpinatorLauncher {
    var baseWebViewNavigatable: BaseWebViewNavigatable {
        return navigator
    }
}

extension OperativeSummaryLisboaPresenter: PullOfferActionsPresenter {
    var presentationView: ViewControllerProxy {
        return view
    }
    
    var pullOffersActionsNavigator: PullOffersActionsNavigatorProtocol {
        return navigator
    }
}

extension OperativeSummaryLisboaPresenter: LocationsResolver {}

private extension OperativeSummaryLisboaPresenter {
    private func hideNetAmount() -> Bool {
        onePayTransferModifier?.hideNetAmount ?? false
    }
    
    private func hideAvailableAmount() -> Bool {
        onePayTransferModifier?.hideAvailableAmount ?? false
    }
    
    private func hideSummaryCommissions() -> Bool {
        onePayTransferModifier?.hideSummaryCommissions ?? false
    }
    
    private func showExecutionDateTitle() -> Bool {
        onePayTransferModifier?.showExecutionDateTitle ?? false
    }
    
    private func showDescriptionHeaderSummaryScreen() -> Bool {
        onePayTransferModifier?.showDescriptionHeaderSummaryScreen ?? true
    }
}
