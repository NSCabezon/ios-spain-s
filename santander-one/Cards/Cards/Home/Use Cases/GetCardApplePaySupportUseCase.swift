import Foundation
import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

public class GetCardApplePaySupportUseCase: UseCase<GetCardApplePaySupportUseCaseInput, GetCardApplePaySupportUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    public override func executeUseCase(requestValues: GetCardApplePaySupportUseCaseInput) throws -> UseCaseResponse<GetCardApplePaySupportUseCaseOkOutput, StringErrorOutput> {
        let appConfigRepository = dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        let applePayEnrollment = dependenciesResolver.resolve(for: ApplePayEnrollmentManager.self)
        guard
            applePayEnrollment.isEnrollingCardEnabled(),
            let enableInAppEnrollment = appConfigRepository.getBool(CardConstants.isInAppEnrollmentEnabled),
            enableInAppEnrollment == true
        else {
            return .ok(GetCardApplePaySupportUseCaseOkOutput(applePayState: .notSupported))
        }
        let cardsManager = dependenciesResolver.resolve(for: BSANManagersProvider.self).getBsanCardsManager()
        let expirationDate: Date? = try {
            guard let expirationDate = requestValues.card.expirationDate else {
                let detailResponse = try cardsManager.getCardDetail(cardDTO: requestValues.card.dto)
                return try detailResponse.getResponseData()?.expirationDate
            }
            let timeManager = dependenciesResolver.resolve(for: TimeManager.self)
            return timeManager.fromString(input: expirationDate, inputFormat: .yyyyMM)
        }()
        guard
            let expirationDateUnwrapped = expirationDate,
            let applePayStatus = try cardsManager.getApplePayStatus(for: requestValues.card.dto, expirationDate: DateModel(date: expirationDateUnwrapped)).getResponseData()
        else {
            return .ok(GetCardApplePaySupportUseCaseOkOutput(applePayState: .notSupported))
        }
        switch applePayStatus.status {
        case .active:
            return .ok(GetCardApplePaySupportUseCaseOkOutput(applePayState: .active))
        case .deactivated, .enrollable:
            guard !requestValues.card.isTemporallyOff, !requestValues.card.isContractBlocked else {
                return .ok(GetCardApplePaySupportUseCaseOkOutput(applePayState: .inactiveAndDisabled))
            }
            return .ok(GetCardApplePaySupportUseCaseOkOutput(applePayState: .inactive))
        case .notEnrollable:
            return .ok(GetCardApplePaySupportUseCaseOkOutput(applePayState: .notSupported))
        }
    }
}

public struct GetCardApplePaySupportUseCaseOkOutput {
    public let applePayState: CardApplePayState
    
    public init(applePayState: CardApplePayState) {
        self.applePayState = applePayState
    }
}

public struct GetCardApplePaySupportUseCaseInput {
    let card: CardEntity
    
    public init(card: CardEntity) {
        self.card = card
    }
}
