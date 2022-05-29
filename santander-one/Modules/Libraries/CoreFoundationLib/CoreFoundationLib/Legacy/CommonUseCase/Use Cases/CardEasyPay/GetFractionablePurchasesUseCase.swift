//
//  GetFractionablePurchasesUseCase.swift
//  Cards
//
//  Created by César González Palomino on 16/02/2021.
//

import SANLegacyLibrary

public final class GetFractionablePurchasesUseCase: UseCase<FractionablePurchasesUseCaseInput, FractionablePurchasesUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        super.init()
    }
    
    public override func executeUseCase(requestValues: FractionablePurchasesUseCaseInput) throws -> UseCaseResponse<FractionablePurchasesUseCaseOkOutput, StringErrorOutput> {
        let provider: BSANManagersProvider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let manager = provider.getBsanCardsManager()
        let response = try manager.getEasyPayFinanceableList(
            input: FinanceableListParameters(
                pan: requestValues.pan,
                isEasyPay: requestValues.isEasyPay,
                isElegibleFinancing: true,
                dateFrom: requestValues.dateFrom,
                dateTo: requestValues.dateTo)
        )
        guard
            response.isSuccess(),
            let dataResponse = try response.getResponseData(),
            let movementsDTO = dataResponse.movements
        else {
            let error = try response.getErrorMessage()
            return UseCaseResponse.error(StringErrorOutput(error))
        }
        let timeManager: TimeManager = self.dependenciesResolver.resolve(for: TimeManager.self)
        return .ok(FractionablePurchasesUseCaseOkOutput(
                    movements: movementsDTO.compactMap {
                        FinanceableMovementEntity(dto: $0,
                                                  date: timeManager.fromString(input: $0.operationDate,
                                                                               inputFormat: TimeFormat.yyyyMMdd))
                    }))
    }
}

public struct FractionablePurchasesUseCaseOkOutput {
    public let movements: [FinanceableMovementEntity]
}

public struct FractionablePurchasesUseCaseInput {
    var isEasyPay: Bool
    var pan: String
    var dateFrom: String?
    var dateTo: String?
    
    public init(isEasyPay: Bool, pan: String, dateFrom: String? = nil, dateTo: String? = nil) {
        self.isEasyPay = isEasyPay
        self.pan = pan
        self.dateFrom = dateFrom
        self.dateTo = dateTo
    }
}
