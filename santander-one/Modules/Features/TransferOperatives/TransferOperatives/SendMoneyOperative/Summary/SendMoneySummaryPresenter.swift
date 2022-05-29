//
//  SendMoneySummaryPresenter.swift
//  Transfer
//
//  Created by David Gálvez Alonso on 21/07/2021.
//

import Operative
import CoreFoundationLib
import CoreDomain

protocol SendMoneySummaryPresenterProtocol: OperativeStepPresenterProtocol {
    var view: SendMoneySummaryView? { get set }
    var transferAmount: String { get }
    func viewDidLoad()
    func close()
    func didTapOnOpinatorView()
    func didTapOnSeeSummary()
    func didTapOnFinancingButton()
}

class SendMoneySummaryPresenter {
    var number: Int = 0
    var isBackButtonEnabled: Bool = false
    var isCancelButtonEnabled: Bool = true
    var shouldShowProgressBar: Bool = false
    var container: OperativeContainerProtocol?
    weak var view: SendMoneySummaryView?
    let dependenciesResolver: DependenciesResolver
    private var pullOffer: OfferRepresentable?
    
    lazy var operativeData: SendMoneyOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    func getSummaryItems() -> [OneListFlowItemViewModel] {
        fatalError("Implement in childs")
    }
    
    func setupTransferAmount() {
        fatalError("Implement in childs")
    }
    
    func getCostWaringLabel() -> String? {
        return nil
    }
}

extension SendMoneySummaryPresenter: SendMoneySummaryPresenterProtocol {
    var transferAmount: String {
        guard let amount = self.operativeData.amount else { return "" }
        let decorator = AmountRepresentableDecorator(amount, font: .typography(fontName: .oneB100Bold))
        return decorator.getStringValue()
    }

    func viewDidLoad() {
        self.setupSummary()
        self.setupTransferAmount()
        self.setupSharing()
        self.setupFooter()
        self.setupHeader()
        self.setupCostWarning()
        self.loadOffer()
        self.trackScreen()
    }

    func close() {
        self.container?.close()
    }

    func didTapOnOpinatorView() {
        self.showOpinator()
    }
    
    func didTapOnSeeSummary() {
        self.trackerManager.trackEvent(screenId: self.trackerPage.page,
                                       eventId: SendMoneySummaryPage.Action.seeSummary.rawValue,
                                       extraParameters: self.operativeData.type == .national ? ["transfer_country" : self.operativeData.type.trackerName] : [:])
    }
    
    func didTapOnFinancingButton() {
        self.executeOffer()
        self.trackerManager.trackEvent(screenId: self.trackerPage.page,
                                       eventId: SendMoneySummaryPage.Action.seeFinancingOptions.rawValue,
                                       extraParameters: ["transfer_country" : self.operativeData.type.trackerName])
    }
}

private extension SendMoneySummaryPresenter {
    // MARK: - Private logic
    func showOpinator() {
        guard let opinatorCapable = self.container?.operative as? OperativeOpinatorCapable & Operative else { return }
        opinatorCapable.showOpinator()
    }
    
    func setupCostWarning() {
        self.view?.addCostsWarningWith(labelValue: self.getCostWaringLabel())
    }

    // MARK: - Sharing Buttons
    func didTapOnSharePDF() {
        // TODO: Future story by each country
        self.view?.showComingSoon()
        self.trackerManager.trackEvent(screenId: self.trackerPage.page,
                                       eventId: SendMoneySummaryPage.Action.fileDownload.rawValue,
                                       extraParameters: self.operativeData.type == .national ? ["transfer_country" : self.operativeData.type.trackerName] : [:])
    }

    func didTapOnShareImage() {
        guard let shareCapable = self.container?.operative as? ShareOperativeCapable else { return }
        shareCapable.getShareView(completion: { [weak self] result in
            switch result {
            case .success((let shareView, let view)):
                guard let self = self, let shareView = shareView, let containerView = view else { return }
                self.trackerManager.trackEvent(screenId: self.trackerPage.page,
                                               eventId: SendMoneySummaryPage.Action.share.rawValue,
                                               extraParameters: self.operativeData.type == .national ? ["transfer_country" : self.operativeData.type.trackerName] : [:])
                self.container?.coordinator.share(self, type: .image(shareView, containerView))
            case .failure:
                return
            }
        })
    }

    // MARK: - Footer
    func didTapOnSendMoney() {
        let finishingOption = SendMoneyOperative.FinishingOption.sendMoney
        self.container?.save(finishingOption)
        self.container?.stepFinished(presenter: self)
    }

