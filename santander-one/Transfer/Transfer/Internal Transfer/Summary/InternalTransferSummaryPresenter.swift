//
//  InternalTransferSummaryPresenter.swift
//  Transfer
//
//  Created by Jose Carlos Estela Anguita on 14/01/2020.
//

import CoreFoundationLib
import Foundation
import Operative
import PdfCommons

class InternalTransferSummaryPresenter {
    let dependenciesResolver: DependenciesResolver
    weak var view: OperativeSummaryViewProtocol?
    var container: OperativeContainerProtocol?
    var isBackButtonEnabled: Bool = false
    var isCancelButtonEnabled: Bool = false
    var number: Int = 0
    lazy var operativeData: InternalTransferOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    private lazy var internalTransferModifier = self.dependenciesResolver.resolve(forOptionalType: InternalTransferModifierProtocol.self)
    
    private let pdfCreator = PDFCreator()
    private var offers: [PullOfferLocation: OfferEntity] = [:]
    private var offerConditions: [PullOfferLocation: Bool] = [:]
    
    private var locations: [PullOfferLocation] {
        return PullOffersLocationsFactoryEntity.internalTransferSummary
    }
    
    private var useCaseHandler: UseCaseHandler {
        return dependenciesResolver.resolve()
    }
    
    private var pullOfferUseCase: GetPullOffersUseCase {
        return dependenciesResolver.resolve()
    }
    
    private var getHasOneProductsUseCase: GetHasOneProductsUseCase {
        return self.dependenciesResolver.resolve()
    }

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    func buildContent() -> [OperativeSummaryStandardBodyItemViewModel] {
        let builder = InternalTransferSummaryContentBuilder(operativeData: self.operativeData, dependenciesResolver: self.dependenciesResolver)
        guard let internalTransferModifier = internalTransferModifier else {
            return getSummaryContent(for: builder)
        }
        return getSummaryContent(for: builder, transferModifier: internalTransferModifier)
    }
    
    func buildLocations() -> [OperativeSummaryStandardLocationViewModel] {
        guard let offerAction = container?.coordinator.executeOffer else { return [] }
        let builder = OperativeSummaryStandardLocationBuilder(offers: offers, offerConditions: offerConditions)
        builder.addPaymentLocation(executeOfferAction: offerAction)
        return builder.build()
    }
    
    func buildFooter() -> [OperativeSummaryStandardFooterItemViewModel] {
        let builder = InternalTransferSummaryFooterBuilder(operativeData: self.operativeData)
        builder.addGoToSendMoney(action: goToSendMoney)
        builder.addGoToGlobalPosition(action: goToGlobalPosition)
        builder.addGoToOpinator(action: goToOpinator)
        return builder.build()
    }
    
    func buildActions() -> [OperativeSummaryStandardBodyActionViewModel] {
        let builder = InternalTransferSummaryActionsBuilder(operativeData: self.operativeData)
        builder.addDownloadPdf(action: showPdf)
        builder.addShare(action: showShare)
        return builder.build()
    }
    
    // MARK: - Actions
    
    func goToGlobalPosition() {
        let finishingOption = InternalTransferOperative.FinishingOption.globalPosition
        self.container?.save(finishingOption)
        self.container?.stepFinished(presenter: self)
    }
    
    func goToSendMoney() {
        let finishingOption = InternalTransferOperative.FinishingOption.sendMoney
        self.container?.save(finishingOption)
        self.container?.stepFinished(presenter: self)
    }
    
    func goToOpinator() {
        guard let opinatorCapable = self.container?.operative as? OperativeOpinatorCapable & Operative else { return }
        opinatorCapable.showOpinator()
        self.trackEvent(.opinator, parameters: [
            .scheduledTransferType: self.operativeData.time?.trackerDescription ?? ""
        ])
    }
    
