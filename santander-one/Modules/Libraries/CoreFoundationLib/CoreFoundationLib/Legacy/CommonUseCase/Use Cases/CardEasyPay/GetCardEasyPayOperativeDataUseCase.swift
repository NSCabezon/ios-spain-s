import SANLegacyLibrary
import CoreDomain
import Foundation

public final class GetCardEasyPayOperativeDataUseCase: UseCase<GetCardEasyPayOperativeDataUseCaseInput, GetCardEasyPayOperativeDataUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let managerProvider: BSANManagersProvider
    private let cardsManager: BSANCardsManager
    private let appConfig: AppConfigRepositoryProtocol
    private let defaultMinimimAmount: Decimal = 60
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.managerProvider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        self.appConfig = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        self.cardsManager = managerProvider.getBsanCardsManager()
    }
    
    override public func executeUseCase(requestValues: GetCardEasyPayOperativeDataUseCaseInput) throws -> UseCaseResponse<GetCardEasyPayOperativeDataUseCaseOkOutput, StringErrorOutput> {
        guard isEasyPayEnable(card: requestValues.card, transaction: requestValues.transaction) else {
            throw NSError(domain: "isEasyPayEnable", code: 0, userInfo: nil)
        }
        do {
            let cardDetail = try self.getDetailCard(card: requestValues.card)
            let transactionDetail = try self.getCardTransactionDetail(card: requestValues.card, transaction: requestValues.transaction)
            let easyPayContractTransaction = try self.getEasyPayContractTransaction(card: requestValues.card, transaction: requestValues.transaction)
            let feeData = try self.getFeeData(card: requestValues.card)
            
            let easyPayTransactionDetail = try self.getEasyPay(
                card: requestValues.card,
                cardDetail: cardDetail,
                transaction: requestValues.transaction,
                transactionDetail: transactionDetail,
                easyPayContract: easyPayContractTransaction)
            
            let easyPayOperativeData = EasyPayOperativeDataEntity(
                cardDetail: cardDetail,
                cardTransactionDetail: transactionDetail,
                easyPayContractTransaction: easyPayContractTransaction,
                easyPay: easyPayTransactionDetail,
                feeData: feeData)
            
            return .ok(GetCardEasyPayOperativeDataUseCaseOkOutput(easyPayOperativeData: easyPayOperativeData))
        } catch let error {
            return .error(StringErrorOutput(error.localizedDescription))
        }
    }
}

private extension GetCardEasyPayOperativeDataUseCase {
    func isEasyPayEnable(card: CardEntity, transaction: CardTransactionEntity) -> Bool {
        guard appConfig.getBool("enableEasyPayCards") == true else {
            return false
        }
        guard card.isCreditCard else {
            return false
        }
        guard let amount = transaction.amount?.value, amount < .zero else {
            return false
        }
        guard abs(amount) >= defaultMinimimAmount else {
            return false
        }
        return true
    }
    
    func getDetailCard(card: CardEntity) throws -> CardDetailEntity {
        let globalPosition = self.dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        let clientName = globalPosition.dto?.clientName ?? ""
        let cardDetailResponse = try cardsManager.getCardDetail(cardDTO: card.dto)
        
        guard cardDetailResponse.isSuccess(),
              let cardDetailDTO = try cardDetailResponse.getResponseData() else {
              throw NSError(domain: "getDetailCard", code: 0, userInfo: nil)
        }
        
        guard let pan = card.formattedPAN else {
            return CardDetailEntity(cardDetailDTO, cardDataDTO: nil, clientName: clientName)
        }
        
        let cardDataResponse = try cardsManager.getCardData(pan)
        guard cardDataResponse.isSuccess(), let cardData = try cardDataResponse.getResponseData() else {
            return CardDetailEntity(cardDetailDTO, cardDataDTO: nil, clientName: clientName)
        }
        return CardDetailEntity(cardDetailDTO, cardDataDTO: cardData, clientName: clientName)
    }
    
