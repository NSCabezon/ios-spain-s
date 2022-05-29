import CoreFoundationLib
import Foundation
import UI

protocol FinanceablePresenterProtocol: AnyObject {
    var view: FinanceableViewProtocol? { get set }
    func viewDidAppear()
    func didSelectOffer(_ viewModel: OfferEntityViewModel)
    func didSelectPreconceivedBanner(_ viewModel: OfferEntityViewModel)
    func didSelectSeeAllFinanceableTransactions(_ card: CardFinanceableViewModel?)
    func didSelectHireCard(_ location: PullOfferLocation?)
    func didPressTrick(index: Int)
    func didSelectSeeAllAccountFinanceableTransacations(_ account: AccountFinanceableViewModel)
    func didSelectAccountTransaction(_ transaction: AccountFinanceableTransactionViewModel)
    func trackPreconceivedBannerAppearance(offerId: String)
    func didSelectAdobeTargetOfferBanner(_ viewModel: AdobeTargetOfferViewModel)
    func didSelectPaymentBox(_ viewModel: FinanceableInfoViewModel.FractionalPaymentBoxViewModel)
    func didSelectGoToNextSettlement(_ viewModel: BankableCardReceiptViewModel)
}

enum FinanceableViewState {
    case loading
    case dataLoaded
}

final class FinanceablePresenter {
    weak var view: FinanceableViewProtocol?
    private let dependenciesResolver: DependenciesResolver
    private var easyPayTransactions: [EasyPayTransactionFinanceable] = []
    private var accountEasyPay: AccountEasyPay?
    private var offers: [PullOfferLocation: OfferEntity] = [:]
    private var cardTransactions: [CardTransactionEntity] = []
    private var trickViewModels: [TrickViewModel] = []
    private var state: FinanceableViewState = .loading
    private var managerResult: FinanceableInfoViewModel?
    lazy var getAllCardsSettlementsSuperUseCase: GetAllCardSettlementsSuperUseCase = {
        let superUseCase = self.dependenciesResolver.resolve(for: GetAllCardSettlementsSuperUseCase.self)
        superUseCase.delegate = self
        return superUseCase
    }()
    