    func showPdf() {
        guard let container = self.container else { return }
        let operativeData: InternalTransferOperativeData = container.get()
        guard
            let originAccount = operativeData.selectedAccount,
            let destinationAccount = operativeData.destinationAccount,
            let time = operativeData.time
        else {
            return
        }
        let pdf = self.buildPDF(originAccount: originAccount, destinationAccount: destinationAccount, time: time, operativeData: operativeData)
        self.pdfCreator.createPDF(
            html: pdf,
            completion: { data in
                self.container?.coordinator.handleWebView(with: data, title: "toolbar_title_detailTransfer")
            },
            failed: {}
        )
        self.trackEvent(.pdf, parameters: [
            .scheduledTransferType: self.operativeData.time?.trackerDescription ?? ""
        ])
    }
    
    func showShare() {
        self.container?.coordinator.share(self, type: .text)
        self.trackEvent(.share, parameters: [
            .scheduledTransferType: self.operativeData.time?.trackerDescription ?? ""
        ])
    }
}

extension InternalTransferSummaryPresenter: Shareable {
    
    func getShareableInfo() -> String {
        return self.buildContent().reduce("") { text, viewModel in
            return text + viewModel.title + " " + viewModel.subTitle.string + "\n"
        }
    }
}

extension InternalTransferSummaryPresenter: OperativeSummaryPresenterProtocol {
    var isBackable: Bool { false }
    var shouldShowProgressBar: Bool { false }
    
    func viewDidLoad() {
        self.loadLocations()
        self.trackScreen()
    }
}

private extension InternalTransferSummaryPresenter {
    func loadLocations() {
        let input = GetPullOffersUseCaseInput(locations: locations)
        UseCaseWrapper(
            with: self.pullOfferUseCase.setRequestValues(requestValues: input),
            useCaseHandler: useCaseHandler,
            onSuccess: { [weak self] result in
                guard let self = self else { return }
                self.offers = result.pullOfferCandidates
                self.evaluateLocations()
        })
    }
    
    func evaluateLocations() {
        guard let (location, _) = self.offers.location(key: TransferPullOffers.paymentSummary) else {
            self.buildSummary()
            return
        }
        
        self.view?.showLoading()
        hasPaymentOneProduct { [weak self] result in
            guard let self = self else { return }
            self.offerConditions[location] = result
            self.view?.dismissLoading {
                self.buildSummary()
            }
        }
    }
    
    func hasPaymentOneProduct(_ completion: @escaping (Bool) -> Void) {
        let input = GetHasOneProductsUseCaseInput(product: \.paymentOneProducts)
        UseCaseWrapper(
            with: getHasOneProductsUseCase.setRequestValues(requestValues: input),
            useCaseHandler: useCaseHandler,
            onSuccess: { result in
                completion(result.hasOneProduct)
            }, onError: { _ in
                completion(false)
            })
    }
    
    func buildSummary() {
        self.view?.setupStandardHeader(
            with: OperativeSummaryStandardHeaderViewModel(
                image: "icnOkSummary",
                title: localized("summe_title_perfect"),
                description: localized("summary_label_sentMoneyOk"),
                extraInfo: nil
            )
        )
        self.view?.setupStandardBody(
            withItems: self.buildContent(),
            locations: self.buildLocations(),
            actions: self.buildActions(),
            collapsableSections: .defaultCollapsable(visibleSections: 2)
        )
        self.view?.setupStandardFooterWithTitle(localized("summary_label_nowThat"), items: self.buildFooter())
        self.view?.build()
    }
}

// MARK: - PDF

