//
//  GetSubscriptionsListUseCase.swift
//  Cards
//
//  Created by César González Palomino on 25/02/2021.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class GetSubscriptionsListUseCase: UseCase<SubscriptionsListInput, SubscriptionsListUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        super.init()
    }
    
    override func executeUseCase(requestValues: SubscriptionsListInput) throws -> UseCaseResponse<SubscriptionsListUseCaseOkOutput, StringErrorOutput> {
        let globalPositionData =  self.dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        let provider: BSANManagersProvider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        guard let userDataDTO = globalPositionData.dto?.userDataDTO,
              let userType = userDataDTO.clientPersonType,
              let userCode = userDataDTO.clientPersonCode
        else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let manager = provider.getBsanCardsManager()
        let response = try manager.getCardSubscriptionsList(
            input: SubscriptionsListParameters(pan: requestValues.pan,
                                               clientType: userType,
                                               clientCode: userCode,
                                               dateFrom: requestValues.dateFrom ?? "",
                                               dateTo: requestValues.dateTo ?? ""
            ))
        guard response.isSuccess(),
            let dataResponse = try response.getResponseData(),
            let movementsDTO = dataResponse.subscriptions
        else {
            let error = try response.getErrorMessage()
            return UseCaseResponse.error(StringErrorOutput(error))
        }
        let subscriptions = movementsDTO.compactMap(CardSubscriptionEntity.init)
        let activeCards = globalPositionData.cards.filter { !$0.isTemporallyOff }
        let subscriptionsForCardsOn = subscriptions.filter { cardEntity in
            for card in activeCards where card.pan == cardEntity.formattedPAN {
                return true
            }
            return false
        }
        let subscriptionsSortedByDate = subscriptionsForCardsOn.sorted(by: {
            guard let date1 = $0.date,
                  let date2 = $1.date else {
                return false
            }
            return date1.compare(date2) == .orderedDescending
        })
        return .ok(SubscriptionsListUseCaseOkOutput(subscriptions: subscriptionsSortedByDate))
    }
}

struct SubscriptionsListUseCaseOkOutput {
    let subscriptions: [CardSubscriptionEntity]
}

struct SubscriptionsListInput {
    var pan: String?
    var dateFrom: String?
    var dateTo: String?
}