    func didTapOnGlobalPosition() {
        let finishingOption = SendMoneyOperative.FinishingOption.globalPosition
        self.container?.save(finishingOption)
        self.container?.stepFinished(presenter: self)
    }

    func didTapOnHelp() {
        self.showOpinator()
    }

    // MARK: - Config
    func setupSummary() {
        let items = self.getSummaryItems()
        self.view?.setSummaryItems(items)
    }

    func setupSharing() {
        let builder = SendMoneySummaryContentBuilder(dependenciesResolver: self.dependenciesResolver, operativeData: self.operativeData)
        builder.addPDFSharing(action: self.didTapOnSharePDF)
        builder.addImageSharing(action: self.didTapOnShareImage)
        let buttons = builder.buildSharingButtons()
        self.view?.setSharingButtons(pdf: buttons[0], image: buttons[1])
    }

    func setupFooter() {
        let builder = SendMoneySummaryContentBuilder(dependenciesResolver: self.dependenciesResolver, operativeData: self.operativeData)
        builder.addSendMoney(action: self.didTapOnSendMoney)
        builder.addGlobalPosition(action: self.didTapOnGlobalPosition)
        builder.addHelp(action: self.didTapOnHelp)
        self.view?.setFooterViewModel(builder.buildFooter())
    }
    
    func setupHeader() {
        guard let summaryState = self.operativeData.summaryState else {
            return
        }
        self.view?.setHeader(summaryState)
    }
    
    func trackScreen() {
        let extraParameters: [String : String] = {
            var parameters = ["transaction_currency" : self.operativeData.currency?.name ?? "" ,
                                     "scheduled_transfer_type" : "\(self.operativeData.transferDateType ?? .day)",
                                     "transfer_type" : "\(self.operativeData.selectedTransferType?.type.serviceString ?? "INTERNAL")"]
            if self.operativeData.type == .national {
                parameters["transfer_country"] = self.operativeData.type.trackerName
            } else {
                guard let amount = self.operativeData.amount?.value else { return parameters }
                parameters["transaction_amount"] = "\(amount)"
            }
            return parameters
        }()
        self.trackerManager.trackScreen(screenId: self.trackerPage.page,
                                        extraParameters: extraParameters)
    }
}

extension SendMoneySummaryPresenter: Shareable {
    func getShareableInfo() -> String {
        return ""
    }
}

//MARK: - AutomaticScreenTrackable

extension SendMoneySummaryPresenter: AutomaticScreenTrackable {
    var trackerManager: TrackerManager {
        self.dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: SendMoneySummaryPage {
        SendMoneySummaryPage(national: self.operativeData.type == .national, type: self.operativeData.type.trackerName)
    }
}


//MARK: - Financiable

extension SendMoneySummaryPresenter {
    
    var getPullOffersCandidatesUseCase: GetPullOffersUseCase {
        self.dependenciesResolver.resolve()
    }

    func loadOffer() {
        guard operativeData.easyPayFundableType != .notAllowed else {
            return
        }
        self.view?.showLoading()
        let location: [PullOfferLocation] = PullOffersLocationsFactoryEntity().sendMoneyEasyPay
        Scenario(useCase: getPullOffersCandidatesUseCase,
                 input: GetPullOffersUseCaseInput(locations: location))
            .execute(on: dependenciesResolver.resolve())
            .onSuccess { [weak self] result in
                guard let strongSelf = self else { return }
                strongSelf.view?.hideLoading()
                strongSelf.showFinancigTagOffer(pullOffersCandidates: result.pullOfferCandidates)
            }
            .onError { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.view?.hideLoading()
            }
    }
    
    func showFinancigTagOffer(pullOffersCandidates: [PullOfferLocation: OfferRepresentable]) {
        switch operativeData.easyPayFundableType {
        case .low:
            let offer = pullOffersCandidates.first(where: { (key, _) in
                return key.stringTag == SendMoneyOperativePullOffers.lowEasyPayAmount
            })
            self.pullOffer = offer?.value
        case .high:
            let offer = pullOffersCandidates.first(where: { (key, _) in
                return key.stringTag == SendMoneyOperativePullOffers.highEasyPayAmount
            })
            self.pullOffer = offer?.value
        case .notAllowed:
            break
        }
        guard self.pullOffer != nil else {
            return
        }
        self.view?.showFinancingViews()
    }
    
    func executeOffer() {
        guard let offer = self.pullOffer else { return }
        self.container?.coordinator.executeOffer(offer)
    }
}

