import Foundation
import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

class OldCardTransactionDetailUseCase: UseCase<CardTransactionDetailUseCaseInput, CardTransactionDetailUseCaseOkOutput, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    private let defaultMinimimAmount = Double(60)
    private let localAppConfig: LocalAppConfig

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.localAppConfig = dependenciesResolver.resolve(for: LocalAppConfig.self)
    }
    
    override func executeUseCase(requestValues: CardTransactionDetailUseCaseInput) throws -> UseCaseResponse<CardTransactionDetailUseCaseOkOutput, StringErrorOutput> {
        let cardsManager = self.dependenciesResolver.resolve(for: BSANManagersProvider.self).getBsanCardsManager()
        let response = try cardsManager.getCardTransactionDetail(cardDTO: requestValues.card.dto, cardTransactionDTO: requestValues.transaction.dto)
        let appConfigRepository: AppConfigRepositoryProtocol = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        let isEnabledMap = appConfigRepository.getBool("enableCardTransactionsMap") == true
        var isSplitExpensesEnabled = appConfigRepository.getBool("enableSplitExpenseBizum") ?? false
        let localEnableSplitExpenseBizum = localAppConfig.enableSplitExpenseBizum
        if localEnableSplitExpenseBizum {
            isSplitExpensesEnabled = localEnableSplitExpenseBizum
        }
        let card = requestValues.card
        let cardTransaction = requestValues.transaction
        let transactionValue = NSDecimalNumber(decimal: cardTransaction.amount?.value ?? 0).doubleValue
        let isEasyPayEnabled = (appConfigRepository.getBool("enableEasyPayCards") ?? true)
            && transactionValue < 0.0
            && abs(transactionValue) >= defaultMinimimAmount
            && card.isCreditCard
            && !card.isBeneficiary
        
        let isEasyPayClassicEnabled = (appConfigRepository.getBool("easyPayCardsModeClassic") ?? true) && isEasyPayEnabled
        let pullOfferCandidates = self.getLocations(requestValues: requestValues)
        
        guard response.isSuccess(), let cardTransactionDetailDTO = try response.getResponseData() else {
            return .error(StringErrorOutput("transaction_label_emptyError"))
        }
        guard isEasyPayEnabled && !isEasyPayClassicEnabled else {
            return .ok(CardTransactionDetailUseCaseOkOutput(
                operativeData: nil,
                detail: CardTransactionDetailEntity(cardTransactionDetailDTO),
                isEnabledMap: isEnabledMap,
                isEasyPayEnabled: isEasyPayEnabled,
                isEasyPayClassicEnabled: isEasyPayClassicEnabled,
                isSplitExpensesEnabled: isSplitExpensesEnabled,
                minimumAmount: defaultMinimimAmount,
                pullOfferCandidates: pullOfferCandidates, isAlreadyFractionated: false))
        }
        guard let cardDetail = getDetailCard(cardDTO: card.dto, cardsManager: cardsManager) else {
            return .ok(getDefaultOkOutPut(cardTransactionDetail: cardTransactionDetailDTO, isEnabledMap: isEnabledMap, isEasyPayEnabled: false, minimumAmount: defaultMinimimAmount, pullOffeerCandidates: pullOfferCandidates, isSplitExpensesEnabled: isSplitExpensesEnabled, isAlreadyFractionated: false))
        }
        guard let easyPayContractTransaction = searchMovementContract(card: card, cardTransaction: cardTransaction, cardManager: cardsManager) else {
            return .ok(getDefaultOkOutPut(cardTransactionDetail: cardTransactionDetailDTO, isEnabledMap: isEnabledMap, isEasyPayEnabled: isEasyPayEnabled, minimumAmount: defaultMinimimAmount, pullOffeerCandidates: pullOfferCandidates, isSplitExpensesEnabled: isSplitExpensesEnabled, isAlreadyFractionated: false))
        }
        let easyPay = getTransactionDetailEasyPay(cardDTO: card.dto, cardDetailDTO: cardDetail.dto, cardTransactionDTO: requestValues.transaction.dto, cardTransactionDetailDTO: cardTransactionDetailDTO, easyPayContractTransactionDTO: easyPayContractTransaction.dto, cardsManager: cardsManager)
        guard let easyPayEntity = easyPay.entity else {
            return .ok(getDefaultOkOutPut(cardTransactionDetail: cardTransactionDetailDTO, isEnabledMap: isEnabledMap, isEasyPayEnabled: isEasyPayEnabled, minimumAmount: defaultMinimimAmount, pullOffeerCandidates: pullOfferCandidates, isSplitExpensesEnabled: isSplitExpensesEnabled, isAlreadyFractionated: easyPay.isAlreadyFractionated))
        }
        guard let feeData = getFeesEasyPay(cardDTO: card.dto, cardsManager: cardsManager) else {
            return .ok(getDefaultOkOutPut(cardTransactionDetail: cardTransactionDetailDTO, isEnabledMap: isEnabledMap, isEasyPayEnabled: isEasyPayEnabled, minimumAmount: defaultMinimimAmount, pullOffeerCandidates: pullOfferCandidates, isSplitExpensesEnabled: isSplitExpensesEnabled, isAlreadyFractionated: easyPay.isAlreadyFractionated))
        }
        // Create struct to content all data neccessary to realize the Easy Pay Operative
        let operativeData = EasyPayOperativeDataEntity(cardDetail: cardDetail,
                                                       cardTransactionDetail: CardTransactionDetailEntity(cardTransactionDetailDTO),
                                                       easyPayContractTransaction: easyPayContractTransaction,
                                                       easyPay: easyPayEntity,
                                                       feeData: feeData)
        return .ok(CardTransactionDetailUseCaseOkOutput(
            operativeData: operativeData,
            detail: CardTransactionDetailEntity(cardTransactionDetailDTO),
            isEnabledMap: isEnabledMap,
            isEasyPayEnabled: isEasyPayEnabled,
            isEasyPayClassicEnabled: isEasyPayClassicEnabled,
            isSplitExpensesEnabled: isSplitExpensesEnabled,
            minimumAmount: defaultMinimimAmount,
            pullOfferCandidates: pullOfferCandidates,
                    isAlreadyFractionated: easyPay.isAlreadyFractionated))
    }
}

