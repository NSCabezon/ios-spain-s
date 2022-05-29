import Foundation
import SANLegacyLibrary
import CoreFoundationLib

class SetupCVVQueryCardUseCase: SetupUseCase<SetupCVVQueryCardUseCaseInput, SetupCVVQueryCardUseCaseOkOutput, SetupCVVQueryCardUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(dependenciesResolver: DependenciesResolver, appConfigRepository: AppConfigRepository) {
        self.provider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        super.init(appConfigRepository: appConfigRepository)
    }
    
    override func executeUseCase(requestValues: SetupCVVQueryCardUseCaseInput) throws -> UseCaseResponse<SetupCVVQueryCardUseCaseOkOutput, SetupCVVQueryCardUseCaseErrorOutput> {
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig
        let validateCVVQuery = try provider.getBsanCardsManager().validateCVV(cardDTO: requestValues.card.cardDTO)
        guard validateCVVQuery.isSuccess(),
              let scaRepresentable = try validateCVVQuery.getResponseData() else {
            return UseCaseResponse.error(SetupCVVQueryCardUseCaseErrorOutput(try validateCVVQuery.getErrorMessage()))
        }
        let legacySCAEntity = LegacySCAEntity(scaRepresentable)
        return UseCaseResponse.ok(SetupCVVQueryCardUseCaseOkOutput(operativeConfig: operativeConfig, legacySCAEntity: legacySCAEntity))
    }
}

struct SetupCVVQueryCardUseCaseInput {
    let card: Card
}

struct SetupCVVQueryCardUseCaseOkOutput {
    var operativeConfig: OperativeConfig
    var legacySCAEntity: LegacySCAEntity
}

extension SetupCVVQueryCardUseCaseOkOutput: SetupUseCaseOkOutputProtocol {}

class SetupCVVQueryCardUseCaseErrorOutput: StringErrorOutput {
}
