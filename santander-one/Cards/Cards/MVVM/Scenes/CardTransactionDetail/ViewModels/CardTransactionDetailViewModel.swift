//
//  CardTransactionDetailViewModel.swift
//  Cards
//
//  Created by Hernán Villamil on 30/3/22.
//

import UI
import Foundation
import OpenCombine
import CoreDomain
import CoreFoundationLib

typealias PullOffersLoadedOutput = (offers: [PullOfferLocation: OfferRepresentable],
                                    item: CardTransactionViewItemRepresentable)
typealias FirstFeeInfoInput = (numberOfFees: Int,
                               card: CardRepresentable,
                               transactionBalanceCode: String?,
                               transactionDay: String?,
                               numberOfMonths: Int)
typealias FirstFeeInfoOutput = (cuoteFee: FeesInfoRepresentable,
                                numberOfMonths: Int)

enum CardTransactionDetailState: State {
    case idle
    case didLoadTransactions([CardTransactionViewItemRepresentable])
    case didSelectTransaction(CardTransactionViewItemRepresentable)
    case loadTransactionDetail(CardTransactionViewItemRepresentable)
    case loadPullOffers(CardTransactionViewItemRepresentable)
    case loadTransactionDetailEasyPay(CardTransactionViewItemRepresentable)
    case loadMinEasyPayAmount(CardTransactionViewItemRepresentable)
    case loadCardMovementLocation(CardTransactionViewItemRepresentable)
    case loadEasyPayFee(CardTransactionViewItemRepresentable)
    case didLoadminAmountEasyPay(Double)
    case didloadDetailEasyPay(EasyPay)
    case didLoadFeeEasyPay(FeeDataRepresentable?)
    case loadDetailViewConfiguration(CardTransactionViewItemRepresentable)
    case didLoadDetailViewConfiguration([CardTransactionDetailViewConfigurationRepresentable])
    case didLoadDetail(CardTransactionViewItemRepresentable)
    case didLoadTransactionLocation(CardTransactionDetailLocationRepresentable)
    case didLoadTransactionNoLocalizable
    case didLoadTransactionTemporallyNotLocalizable
    case removeFractionatedPayment
    case didLoadFractionatedPayment(FractionatePaymentItem)
    case loadFirstFeeInfoEasyPay(FirstFeeInfoInput)
    case updateItem(CardTransactionViewItemRepresentable)
    case loadActions(CardTransactionViewItemRepresentable)
    case didLoadActions([CardActions])
    case notAvailable
}

final class CardTransactionDetailViewModel: DataBindable {
    private let dependencies: CardTransactionDetailDependenciesResolver
    private var subscriptions: Set<AnyCancellable> = []
    private var currentItem: CardTransactionViewItemRepresentable?
    private var offers: [PullOfferLocation: OfferRepresentable] = [:]
    private var movementLocation: CardMapItemRepresentable?
    private var location: PullOfferLocation {
        PullOfferLocation(stringTag: CardsPullOffers.movCardDetails,
                          hasBanner: true,
                          pageForMetrics: trackerPage.page)
        
    }
    private let fractionItem = FractionatePaymentItem()
    private var cuotesFees = [FeesInfoRepresentable]()
    private var getCardTransactionDetailUseCase: CardTransactionDetailUseCase {
        dependencies.external.resolve()
    }
    private var getTransactionDetailEasyPayUseCase: GetTransactionDetailEasyPayUseCase {
        dependencies.external.resolve()
    }
    private var getSingleCardMovementLocationUseCase: GetSingleCardMovementLocationUseCase {
        dependencies.external.resolve()
    }
    private var getMinEasyPayAmountUseCase: GetMinEasyPayAmountUseCase {
        dependencies.external.resolve()
    }
    private var getCandidateOfferUseCase: GetCandidateOfferUseCase {
        dependencies.external.resolve()
    }
    private var getFeesEasypayUseCase: GetFeesEasypayUseCase {
        dependencies.external.resolve()
    }
    private var getCardTransactionDetailViewConfigurationUseCase: GetCardTransactionDetailViewConfigurationUseCase {
        dependencies.external.resolve()
    }
    private var getFirstFeeInfoEasyPay: FirstFeeInfoEasyPayReactiveUseCase {
        dependencies.external.resolve()
    }
    private var getCardTransactionDetailActionsUseCase: GetCardTransactionDetailActionsUseCase {
        dependencies.external.resolve()
    }
    private var timeManager: TimeManager {
        dependencies.external.resolve()
    }
    private let stateSubject = CurrentValueSubject<CardTransactionDetailState, Never>(.idle)
    var state: AnyPublisher<CardTransactionDetailState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
    @BindingOptional private var configurationData: CardTransactionDetailConfiguration?
    
