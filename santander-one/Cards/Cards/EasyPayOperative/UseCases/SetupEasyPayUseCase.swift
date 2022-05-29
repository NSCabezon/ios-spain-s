//
//  SetupEasyPayUseCase.swift
//  Cards
//
//  Created by alvola on 01/12/2020.
//

import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain
import Operative

final class SetupEasyPayUseCase: UseCase<SetupEasyPayUseCaseInput, SetupEasyPayUseCaseOkOutput, SetupEasyPayUseCaseErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override func executeUseCase(requestValues: SetupEasyPayUseCaseInput) throws -> UseCaseResponse<SetupEasyPayUseCaseOkOutput, SetupEasyPayUseCaseErrorOutput> {
        let card = requestValues.card
        let cardTransaction = requestValues.cardTransaction
        
        // 1. Detalle de tarjeta
        let cardDetailResponse = try getDetailCard(card: card)
        guard let cardDetail = cardDetailResponse.result else {
            return resultError(error: cardDetailResponse.error)
        }
        
        // 2. Detalle de movimiento de tarjeta
        let cardTransactionDetailResponse = try getCardTransactionDetail(card: card, cardTransaction: cardTransaction)
        guard let cardTransactionDetail = cardTransactionDetailResponse.result else {
            return resultError(error: cardTransactionDetailResponse.error)
        }
        
        // 3. Buscar moviminetos de contrato
        let easyPayContractTransactionsResponse = try searchMovementContract(card: card, cardTransaction: cardTransaction)
        guard let easyPayContractTransaction = easyPayContractTransactionsResponse.result else {
            return resultError(error: easyPayContractTransactionsResponse.error)
        }
        
        // 4. Detalle de tarnsacción de pago facil
        let easyPayResponse = try getTransactionDetailEasyPay(card: card,
                                                              cardDetail: cardDetail,
                                                              cardTransaction: cardTransaction,
                                                              cardTransactionDetail: cardTransactionDetail,
                                                              easyPayContractTransaction: easyPayContractTransaction)
        guard let easyPay = easyPayResponse.result else {
            return resultError(error: easyPayResponse.error)
        }
        
        // 5. Cuotas pago facil
        let feeDataResponse = try getFeesEasyPay(card: card)
        guard let feeData = feeDataResponse.result else {
            return resultError(error: feeDataResponse.error)
        }
        