    private var financeableManager: FinanceableManagerProtocol {
        dependenciesResolver.resolve(for: FinanceableManagerProtocol.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }

    var useCaseHandler: UseCaseHandler {
        self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }

    var coordinatorDelegate: FinancingCoordinatorDelegate {
        return self.dependenciesResolver.resolve(for: FinancingCoordinatorDelegate.self)
    }

    var coordinator: FinancingCoordinatorProtocol {
        return self.dependenciesResolver.resolve(for: FinancingCoordinatorProtocol.self)
    }

    var baseURLProvider: BaseURLProvider {
        return self.dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
}

extension FinanceablePresenter: FinanceablePresenterProtocol {
    func viewDidAppear() {
        switch self.state {
        case .loading: self.loadData()
        case .dataLoaded: break
        }
        trackScreen()
    }

    func didSelectOffer(_ viewModel: OfferEntityViewModel) {
        self.coordinatorDelegate.didSelectOffer(viewModel.offer)
    }

    func didSelectCard(_ viewModel: CardFinanceableViewModel) {  }

    func didSelectSeeAllFinanceableTransactions(_ card: CardFinanceableViewModel?) {
        trackEvent(.seeAllCards)
        self.coordinator.didSelectSeeAllFinanceableTransactions(card?.card)
    }

    func didSelectHireCard(_ location: PullOfferLocation?) {
        self.coordinatorDelegate.didSelectHireCard(location)
    }

    func didPressTrick(index: Int) {
        guard !self.trickViewModels.isEmpty else { return }
        self.view?.showFinancingTricksCurtainView(viewModels: self.trickViewModels, index: index)
    }

    func didSelectSeeAllAccountFinanceableTransacations(_ account: AccountFinanceableViewModel) {
        trackEvent(.seeAllAccounts)
        self.coordinator.didSelectSeeAllAccountFinanceableTransactions(account.account)
    }

    func didSelectAccountTransaction(_ transaction: AccountFinanceableTransactionViewModel) {
        trackEvent(.accountDetail)
        self.coordinatorDelegate.didSelectOffer(transaction.offer?.offer)
    }

    func trackPreconceivedBannerAppearance(offerId: String) {
        self.trackEvent(.viewPromotion, parameters: [.offerId: offerId])
    }

    func didSelectPreconceivedBanner(_ viewModel: OfferEntityViewModel) {
        trackEvent(.selectContent, parameters: [.offerId: viewModel.offer.id ?? ""])
        self.didSelectOffer(viewModel)
    }
    
    func didSelectAdobeTargetOfferBanner(_ viewModel: AdobeTargetOfferViewModel) {
       trackEvent(.promoClick)
       self.coordinatorDelegate.didSelectAdobeTargetOffer(viewModel)
   }
    
    func didSelectPaymentBox(_ viewModel: FinanceableInfoViewModel.FractionalPaymentBoxViewModel) {
        switch viewModel.paymentType {
        case .creditCard:
            self.coordinator.didSelectSeeAllFinanceableTransactions(nil)
            trackEvent(.fractionateCreditCardPayments)
        case .transfers:
            self.coordinatorDelegate.didSelectShowFractionablePayments(viewModel.paymentType)
            trackEvent(.fractionateTransfers)
        case .receipts:
            self.coordinatorDelegate.didSelectShowFractionablePayments(viewModel.paymentType)
            trackEvent(.fractionateBills)
        case .purchases:
            self.coordinatorDelegate.didSelectShowFractionablePayments(viewModel.paymentType)
            trackEvent(.fractionatePurchases)
        }
    }
    
    func didSelectGoToNextSettlement(_ viewModel: BankableCardReceiptViewModel) {
        let localAppConfig: AppConfigRepositoryProtocol = dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        let enableMap = localAppConfig.getBool(CardConstants.isEnableCardsHomeLocationMap) ?? false
        guard let card = viewModel.cardEntity, let detail = viewModel.cardDetailSettlement else { return }
        self.coordinator.didSelectGoToNextSettlementFor(card,
                                                        cardSettlementDetailEntity: detail,
                                                        isEnabledMap: enableMap)
        self.trackEvent(.financeCardReceipt)
    }
}

private extension FinanceablePresenter {
    func loadData() {
        view?.setLoadingView { [weak self] in
            self?.financeableManager.fetch { [weak self] result, info in
                self?.state = .dataLoaded
                self?.showFinanceableViews(result)
                self?.view?.hideLoadingView {
                    self?.loadOffers(info) {
                        self?.loadFinancingTricks(result.tricks)
                    }
                }
            }
        }
    }
    
    func loadOffers(_ firstFectchInfo: FinanceableInfo, completion: @escaping() -> Void) {
        self.financeableManager.fetchOffers(firstFectchInfo: firstFectchInfo) { [weak self] result in
            self?.setFinanceableOffersSectionIfNeeded(result)
            if result.adobeTarget != nil {
                self?.trackEvent(.promoView)
            }
            completion()
        }
    }

    func loadFinancingTricks(_ infoTricks: FinanceableInfoViewModel.Tricks?) {
        guard let infoTricks = infoTricks else {
            self.view?.hideFinancingTricks()
            return
        }
        self.loadFinancingTrick(infoTricks.tricks)
    }

    func loadFinancingTrick(_ tricks: [TrickEntity]) {
        let baseUrl = self.baseURLProvider.baseURL
        self.trickViewModels = tricks.map {
            TrickViewModel(entity: $0, baseUrl: baseUrl)
        }
        self.view?.showFinancingTricks(self.trickViewModels)
    }
    
    // MARK: Show FinanceableViews sorted  
    func showFinanceableViews(_ viewModel: FinanceableInfoViewModel) {
        setTitleView()
        setFractionalPaymentsView(viewModel)
        setCardSettlementsView(viewModel)
    }
    
    func setTitleView() {
        view?.setTitleView()
    }
    
    func setFractionalPaymentsView(_ viewModel: FinanceableInfoViewModel) {
        view?.setFractionalPaymentsView(viewModel)
    }
    
    func setCardSettlementsView(_ viewModel: FinanceableInfoViewModel) {
        let cards = viewModel.cardsCarousel.cards.filter { $0.isCardContractHolder && !$0.isTemporallyOff }
        guard cards.isNotEmpty else { return }
        view?.setCardCarouselView()
        getAllCardsSettlementsSuperUseCase.executeWith(cards: viewModel.cardsCarousel.cards)
    }
    
    func setFinanceableOffersSectionIfNeeded(_ viewModel: FinanceableInfoViewModel) {
        guard viewModel.robinsonOffer != nil
                || viewModel.preconceivedBanner != nil
                || viewModel.commercialOffers != nil
                || viewModel.adobeTarget != nil
        else {
            return
        }
        view?.setFinanceableOfferSectionView(
            viewModel,
            baseUrl: baseURLProvider.baseURL
        )
    }
}
extension FinanceablePresenter: AutomaticScreenActionTrackable {
    var trackerPage: FinancingPage {
        return FinancingPage()
    }

    var trackerManager: TrackerManager {
        return self.dependenciesResolver.resolve(for: TrackerManager.self)
    }
}

extension FinanceablePresenter: GetAllCardsSettlementsSuperUseCaseDelegate {
    func didFinishGetCardsSettlementsSuccessfully(with cardSettlementsData: [GetCardsSettlementsOutput]) {
        guard cardSettlementsData.isNotEmpty else { showEmptySettlements(); return }
        let bankableReceiptCardData = cardSettlementsData
            .filter({ $0.cardSettlementDetailEntity.totalAmount.value != 0.0 })
            .compactMap {
                BankableCardReceiptViewModel(
                    cardDetailSettlement: $0.cardSettlementDetailEntity,
                    cardEntity: $0.cardEntity,
                    baseUrl: baseURLProvider.baseURL,
                    timeManager: dependenciesResolver.resolve(for: TimeManager.self))
            }
        view?.setBankableCardReceiptsView(bankableReceiptCardData)
    }

    func didFinishWithError(error: String?) {
        showEmptySettlements()
    }
    
    func showEmptySettlements() {
        view?.setBankableCardReceiptsView([])
    }
}