    private var coordinator: CardTransactionDetailCoordinator {
        return dependencies.cardTransactionDetailCoordinator()
    }
    
    init(dependencies: CardTransactionDetailDependenciesResolver) {
        self.dependencies = dependencies
    }
    
    func viewDidLoad() {
        trackScreen()
        subscribe()
        checkConfigurationData()
    }
}

// MARK: - Actions
extension CardTransactionDetailViewModel {
    func didSelectGoBack() {
        coordinator.dismiss()
    }
    
    func didSelectOpenMenu() {
        coordinator.openMenu()
    }
    
    func didSelectTransaction(_ transaction: CardTransactionRepresentable?) {
        guard let card = configurationData?.selectedCard.representable,
              let showAmountBackground = configurationData?.showAmountBackground,
              let selectedTransacion = transaction
        else { return }
        let item = CardTransactionItem(card: card,
                                       transaction: selectedTransacion,
                                       showAmountBackground: showAmountBackground)
        currentItem = item
        stateSubject.send(.didSelectTransaction(item))
        stateSubject.send(.loadPullOffers(item))
    }
    
    func didSelectFractionate() {
        guard let item = currentItem else { return }
        coordinator.goToEasyPay(card: item.card,
                                transaction: item.transaction,
                                easyPayOperativeDataEntity: nil)
    }
    
    func didSelectMap() {
        trackEvent(.map, parameters: nil)
        guard let item = currentItem,
        let configuration = item.configuration else { return }
        if configuration.isEnabledMap,
           item.transactionDetail != nil,
           let movementLocation = movementLocation {
            let mapTypeConfiguration = CardMapTypeConfiguration.one(location: movementLocation)
            coordinator.goToMapView(card: item.card,
                                    type: mapTypeConfiguration)
        } else {
            stateSubject.send(.notAvailable)
        }
    }
    
    func didSelectOffer(item: CardTransactionViewItemRepresentable) {
        guard let offer = offers.location(key: CardsPullOffers.movCardDetails) else { return }
        coordinator.goToOffer(offer: offer.offer)
    }
    
    func didSelectMonthlyFee(_ monthlyFee: MontlyPaymentFeeItem?) {
        if monthlyFee?.entity != nil {
            guard let item = currentItem else { return }
            coordinator.goToEasyPay(card: item.card,
                                    transaction: item.transaction,
                                    easyPayOperativeDataEntity: nil) // check easy pay in new artchitecture.
        } else {
            didSelectFractionate()
        }
    }
}

private extension CardTransactionDetailViewModel {
    func checkConfigurationData() {
        guard let card = configurationData?.selectedCard.representable,
              let transaction = configurationData?.selectedTransaction.dto,
              let showAmountBackground = configurationData?.showAmountBackground,
              let allTransactions = configurationData?.allTransactions
                .map({ $0.dto })
        else { return }
        stateSubject.send(.didLoadTransactions(allTransactions.map({CardTransactionItem(card: card,
                                                                                       transaction: $0,
                                                                                       showAmountBackground: showAmountBackground)})))
        didSelectTransaction(transaction)
    }
    
    func getLocationForMapWith(_ location: CardMovementLocationRepresentable,
                               showMapButton: Bool,
                               title: String? = nil) -> CardTransactionDetailLocationRepresentable {
        return CardTransactionDetailLocationItem(title: title ?? location.concept,
                                                 address: location.address,
                                                 location: location.location,
                                                 postalCode: location.postalCode,
                                                 category: location.category,
                                                 showMapButton: showMapButton)
    }
    
    func validateFractionatedPayment(_ item: CardTransactionViewItemRepresentable) {
        guard let configuration = item.configuration,
              !configuration.isEasyPayClassicEnabled && configuration.enableEasyPayCards,
              item.feeData != nil,
              let amount = item.transaction.amountRepresentable?.value,
              let numberOfMonths = fractionItem.getNumberOfMonthsForQuoteCalculation(amount: amount,
                                                                                     isAllInOneCard: isAllInOneCard(item.card))
        else {
            stateSubject.send(.removeFractionatedPayment)
            return
        }
        cuotesFees = []
        numberOfMonths.forEach { (month) in
            let input = FirstFeeInfoInput(numberOfFees: month,
                                          card: item.card,
                                          transactionBalanceCode: item.contract?.balanceCode,
                                          transactionDay: item.contract?.transactionDay,
                                          numberOfMonths: numberOfMonths.count)
            stateSubject.send(.loadFirstFeeInfoEasyPay(input))
        }
    }
    
