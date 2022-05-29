//
//  SetPersistedUserUseCase.swift
//  Session
//
//  Created by José Carlos Estela Anguita on 17/9/21.
//

import Foundation
import SANLegacyLibrary

final class SetPersistedUserUseCase: UseCase<Void, Void, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    private let appRepository: AppRepositoryProtocol
    private let bsanManagersProvider: BSANManagersProvider
    private let localAuth: LocalAuthenticationPermissionsManagerProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.appRepository = dependenciesResolver.resolve()
        self.bsanManagersProvider = dependenciesResolver.resolve()
        self.localAuth = dependenciesResolver.resolve()
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let globalPositionDTO: GlobalPositionDTO = try checkRepositoryResponse(bsanManagersProvider.getBsanPGManager().getGlobalPosition())!
        let isPb = try checkRepositoryResponse(bsanManagersProvider.getBsanSessionManager().isPB())!
        guard
            try persistedUserExists(),
            let persistedUserDTO = try appRepository.getPersistedUser().getResponseData(),
            let userDataDTO = globalPositionDTO.userDataDTO
        else {
            return .ok()
        }
        persistedUserDTO.isPb = isPb
        persistedUserDTO.name = formatName(globalPositionDTO)
        persistedUserDTO.channelFrame = userDataDTO.channelFrame
        persistedUserDTO.userId = userId(of: userDataDTO)
        persistedUserDTO.biometryData = self.localAuth.biometryData
        _ = appRepository.setPersistedUserDTO(persistedUserDTO: persistedUserDTO)
        return .ok()
    }
}

private extension SetPersistedUserUseCase {
    
    func userId(of userDataDTO: UserDataDTO) -> String? {
        guard let userType = userDataDTO.clientPersonType, let userCode = userDataDTO.clientPersonCode else {
            return nil
        }
        return userType + userCode
    }
    
    func formatName(_ globalPositionDTO: GlobalPositionDTO) -> String {
        if let clientNameWithoutSurname = globalPositionDTO.clientNameWithoutSurname, !clientNameWithoutSurname.isEmpty {
            return clientNameWithoutSurname
        }
        return globalPositionDTO.clientName ?? ""
    }
    
    func persistedUserExists() throws -> Bool {
        return try appRepository.getPersistedUser().isSuccess() && appRepository.getPersistedUser().getResponseData() != nil
    }
}
