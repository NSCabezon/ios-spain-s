import Foundation
import CoreFoundationLib


class GetInfoServicesForYouUseCase: UseCase<Void, GetInfoServicesForYouUseCaseOkOutput, GetInfoServicesForYouUseCaseErrorOutput> {
    
    private let servicesForYouRepository: ServicesForYouRepository
    private let appRepository: AppRepository
    
    init(servicesForYouRepository: ServicesForYouRepository, appRepository: AppRepository) {
        self.servicesForYouRepository = servicesForYouRepository
        self.appRepository = appRepository
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetInfoServicesForYouUseCaseOkOutput, GetInfoServicesForYouUseCaseErrorOutput> {
        if let servicesForYouRepositoryDTO = self.servicesForYouRepository.get() {
            let servicesForYou = ServicesForYou(servicesForYouRepositoryDTO)
             return UseCaseResponse.ok(GetInfoServicesForYouUseCaseOkOutput(servicesForYou: servicesForYou))
        }
        return UseCaseResponse.ok()
    }
}

struct GetInfoServicesForYouUseCaseOkOutput {
    let servicesForYou: ServicesForYou
}

class GetInfoServicesForYouUseCaseErrorOutput: StringErrorOutput {}