extension InternalTransferSummaryPresenter {
    func buildPDF(originAccount: AccountEntity, destinationAccount: AccountEntity, time: TransferTime, operativeData: InternalTransferOperativeData) -> String {
        let date: Date = {
            switch time {
            case .now:
                return Date()
            case .day(let day):
                return day
            case .periodic(let startDate, _, _, _):
                return startDate
            }
        }()
        let timeManager = dependenciesResolver.resolve(for: TimeManager.self)
        let builder = TransferPDFBuilder(stringLoader: dependenciesResolver.resolve(for: StringLoader.self), timeManager: timeManager)
        builder.addHeader(title: "pdf_title_summaryTransfer", office: nil, date: date)
        builder.addAccounts(originAccount: originAccount, destinationAccount: destinationAccount, dependenciesResolver: self.dependenciesResolver)
        builder.addTransferInfo([
            (key: "summary_item_amount", value: operativeData.amount),
            (key: "summary_item_concept", value: operativeData.concept.map({ $0.isEmpty ? localized("onePay_label_notConcept") : $0 })),
            (key: "summary_item_periodicity", value: time.isPeriodic() ? operativeData.time.map(periodicity) : nil),
            (key: "summary_item_transactionDate", value: !time.isPeriodic() ? timeManager.toString(date: operativeData.internalTransfer?.issueDate, outputFormat: .dd_MMM_yyyy) : nil),
            (key: "summary_item_startDate", value: time.isPeriodic() ? timeManager.toString(date: operativeData.internalTransfer?.issueDate, outputFormat: .dd_MMM_yyyy) : nil),
            (key: "summary_item_endDate", value: time.isPeriodic() ? endDate(time) : nil)
        ])
        builder.addExpenses([
            (key: "summary_item_commission", value: operativeData.internalTransfer?.bankChargeAmount),
            (key: "summary_item_mailExpenses", value: operativeData.internalTransfer?.expensesAmount),
            (key: "summary_item_amountToDebt", value: operativeData.internalTransfer?.netAmount)
        ])
        return builder.build()
    }
    
    func periodicity(_ periodicity: TransferTime) -> String {
        guard let container = self.container else { return localized("summary_label_standar") }
        let operativeData: InternalTransferOperativeData = container.get()
        let periodicity: String
        switch operativeData.time {
        case .day?:
            periodicity = localized("summary_label_delayed")
        case .periodic(_, _, let periodicityValue, _)?:
            periodicity = localized(periodicityValue.periodicity)
        case .now?:
            periodicity = localized("summary_label_standar")
        default:
            periodicity = localized("summary_label_standar")
        }
        return periodicity
    }
    
    func endDate(_ time: TransferTime) -> String? {
        let timeManager = dependenciesResolver.resolve(for: TimeManager.self)
        let issueDate: String?
        switch time {
        case .periodic(_, let endDate, _, _):
            switch endDate {
            case .never:
                issueDate = localized("detailsOnePay_label_indefinite")
            case .date(let endDate):
                issueDate = timeManager.toString(date: endDate, outputFormat: .dd_MMM_yyyy) ?? ""
            }
        default:
            issueDate = nil
        }
        return issueDate
    }
}

extension InternalTransferSummaryPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: InternalTransferSummaryPage {
        return InternalTransferSummaryPage()
    }
    
    func getTrackParameters() -> [String: String]? {
        return [
            TrackerDimension.amount.key: self.operativeData.amount?.getFormattedTrackValue() ?? "",
            TrackerDimension.currency.key: self.operativeData.amount?.currencyTrack ?? "",
            TrackerDimension.scheduledTransferType.key: self.operativeData.time?.trackerDescription ?? ""
        ]
    }
}

private extension InternalTransferSummaryPresenter {
    func getSummaryContent(for builder: InternalTransferSummaryContentBuilder) -> [OperativeSummaryStandardBodyItemViewModel] {
        builder.addAmountAndConcept()
        builder.addTransferType()
        builder.addOriginAccount()
        builder.addDestinationAccount()
        builder.addMailExpenses()
        builder.addTotalAmount()
        builder.addDate()
        return builder.build()
    }
    
    func getSummaryContent(for builder: InternalTransferSummaryContentBuilder, transferModifier: InternalTransferModifierProtocol) -> [OperativeSummaryStandardBodyItemViewModel] {
        return transferModifier.getSummaryContent(for: builder)
    }
}