    func isAllInOneCard(_ card: CardRepresentable?) -> Bool {
        guard let cardType = card?.productSubtypeRepresentable?.productType,
              let cardSubType = card?.productSubtypeRepresentable?.productSubtype else {
                  return false
              }
        let candidatesTypes = ["501", "502"]
        let candidatesSubtype = ["665", "699", "608", "620", "694"]
        return candidatesTypes.contains(cardType) && candidatesSubtype.contains(cardSubType)
    }
    
    func prepareFractionPayment() {
        currentItem?.isFractioned = false
        updateTransactionWithItem(currentItem)
        var sortedFees = cuotesFees.sorted { ($0.totalMonths ?? 0) < ($1.totalMonths ?? 0) }
        if isAllInOneCard(currentItem?.card),
           sortedFees.count >= 2,
           sortedFees[1].totalMonths == 3 {
            sortedFees.swapAt(0, 1)
        }
        var monthsPayments = sortedFees.map { (fee) -> MontlyPaymentFeeEntity in
            let feeAmount = fee.feeImport
            let settlementDate = timeManager.fromString(input: fee.settlementDate,
                                                        inputFormat: .yyyyMMdd)
            let amortizationItem = EasyPayAmortizationEntity(representable: fee,
                                                             settlementDate: settlementDate)
            return MontlyPaymentFeeEntity(fee: Decimal(feeAmount ?? 0.0),
                                          numberOfMonths: fee.totalMonths ?? 0,
                                          easyPayAmortization: amortizationItem)
        }
        monthsPayments.append(MontlyPaymentFeeEntity())
        let entity = FractionatePaymentEntity(fractions: monthsPayments, minAmount: 60, maxMonths: 36)
        fractionItem.updateEntity(entity: entity)
        stateSubject.send(.didLoadFractionatedPayment(fractionItem))
    }
    
    func updateTransactionWithItem(_ item: CardTransactionViewItemRepresentable?) {
        guard let selecteditem = item else { return }
        stateSubject.send(.updateItem(selecteditem))
    }
    
    func bindAction(_ actions: [CardActions]) {
        actions.forEach { action in
            action.actionState
                .case(CardActionState.actionSelected)
                .sink { [unowned self] action, card in
                    trackActionSelected(action)
                    coordinator.goToCardAction(card, type: action)
                }.store(in: &subscriptions)
        }
    }
    func updateMovementLocation(_ movement: CardSingleCardMovementRepresentable) {
        if let latitutde = movement.location.latitude,
           let longitude = movement.location.longitude {
            var amount: AmountEntity? = nil
            if let amountRepresentable = movement.location.amountRepresentable {
                amount = AmountEntity(amountRepresentable)
            }
            movementLocation = CardMapItem(date: movement.location.date,
                                           name: movement.location.concept,
                                           alias: currentItem?.card.alias,
                                           amount: amount,
                                           address: movement.location.address,
                                           postalCode: movement.location.postalCode,
                                           location: movementLocation?.location,
                                           latitude: latitutde,
                                           longitude: longitude,
                                           amountValue: movement.location.amountRepresentable?.value,
                                           totalValues: movement.location.amountRepresentable?.value ?? 0)
        }
    }
    
    func didFinishLoad() {
        guard let item = self.currentItem else { return }
        stateSubject.send(.loadCardMovementLocation(item))
        stateSubject.send(.didLoadDetail(item))
        validateFractionatedPayment(item)
    }
    
    func trackActionSelected(_ selected: CardActionType) {
        switch selected {
        case .offCard:
            trackEvent(.offCard, parameters: nil)
        case .divide:
            trackEvent(.expensesDivide, parameters: nil)
        case .share:
            trackEvent(.share, parameters: nil)
        case .fraud:
            trackEvent(.fraud, parameters: nil)
        default:
            break
        }
    }
}

// MARK: Subscriptions
private extension CardTransactionDetailViewModel {
    func subscribe() {
        subscribeTransactionDetail()
        subscribePullOffers()
        subscribeDetailEasyPay()
        subscribeMinEasyPay()
        subscribeEasyPayFee()
        subscribeCardMoventLocation()
        subscribeDetailViewConfiguration()
        subscribeExtraData()
        subscribeFirstFeeinfoEasyPay()
        subscribeCardTransactionActions()
    }
    
    func subscribeTransactionDetail() {
        transactionDetailPublisher()
            .sink { completion in
                if case .failure(let error) = completion {
                    self.currentItem?.error = error.localizedDescription
                    self.didFinishLoad()
                }
            } receiveValue: { [unowned self] result in
                self.currentItem = result
                stateSubject.send(.loadTransactionDetailEasyPay(result))
                stateSubject.send(.loadMinEasyPayAmount(result))
                stateSubject.send(.loadEasyPayFee(result))
                stateSubject.send(.loadDetailViewConfiguration(result))
                stateSubject.send(.loadActions(result))
            }.store(in: &subscriptions)

    }
    
