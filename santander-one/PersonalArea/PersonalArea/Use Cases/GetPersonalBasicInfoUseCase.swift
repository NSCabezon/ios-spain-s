//
//  GetPersonalBasicInfoUseCase.swift
//  PersonalArea
//
//  Created by alvola on 21/01/2020.
//

import CoreFoundationLib
import SANLegacyLibrary

class GetPersonalBasicInfoUseCase: UseCase<Void, GetPersonalBasicInfoUseCaseOkOutput, StringErrorOutput> {
    let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetPersonalBasicInfoUseCaseOkOutput, StringErrorOutput> {
        let provider: BSANManagersProvider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let userPref = self.dependenciesResolver.resolve(for: UserPrefWrapper.self)
        let appConfigRepository = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        userPref.isPersonalAreaEnabled = appConfigRepository.getBool(PersonalAreaConstants.isPersonalAreaEnabled)
        guard userPref.isPersonalAreaEnabled == true else {
            return UseCaseResponse.ok(GetPersonalBasicInfoUseCaseOkOutput(personalInformation: nil))
        }
        let response = try provider.getBsanPersonDataManager().loadBasicPersonData()
        guard response.isSuccess(), let data = try response.getResponseData() else {
            return UseCaseResponse.error(StringErrorOutput(try response.getErrorMessage()))
        }
        return UseCaseResponse.ok(GetPersonalBasicInfoUseCaseOkOutput(personalInformation: PersonalInformationEntity(data)))
    }
        
    private func isConsultiveUser(signatureStatusInfo: SignStatusInfo?) -> Bool {
        guard let info = signatureStatusInfo else {
            return true
        }
        return info.signatureDataDTO.list?.first?.userOperabilityInd?.uppercased() == "C"
    }
}

public struct GetPersonalBasicInfoUseCaseOkOutput {
    public let personalInformation: PersonalInformationEntity?
    
    public init(personalInformation: PersonalInformationEntity?) {
        self.personalInformation = personalInformation
    }
}

extension GetPersonalBasicInfoUseCase: GetPersonalBasicInfoUseCaseProtocol { }

public protocol GetPersonalBasicInfoUseCaseProtocol: UseCase<Void, GetPersonalBasicInfoUseCaseOkOutput, StringErrorOutput> {}