        return UseCaseResponse.ok(SetupEasyPayUseCaseOkOutput(cardDetail: cardDetail,
                                                              cardTransactionDetail: cardTransactionDetail,
                                                              easyPayContractTransaction: easyPayContractTransaction,
                                                              easyPay: easyPay,
                                                              feeData: feeData))
    }
    
    private struct PartialResponse<T> {
        let result: T?
        let error: SetupEasyPayUseCaseErrorOutput?
    }
    
    private func resultError(error: SetupEasyPayUseCaseErrorOutput?) -> UseCaseResponse<SetupEasyPayUseCaseOkOutput, SetupEasyPayUseCaseErrorOutput> {
        let errorOutput: SetupEasyPayUseCaseErrorOutput
        if let error = error {
            errorOutput = error
        } else {
            errorOutput = SetupEasyPayUseCaseErrorOutput(reason: .normal, errorDesc: nil)
        }
        return UseCaseResponse.error(errorOutput)
    }
    
    private func getDetailCard(card: CardEntity) throws -> PartialResponse<CardDetailEntity> {
        let cardManager = provider.getBsanCardsManager()
        let responseDetailCard = try cardManager.getCardDetail(cardDTO: card.dto)
        guard responseDetailCard.isSuccess(), let dataDetailCard = try responseDetailCard.getResponseData() else {
            let error = try responseDetailCard.getErrorMessage()
            let errorOutput = SetupEasyPayUseCaseErrorOutput(reason: .normal, errorDesc: error)
            return PartialResponse(result: nil, error: errorOutput)
        }
        
        let clientName = try? provider.getBsanPGManager().getGlobalPosition().getResponseData()?.clientName ?? ""
        let cardData: CardDataDTO?
        if let pan = card.dto.formattedPAN,
            let responseCardData = try? cardManager.getCardData(pan),
            responseCardData.isSuccess(),
            let cardDataResponse = try? responseCardData.getResponseData() {
            cardData = cardDataResponse
        } else {
            cardData = nil
        }
        let cardDetail = CardDetailEntity(dataDetailCard, cardDataDTO: cardData, clientName: clientName ?? "")
        return PartialResponse(result: cardDetail, error: nil)
    }
    
    private func getCardTransactionDetail(card: CardEntity, cardTransaction: CardTransactionEntity) throws -> PartialResponse<CardTransactionDetailEntity> {
        let cardManager = provider.getBsanCardsManager()
        let responseDetailCardMovement = try cardManager.getCardTransactionDetail(cardDTO: card.dto,
                                                                                  cardTransactionDTO: cardTransaction.dto)
        guard responseDetailCardMovement.isSuccess(),
            let dataDetailCardMovement = try responseDetailCardMovement.getResponseData()
            else {
                let error = try responseDetailCardMovement.getErrorMessage()
                let errorOutput = SetupEasyPayUseCaseErrorOutput(reason: .notAllowedMovementToFinance, errorDesc: error)
                return PartialResponse(result: nil, error: errorOutput)
        }
        let cardTransactionDetail = CardTransactionDetailEntity(dataDetailCardMovement)
        return PartialResponse(result: cardTransactionDetail, error: nil)
    }
    
    private func searchMovementContract(card: CardEntity, cardTransaction: CardTransactionEntity) throws -> PartialResponse<EasyPayContractTransactionEntity> {
        let cardManager = provider.getBsanCardsManager()
        let dateFilterContractMovementDto: DateFilter?
        if let operationDate = cardTransaction.operationDate, let annotationDate = cardTransaction.annotationDate {
           dateFilterContractMovementDto = DateFilterEntity(from: operationDate, to: annotationDate).dto
        } else {
            dateFilterContractMovementDto = nil
        }
        let responseEasyPayContractTransaction = try cardManager.getAllTransactionsEasyPayContract(cardDTO: card.dto,
                                                                                                   dateFilter: dateFilterContractMovementDto)
        guard responseEasyPayContractTransaction.isSuccess(),
            let dataEasyPayContractTransaction =
            try responseEasyPayContractTransaction.getResponseData()
            else {
                let error = try responseEasyPayContractTransaction.getErrorMessage()
                let errorOutput = SetupEasyPayUseCaseErrorOutput(reason: .normal, errorDesc: error)
                return PartialResponse(result: nil, error: errorOutput)
        }
        let easyPayContractTransactionDTOs = dataEasyPayContractTransaction.easyPayContractTransactionDTOS ?? []
        let easyPayContractTransactions = easyPayContractTransactionDTOs.map { easyPayContractTransactionDTO -> EasyPayContractTransactionEntity in
            return EasyPayContractTransactionEntity(easyPayContractTransactionDTO)
        }
        let pkOrigin = cardTransaction.pk
        guard let easyPayContractTransaction = easyPayContractTransactions.first(where: { transaction -> Bool in
            return transaction.pk == pkOrigin
        }) else {
            let errorOutput = SetupEasyPayUseCaseErrorOutput(reason: .notAllowedMovementToFinance, errorDesc: nil)
            return PartialResponse(result: nil, error: errorOutput)
        }
        return PartialResponse(result: easyPayContractTransaction, error: nil)
    }
    
    private func getTransactionDetailEasyPay(card: CardEntity,
                                             cardDetail: CardDetailEntity,
                                             cardTransaction: CardTransactionEntity,
                                             cardTransactionDetail: CardTransactionDetailEntity,
                                             easyPayContractTransaction: EasyPayContractTransactionEntity) throws -> PartialResponse<EasyPayEntity> {
        let cardTransactionDetailDto = cardTransactionDetail.dto
        let cardDetailDTO = cardDetail.dto
        let cardManager = provider.getBsanCardsManager()
        let responseDetailMovEasyPay = try cardManager.getTransactionDetailEasyPay(cardDTO: card.dto,
                                                                                   cardDetailDTO: cardDetailDTO,
                                                                                   cardTransactionDTO: cardTransaction.dto,
                                                                                   cardTransactionDetailDTO: cardTransactionDetailDto,
                                                                                   easyPayContractTransactionDTO: easyPayContractTransaction.dto)
        guard responseDetailMovEasyPay.isSuccess(), let dataDetailMovEasyPay = try responseDetailMovEasyPay.getResponseData() else {
            let error = try responseDetailMovEasyPay.getErrorMessage()
            let errorOutput = SetupEasyPayUseCaseErrorOutput(reason: .normal, errorDesc: error)
            return PartialResponse(result: nil, error: errorOutput)
        }
        let easyPay = EasyPayEntity(dataDetailMovEasyPay)
        return PartialResponse(result: easyPay, error: nil)
    }
    
    private func getFeesEasyPay(card: CardEntity) throws -> PartialResponse<FeeDataEntity> {
        let cardManager = provider.getBsanCardsManager()
        let responseFees = try cardManager.getFeesEasyPay(cardDTO: card.dto)
        guard responseFees.isSuccess(), let dataFees = try responseFees.getResponseData() else {
            let error = try responseFees.getErrorMessage()
            let errorOutput = SetupEasyPayUseCaseErrorOutput(reason: .normal, errorDesc: error)
            return PartialResponse(result: nil, error: errorOutput)
        }
        let feeData = FeeDataEntity(dataFees)
        return PartialResponse(result: feeData, error: nil)
    }
}

struct SetupEasyPayUseCaseInput {
    let card: CardEntity
    let cardTransaction: CardTransactionEntity
}

struct SetupEasyPayUseCaseOkOutput {
    let cardDetail: CardDetailEntity
    let cardTransactionDetail: CardTransactionDetailEntity
    let easyPayContractTransaction: EasyPayContractTransactionEntity
    let easyPay: EasyPayEntity
    let feeData: FeeDataEntity
}

enum SetupEasyPayUseCaseErrorType {
    case normal
    case notAllowedMovementToFinance
}

final class SetupEasyPayUseCaseErrorOutput: StringErrorOutput {
    let reason: SetupEasyPayUseCaseErrorType
    
    init(reason: SetupEasyPayUseCaseErrorType, errorDesc: String?) {
        self.reason = reason
        super.init(errorDesc)
    }
}