    func subscribePullOffers() {
        pullOffersPublisher()
            .sink { [unowned self] result in
                self.offers = result.offers
                stateSubject.send(.loadTransactionDetail(result.item))
            }.store(in: &subscriptions)

    }

    func subscribeDetailEasyPay() {
        transactionDetailEasyPayPublisher()
            .sink { [unowned self] completion in
                if case .failure = completion {
                    let easyPay = EasyPay(easyPay: nil, isFractioned: false)
                    stateSubject.send(.didloadDetailEasyPay(easyPay))
                }
            } receiveValue: { [unowned self] result in
                stateSubject.send(.didloadDetailEasyPay(result))
            }.store(in: &subscriptions)

    }
    
    func subscribeMinEasyPay() {
        minEasyPayPublisher()
            .sink { [unowned self] result in
                stateSubject.send(.didLoadminAmountEasyPay(result))
            }.store(in: &subscriptions)
    }
    
    func subscribeEasyPayFee() {
        easyPayFeePublisher()
            .sink { [unowned self] result in
                stateSubject.send(.didLoadFeeEasyPay(result))
            }.store(in: &subscriptions)
    }
    
    func subscribeExtraData() {
        let detailtPublisher = state
            .case(CardTransactionDetailState.didloadDetailEasyPay)
            .eraseToAnyPublisher()
        let minAmountPublisher = state
            .case(CardTransactionDetailState.didLoadminAmountEasyPay)
            .eraseToAnyPublisher()
        let feePublisher = state
            .case(CardTransactionDetailState.didLoadFeeEasyPay)
            .eraseToAnyPublisher()
        let detailConfigurationPublisher = state
            .case(CardTransactionDetailState.didLoadDetailViewConfiguration)
            .eraseToAnyPublisher()
        
        Publishers.Zip4(detailtPublisher, minAmountPublisher, feePublisher, detailConfigurationPublisher)
            .sink { [unowned self] completion in
                if case .failure = completion {
                    self.didFinishLoad()
                }
            } receiveValue: { easyPay, minAmount, easyPayFee, detailConfiguration  in
                self.currentItem?.easyPay = easyPay.easyPay
                self.currentItem?.isFractioned = easyPay.isFractioned
                self.currentItem?.minEasyPayAmount = minAmount
                self.currentItem?.feeData = easyPayFee
                self.currentItem?.viewConfigurationRepresentable = detailConfiguration
                self.didFinishLoad()
            }.store(in: &subscriptions)
    }
    
    func subscribeDetailViewConfiguration() {
        detailViewConfigurationPublisher()
            .sink { [unowned self] result in
                stateSubject.send(.didLoadDetailViewConfiguration(result))
            }.store(in: &subscriptions)
    }
    
    func subscribeCardMoventLocation() {
        cardMovementLocationPublisher()
            .sink { [unowned self] completion in
                if case .failure = completion {
                    stateSubject.send(.didLoadTransactionTemporallyNotLocalizable)
                }
            } receiveValue: { [unowned self] result  in
                switch result.status {
                case .locatedMovement:
                    self.updateMovementLocation(result)
                    let mapItem = self.getLocationForMapWith(result.location, showMapButton: true)
                    stateSubject.send(.didLoadTransactionLocation(mapItem))
                case .notLocatedMovement:
                    let mapItem = self.getLocationForMapWith(result.location, showMapButton: false)
                    stateSubject.send(.didLoadTransactionLocation(mapItem))
                case .onlineMovement:
                    let mapItem = self.getLocationForMapWith(result.location,
                                                             showMapButton: false,
                                                             title: localized("transaction_label_transactionOnline"))
                    stateSubject.send(.didLoadTransactionLocation(mapItem))
                case .neverLocalizable:
                    stateSubject.send(.didLoadTransactionNoLocalizable)
                case .serviceError:
                    stateSubject.send(.didLoadTransactionTemporallyNotLocalizable)
                }
            }.store(in: &subscriptions)
    }
    
    func subscribeFirstFeeinfoEasyPay() {
        firstFeeinfoEasyPayPublisher()
            .sink { [unowned self] completion in
                if case .failure = completion {
                    self.prepareFractionPayment()
                }
            } receiveValue: { [unowned self] result in
                cuotesFees.append(result.cuoteFee)
                if result.numberOfMonths == cuotesFees.count {
                    self.prepareFractionPayment()
                }
            }.store(in: &subscriptions)

    }
    
