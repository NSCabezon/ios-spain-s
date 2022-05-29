//
//  GetLastLoginDateUseCase.swift
//  GlobalPosition
//
//  Created by Laura González on 01/07/2020.
//

import SANLegacyLibrary
import CoreFoundationLib
import Foundation

class GetLastLoginDateUseCase: UseCase<Void, GetLastLoginDateOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let managersProvider: BSANManagersProvider
    private let timeManager: TimeManager
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.managersProvider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        self.timeManager = dependenciesResolver.resolve(for: TimeManager.self)
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetLastLoginDateOkOutput, StringErrorOutput> {
        let appRepository: AppRepositoryProtocol = self.dependenciesResolver.resolve()
        let appconfigRepository: AppConfigRepositoryProtocol = self.dependenciesResolver.resolve()
        let manager = managersProvider.getLastLogonManager()
        let persistedUserResponse = appRepository.getPersistedUser()
        var aliasOrUserName: String? = ""
        if persistedUserResponse.isSuccess() {
            let user = try persistedUserResponse.getResponseData()
            let userId: String? = user?.userId
            let userPrefDTO = appRepository.getUserPreferences(userId: userId ?? "")
            aliasOrUserName = userPrefDTO.pgUserPrefDTO.alias.isEmpty ? user?.name : userPrefDTO.pgUserPrefDTO.alias
            guard
                let lastLoginData = try? manager.getLastLogonInfo(), lastLoginData.isSuccess(),
                let lastLoginDTO = try lastLoginData.getResponseData(),
                appconfigRepository.getBool("enabledWhatsNewLastLogin") == true
                else {
                    return .ok(GetLastLoginDateOkOutput(lastLoginInfoEntity: nil, alias: aliasOrUserName))
            }
            return .ok(GetLastLoginDateOkOutput(lastLoginInfoEntity: createLastLogonEntity(from: lastLoginDTO),
                                                alias: aliasOrUserName))
        } else {
            return .error(StringErrorOutput(nil))
        }
    }
}

private extension GetLastLoginDateUseCase {
    func createLastLogonEntity(from dto: LastLogonDTO) -> GetLastLogonInfoEntity? {
        guard let date = dto.lastConnection else { return nil }
        let lastConnection = timeManager.fromString(input: date, inputFormat: .yyyyMMddHHmmss)
        return GetLastLogonInfoEntity(lastConnection: lastConnection, uid: dto.uid)
    }
}

struct GetLastLoginDateOkOutput {
    let lastLoginInfoEntity: GetLastLogonInfoEntity?
    let alias: String?
}
