import Foundation
import CoreFoundationLib
import SANLegacyLibrary

public final class GetSubscriptionHistoricalUseCase: UseCase<GetSubscriptionHistoricalUseCaseInput, GetSubscriptionHistoricalUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.provider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override public func executeUseCase(requestValues: GetSubscriptionHistoricalUseCaseInput) throws -> UseCaseResponse<GetSubscriptionHistoricalUseCaseOkOutput, StringErrorOutput> {
        let input = SubscriptionsHistoricalInputParams(
            pan: requestValues.pan,
            instaId: requestValues.instaId,
            startDate: requestValues.startDate,
            endDate: requestValues.endDate
        )
        let response = try provider.getBsanCardsManager().getCardSubscriptionsHistorical(input: input)
        guard
            response.isSuccess(),
            let dataResponse = try response.getResponseData()
        else {
            return .ok(GetSubscriptionHistoricalUseCaseOkOutput(subscriptions: nil))
        }
        let historical = CardSubscriptionHistoricalListEntity(dto: dataResponse)
        let subscriptionsSortedByDate = historical.subscriptions?.sorted(by: {
            guard let date1 = $0.date,
                  let date2 = $1.date else {
                return false
            }
            return date1.compare(date2) == .orderedDescending
        })
        return .ok(GetSubscriptionHistoricalUseCaseOkOutput(subscriptions: subscriptionsSortedByDate))
    }
}

public struct GetSubscriptionHistoricalUseCaseInput {
    let pan: String
    let instaId: String
    let startDate: String
    let endDate: String
}

public struct GetSubscriptionHistoricalUseCaseOkOutput {
    let subscriptions: [CardSubscriptionHistoricalEntity]?
}