    func getCardTransactionDetail(card: CardEntity, transaction: CardTransactionEntity) throws -> CardTransactionDetailEntity {
        let response = try self.cardsManager.getCardTransactionDetail(
            cardDTO: card.dto, cardTransactionDTO: transaction.dto)
        guard response.isSuccess(), let data = try response.getResponseData() else {
            throw NSError(domain: "getCardTransactionDetail", code: 0, userInfo: nil)
        }
        return CardTransactionDetailEntity(data)
    }
    
    func getEasyPayContractTransaction(card: CardEntity, transaction: CardTransactionEntity) throws -> EasyPayContractTransactionEntity {
        var dateFilter: DateFilter?
        
        if let operationDate = transaction.operationDate, let annotationDate = transaction.annotationDate {
           dateFilter = DateFilter(from: operationDate, to: annotationDate)
        }
        let response = try cardsManager.getAllTransactionsEasyPayContract(cardDTO: card.dto, dateFilter: dateFilter)
        
        guard response.isSuccess(), let data = try response.getResponseData() else {
            let userInfo = [NSLocalizedDescriptionKey: try response.getErrorMessage()]
            throw NSError(domain: "getEasyPayContractTransaction", code: 0, userInfo: userInfo as [String: Any])
        }
        
        let contractList = data.easyPayContractTransactionDTOS ?? []
        let easyPayContractTransactions = contractList.map { dto -> EasyPayContractTransactionEntity in
            return EasyPayContractTransactionEntity(dto)
        }
        let pkOrigin = transaction.pkDescription
        
        let easyPayContractTransaction = easyPayContractTransactions.first(where: { transaction -> Bool in
            return transaction.pkDescription == pkOrigin
        })
        
        guard let easyPayContract = easyPayContractTransaction else {
            throw NSError(domain: "getEasyPayContractTransaction", code: 0, userInfo: nil)
        }
        return easyPayContract
    }
    
    func getEasyPay(card: CardEntity, cardDetail: CardDetailEntity,
                    transaction: CardTransactionEntity,
                    transactionDetail: CardTransactionDetailEntity,
                    easyPayContract: EasyPayContractTransactionEntity) throws -> EasyPayEntity {
        
        let response = try cardsManager.getTransactionDetailEasyPay(
            cardDTO: card.dto,
            cardDetailDTO: cardDetail.dto,
            cardTransactionDTO: transaction.dto,
            cardTransactionDetailDTO: transactionDetail.dto,
            easyPayContractTransactionDTO: easyPayContract.dto
        )
    
        guard response.isSuccess(), let data = try? response.getResponseData() else {
            let errorCode = try response.getErrorMessage()
            let error = "operative_error_\(errorCode ?? "")"
            let userInfo = [NSLocalizedDescriptionKey: error]
            throw NSError(domain: "getEasyPay", code: 0, userInfo: userInfo)
        }
        
        return EasyPayEntity(data)
    }
    
    func getFeeData(card: CardEntity) throws -> FeeDataEntity {
        let response = try cardsManager.getFeesEasyPay(cardDTO: card.dto)
        guard response.isSuccess(), let data = try response.getResponseData() else {
            let userInfo = [NSLocalizedDescriptionKey: try response.getErrorMessage()]
            throw NSError(domain: "getFeeData", code: 0, userInfo: userInfo as [String : Any])
        }
        return FeeDataEntity(data)
    }
}

public struct GetCardEasyPayOperativeDataUseCaseInput {
    let card: CardEntity
    let transaction: CardTransactionEntity
    
    public init(card: CardEntity, transaction: CardTransactionEntity) {
        self.card = card
        self.transaction = transaction
    }
}

public struct GetCardEasyPayOperativeDataUseCaseOkOutput {
    public let easyPayOperativeData: EasyPayOperativeDataEntity
}

private extension CardTransactionPkProtocol {
    var pkDescription: String {
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