    func subscribeCardTransactionActions() {
        cardTransactionActionsPublisher()
            .sink { [unowned self] response in
                self.bindAction(response)
                self.stateSubject.send(.didLoadActions(response))
            }.store(in: &subscriptions)
    }
}

// MARK: Publishers
private extension CardTransactionDetailViewModel {
    func transactionDetailPublisher() -> AnyPublisher<CardTransactionViewItemRepresentable, Error> {
        return stateSubject
            .case(CardTransactionDetailState.loadTransactionDetail)
            .flatMap { [unowned self] input in
                self.getCardTransactionDetailUseCase
                    .fetchCardDetailDataUseCase(card: input.card,
                                                transaction: input.transaction,
                                                showAmountBackground: input.showAmountBackground)
            }.receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func pullOffersPublisher() -> AnyPublisher<PullOffersLoadedOutput, Never> {
        return stateSubject
            .case(CardTransactionDetailState.loadPullOffers)
            .flatMap { [unowned self] input in
                self.getCandidateOfferUseCase
                    .fetchCandidateOfferPublisher(location: location)
                    .map { (offers: [self.location: $0], item: input) }
                    .replaceError(with: (offers: [:], item: input))
            }.receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func transactionDetailEasyPayPublisher() -> AnyPublisher<EasyPay, Error> {
        return stateSubject
            .case(CardTransactionDetailState.loadTransactionDetailEasyPay)
            .flatMap { [unowned self] input in
                self.getTransactionDetailEasyPayUseCase
                    .fetchTransactionDetailEasyPay(card: input.card,
                                                   transaction: input.transaction,
                                                   cardDetail: input.cardDetail,
                                                   easyPayContract: input.contract)
            }.receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func minEasyPayPublisher() -> AnyPublisher<Double, Never> {
        return stateSubject
            .case(CardTransactionDetailState.loadMinEasyPayAmount)
            .flatMap { [unowned self] _ in
                self.getMinEasyPayAmountUseCase
                    .fetchMinEasyPayAmountPublisher()
            }.receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func easyPayFeePublisher() -> AnyPublisher<FeeDataRepresentable?, Never> {
        return stateSubject
            .case(CardTransactionDetailState.loadEasyPayFee)
            .flatMap { [unowned self] input in
                self.getFeesEasypayUseCase
                    .fetchFeesEasypay(card: input.card)
                    .map { $0 }
                    .replaceError(with: nil)
            }.receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func detailViewConfigurationPublisher() -> AnyPublisher<[CardTransactionDetailViewConfigurationRepresentable], Never> {
        return stateSubject
            .case(CardTransactionDetailState.loadDetailViewConfiguration)
            .flatMap { [unowned self] input in
                self.getCardTransactionDetailViewConfigurationUseCase
                    .fetchCardTransactionDetailViewConfiguration(transaction: input.transaction,
                                                                 detail: input.transactionDetail)
            }.receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func cardMovementLocationPublisher() -> AnyPublisher<CardSingleCardMovementRepresentable, Error> {
        return stateSubject
            .case(CardTransactionDetailState.loadCardMovementLocation)
            .flatMap { [unowned self] input in
                self.getSingleCardMovementLocationUseCase
                    .fetchSingleCardMovementLocation(card: input.card,
                                                     transaction: input.transaction,
                                                     transactionDetail: input.transactionDetail)
            }.receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func firstFeeinfoEasyPayPublisher() -> AnyPublisher<FirstFeeInfoOutput, Error> {
        return stateSubject
            .case(CardTransactionDetailState.loadFirstFeeInfoEasyPay)
            .flatMap { [unowned self] input in
                self.getFirstFeeInfoEasyPay
                    .fetchFirstFeeInfoEasyPay(numberOfFees: input.numberOfFees,
                                              card: input.card,
                                              transactionBalanceCode: input.transactionBalanceCode,
                                              transactionDay: input.transactionDay)
                    .map { (cuoteFee: $0, numberOfMonths: input.numberOfMonths) }
            }.receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func cardTransactionActionsPublisher() -> AnyPublisher<[CardActions], Never> {
        return stateSubject
            .case(CardTransactionDetailState.loadActions)
            .flatMap { [unowned self] input in
                self.getCardTransactionDetailActionsUseCase
                    .fetchCardTransactionDetailActions(item: input)
            }.receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - Analytics
extension CardTransactionDetailViewModel: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        dependencies.external.resolve()
    }
    
    var trackerPage: CardsDetailMovementPage {
        CardsDetailMovementPage()
    }
}
