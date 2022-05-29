import CoreFoundationLib
import Foundation
import SANLibraryV3
import SANServicesLibrary
import SANSpainLibrary
import Menu

class GetAdobeTargetOfferUseCase: UseCase<GetAdobeTargetOfferUseCaseInput, GetAdobeTargetOfferUseCaseOkOutput, StringErrorOutput> {
    private let adobeTargetRepository: AdobeTargetRepository
    private let dependenciesResolver: DependenciesResolver

    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.adobeTargetRepository = dependenciesResolver.resolve()
    }

    override func executeUseCase(requestValues: GetAdobeTargetOfferUseCaseInput) throws -> UseCaseResponse<GetAdobeTargetOfferUseCaseOkOutput, StringErrorOutput> {
        let manager: AdobeTargetRepository = dependenciesResolver.resolve()
        let response = try manager.getAdobeTargetOfferRequest(input: requestValues)
        switch response {
        case .success(let data):
            return UseCaseResponse.ok(GetAdobeTargetOfferUseCaseOkOutput(adobeTargetOfferRepresentable: data))
        case .failure(let error):
            return UseCaseResponse.error(StringErrorOutput(error.localizedDescription))
        }
    }
}

extension GetAdobeTargetOfferUseCase: GetAdobeTargetOfferUseCaseProtocol {}