private extension OldCardTransactionDetailUseCase {
    
    func getDetailCard(cardDTO: CardDTO, cardsManager: BSANCardsManager) -> CardDetailEntity? {
        let cardDetailResponse = try? cardsManager.getCardDetail(cardDTO: cardDTO)
        
        guard cardDetailResponse?.isSuccess() ?? false, let cardDetailDTO = try? cardDetailResponse?.getResponseData() else { return nil }
        
        let globalPosition: GlobalPositionWithUserPrefsRepresentable = self.dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        let clientName = globalPosition.dto?.clientName ?? ""
        var cardDataDTO: CardDataDTO?
        if let pan = cardDTO.formattedPAN, let responseCardData = try? cardsManager.getCardData(pan), responseCardData.isSuccess(), let cardDataResponse = try? responseCardData.getResponseData() {
            cardDataDTO = cardDataResponse
        }
        return CardDetailEntity(cardDetailDTO, cardDataDTO: cardDataDTO, clientName: clientName)
    }
    
    func searchMovementContract(card: CardEntity, cardTransaction: CardTransactionEntity, cardManager: BSANCardsManager) -> EasyPayContractTransactionEntity? {
        var dateFilterContractMovementDto: DateFilter?
        
        if let operationDate = cardTransaction.operationDate, let annotationDate = cardTransaction.annotationDate {
           dateFilterContractMovementDto = DateFilter(from: operationDate, to: annotationDate)
        }
        
        let responseEasyPayContractTransaction = try? cardManager.getAllTransactionsEasyPayContract(cardDTO: card.dto, dateFilter: dateFilterContractMovementDto)
        guard responseEasyPayContractTransaction?.isSuccess() ?? false, let dataEasyPayContractTransaction = try? responseEasyPayContractTransaction?.getResponseData() else {
            return nil
        }
        
        let easyPayContractTransactionDTOs = dataEasyPayContractTransaction.easyPayContractTransactionDTOS ?? []

        let easyPayContractTransactions = easyPayContractTransactionDTOs.map { easyPayContractTransactionDTO -> EasyPayContractTransactionEntity in
            return EasyPayContractTransactionEntity(easyPayContractTransactionDTO)
        }
        let pkOrigin = cardTransaction.pkDescription
        
        let easyPayContractTransaction = easyPayContractTransactions.first(where: { transaction -> Bool in
            return transaction.pkDescription == pkOrigin
        })
        
        return easyPayContractTransaction
    }
    
    func getTransactionDetailEasyPay(cardDTO: CardDTO, cardDetailDTO: CardDetailDTO, cardTransactionDTO: CardTransactionDTO, cardTransactionDetailDTO: CardTransactionDetailDTO, easyPayContractTransactionDTO: EasyPayContractTransactionDTO, cardsManager: BSANCardsManager) -> (entity: EasyPayEntity?, isAlreadyFractionated: Bool) {
        let responseDetailMovEasyPay = try? cardsManager.getTransactionDetailEasyPay(cardDTO: cardDTO, cardDetailDTO: cardDetailDTO, cardTransactionDTO: cardTransactionDTO, cardTransactionDetailDTO: cardTransactionDetailDTO, easyPayContractTransactionDTO: easyPayContractTransactionDTO)
        if let errorMessage = try? responseDetailMovEasyPay?.getErrorMessage(),
           errorMessage == WSErrors.operativeErrorMd1112 {
            return (nil, true)
        }
        guard responseDetailMovEasyPay?.isSuccess() ?? false, let easyPayDTO = try? responseDetailMovEasyPay?.getResponseData() else { return (nil, false) }
        return (EasyPayEntity(easyPayDTO), false)
    }
    
