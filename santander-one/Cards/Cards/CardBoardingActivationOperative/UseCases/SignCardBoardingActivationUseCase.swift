import Foundation
import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

final class SignCardBoardingActivationUseCase: UseCase<SignCardBoardingActivationUseCaseInput, Void, GenericErrorSignatureErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    private lazy var provider: BSANManagersProvider = {
        return self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: SignCardBoardingActivationUseCaseInput) throws -> UseCaseResponse<Void, GenericErrorSignatureErrorOutput> {
        guard let signature = requestValues.signature as? SignatureDTO else {
            return .error(GenericErrorSignatureErrorOutput(nil, .otherError, nil))
        }
        let cardDTO = requestValues.card.dto
        let cardsManager = dependenciesResolver.resolve(for: BSANManagersProvider.self).getBsanCardsManager()
        let expirationDate: Date? = try {
            guard let expirationDate = requestValues.card.expirationDate else {
                let detailResponse = try cardsManager.getCardDetail(cardDTO: requestValues.card.dto)
                return try detailResponse.getResponseData()?.expirationDate
            }
            let timeManager = dependenciesResolver.resolve(for: TimeManager.self)
            return timeManager.fromString(input: expirationDate, inputFormat: .yyyyMM)
        }()
        let response = try cardsManager.confirmActivateCard(cardDTO: cardDTO, expirationDate: expirationDate ?? Date(), signatureDTO: signature)
        if response.isSuccess() {
            return .ok()
        }
        
        let signatureType = try processSignatureResult(response)
        let errorDescription = try response.getErrorMessage() ?? ""
        let errorCode = try response.getErrorCode()
        return .error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
    }
}

struct SignCardBoardingActivationUseCaseInput {
    let card: CardEntity
    let signature: SignatureRepresentable
}
