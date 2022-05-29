//
//  GetSubscriptionGraphDataUseCase.swift
//  Cards
//
//  Created by Tania Castellano Brasero on 14/04/2021.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary

public final class GetSubscriptionGraphDataUseCase: UseCase<GetSubscriptionGraphDataUseCaseInput, GetSubscriptionGraphDataUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.provider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override public func executeUseCase(requestValues: GetSubscriptionGraphDataUseCaseInput) throws -> UseCaseResponse<GetSubscriptionGraphDataUseCaseOkOutput, StringErrorOutput> {
        let input = SubscriptionsGraphDataInputParams(
            pan: requestValues.pan,
            instaId: requestValues.instaId
        )
        let response = try provider.getBsanCardsManager().getCardSubscriptionsGraphData(input: input)
        guard
            response.isSuccess(),
            let dataResponse = try response.getResponseData()
        else {
            _ = try response.getErrorMessage()
            return .ok(GetSubscriptionGraphDataUseCaseOkOutput(graphData: nil))
        }
        let graphData = CardSubscriptionGraphDataEntity(dto: dataResponse)
        return .ok(GetSubscriptionGraphDataUseCaseOkOutput(graphData: graphData))
    }
}

public struct GetSubscriptionGraphDataUseCaseInput {
    let pan: String
    let instaId: String
}

public struct GetSubscriptionGraphDataUseCaseOkOutput {
    let graphData: CardSubscriptionGraphDataEntity?
}