    func getFeesEasyPay(cardDTO: CardDTO, cardsManager: BSANCardsManager) -> FeeDataEntity? {
        let feesEasyPayResponse = try? cardsManager.getFeesEasyPay(cardDTO: cardDTO)
        
        guard feesEasyPayResponse?.isSuccess() ?? false, let feeDataDTO = try? feesEasyPayResponse?.getResponseData() else { return nil }
        return FeeDataEntity(feeDataDTO)
    }
    
    func getDefaultOkOutPut(cardTransactionDetail: CardTransactionDetailDTO, isEnabledMap: Bool, isEasyPayEnabled: Bool, minimumAmount: Double, pullOffeerCandidates: [PullOfferLocation: OfferEntity], isSplitExpensesEnabled: Bool, isAlreadyFractionated: Bool) -> CardTransactionDetailUseCaseOkOutput {
        return CardTransactionDetailUseCaseOkOutput(
            operativeData: nil,
            detail: CardTransactionDetailEntity(cardTransactionDetail),
            isEnabledMap: isEnabledMap,
            isEasyPayEnabled: isEasyPayEnabled,
            isEasyPayClassicEnabled: true,
            isSplitExpensesEnabled: isSplitExpensesEnabled,
            minimumAmount: defaultMinimimAmount,
            pullOfferCandidates: pullOffeerCandidates,
            isAlreadyFractionated: isAlreadyFractionated)
    }
    
    private func addNewRules(requestValues: CardTransactionDetailUseCaseInput) {
        let pullOffersEngine = self.dependenciesResolver.resolve(for: EngineInterface.self)
        var output = [String: Any]()
        // Rules by cards
        output["TMDA"] = "\"\(requestValues.card.alias ?? "")\""
        switch requestValues.card.cardType {
        case .credit:
            output["TMDT"] = "\"credito\""
        case .debit:
            output["TMDT"] = "\"debito\""
        case .prepaid:
            output["TMDT"] = "\"prepago\""
        }
        output["TMDD"] = "\"\(requestValues.transaction.description ?? "")\""
        output["TMDI"] = "\"\(requestValues.transaction.amount?.value?.doubleValue ?? 0)\""
        pullOffersEngine.addRules(rules: output)
    }
    
    // Add specifics location to transaction details
    private func addSpecifics(_ locationInputs: [PullOfferLocation]) {
        let pullOffersConfigRepository = dependenciesResolver.resolve(for: PullOffersConfigRepositoryProtocol.self)
        let pullOffersInterpreter = self.dependenciesResolver.resolve(for: PullOffersInterpreter.self)
        let globalPosition = self.dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        guard let userId: String = globalPosition.userId else { return }
        var newLocations: [String: [String]] = [:]
        let locationIds = locationInputs.map { $0.stringTag }
        let locations = pullOffersConfigRepository.getLocations() ?? [:]
        for location in locations.keys where locationIds.contains(location) {
            newLocations[location] = locations[location]
            pullOffersInterpreter.removeOffer(location: location)
        }
        pullOffersInterpreter.setCandidates(locations: newLocations, userId: userId, reload: true)
    }
    
    private func getLocations(requestValues: CardTransactionDetailUseCaseInput) -> [PullOfferLocation: OfferEntity] {
        let globalPosition = self.dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        let pullOffersInterpreter = self.dependenciesResolver.resolve(for: PullOffersInterpreter.self)
        self.addNewRules(requestValues: requestValues)
        self.addSpecifics(requestValues.locations)
        var outputCandidates: [PullOfferLocation: OfferEntity] = [:]
        if let userId: String = globalPosition.userId {
            for location in requestValues.locations {
                if let candidate = pullOffersInterpreter.getCandidate(userId: userId, location: location) {
                    outputCandidates[location] = OfferEntity(candidate, location: location)
                }
            }
        }
        return outputCandidates
    }
}

struct CardTransactionDetailUseCaseInput {
    let transaction: CardTransactionEntity
    let card: CardEntity
    let locations: [PullOfferLocation]
}

struct CardTransactionDetailUseCaseOkOutput {
    let operativeData: EasyPayOperativeDataEntity?
    let detail: CardTransactionDetailEntity
    let isEnabledMap: Bool
    let isEasyPayEnabled: Bool
    let isEasyPayClassicEnabled: Bool
    let isSplitExpensesEnabled: Bool
    let minimumAmount: Double
    let pullOfferCandidates: [PullOfferLocation: OfferEntity]
    let isAlreadyFractionated: Bool
}

extension CardTransactionPkProtocol {
    public var pkDescription: String {
        var pkDescription = ""
        if let date = operationDate?.description {
            pkDescription += date
        }
        
        if let amount = amount {
            pkDescription += amount.getAbsFormattedValue()
        }

        if let currency = amount?.currency {
            pkDescription += currency
        }
        if let transactionDay = transactionDay {
            pkDescription += transactionDay
        }
        return pkDescription
    }
}
