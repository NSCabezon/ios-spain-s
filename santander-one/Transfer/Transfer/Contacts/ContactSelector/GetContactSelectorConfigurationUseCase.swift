import Foundation
import CoreFoundationLib
import SANLegacyLibrary

public protocol GetContactSelectorConfigurationUseCaseProtocol: UseCase<Void, GetContactSelectorConfigurationUseCaseOkOutput, StringErrorOutput> {}

final class GetContactSelectorConfigurationUseCase: UseCase<Void, GetContactSelectorConfigurationUseCaseOkOutput, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetContactSelectorConfigurationUseCaseOkOutput, StringErrorOutput> {
        let sepaInfoRepository = self.dependenciesResolver.resolve(for: SepaInfoRepositoryProtocol.self)
        let sepaInfoListEntity = SepaInfoListEntity(dto: sepaInfoRepository.getSepaList())
        let output = GetContactSelectorConfigurationUseCaseOkOutput(sepaList: sepaInfoListEntity,
                                                                    isEnabledCreate: true,
                                                                   isEnabledEdit: true,
                                                                   showCloseButton: true)
        return .ok(output)
    }
}

extension GetContactSelectorConfigurationUseCase: GetContactSelectorConfigurationUseCaseProtocol {}

public struct GetContactSelectorConfigurationUseCaseOkOutput {
    let sepaList: SepaInfoListEntity
    let isEnabledCreate: Bool
    let isEnabledEdit: Bool
    let showCloseButton: Bool
    
    public init(sepaList: SepaInfoListEntity, isEnabledCreate: Bool, isEnabledEdit: Bool, showCloseButton: Bool) {
        self.sepaList = sepaList
        self.isEnabledCreate = isEnabledCreate
        self.isEnabledEdit = isEnabledEdit
        self.showCloseButton = showCloseButton
    }
}
