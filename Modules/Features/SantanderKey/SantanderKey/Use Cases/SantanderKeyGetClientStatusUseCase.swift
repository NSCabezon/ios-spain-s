//
//  SantanderKeyGetClientStatusUseCase.swift
//  SantanderKey
//
//  Created by Ali Ghanbari Dolatshahi on 9/3/22.
//

import CoreFoundationLib
import Operative
import SANLegacyLibrary
import CoreDomain
import SANSpainLibrary
import ESCommons

public enum SantanderKeyClientStatusState {
    public static let rightRegisteredDevice = "0"
    public static let anotherDeviceRegistered = "1"
    public static let notRegistered = "2"
    public static let resgisteredSafeDevice = "5"
}

public protocol SantanderKeyGetClientStatusUseCaseProtocol: UseCase<Void, SantanderKeyGetClientUseCaseOKOutput, StringErrorOutput> {}

public class SantanderKeyGetClientStatusUseCase: UseCase<Void, SantanderKeyGetClientUseCaseOKOutput, StringErrorOutput> {
    
    private let repository: SantanderKeyOnboardingRepository
    private let dependenciesResolver: DependenciesResolver
    private let compilation: SpainCompilationProtocol
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.repository = dependenciesResolver.resolve()
        self.compilation = dependenciesResolver.resolve()
    }
    
    public override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<SantanderKeyGetClientUseCaseOKOutput, StringErrorOutput> {
        let deviceId = self.getTokenPush() != nil ? self.getDeviceId() : nil
        let sankeyId = self.getSantanderKeyId()
        guard let status = try? repository.getClientStatus(santanderKeyID: sankeyId, deviceId: deviceId) else {
            return .error(StringErrorOutput("SantanderKeyGetClientStatusUseCase error"))
        }
        return .ok(SantanderKeyGetClientUseCaseOKOutput(clientStatus: status))
    }
    
    private func getDeviceId() -> String? {
        let lookupQuery = KeychainQuery(service: compilation.service,
                                        account: compilation.keychainSantanderKey.deviceId,
                                        accessGroup: compilation.sharedTokenAccessGroup)
        if let deviceId = try? KeychainWrapper().fetch(query: lookupQuery) as? String {
            return deviceId
        }
        
        return nil
    }
    
    private func getSantanderKeyId() -> String? {
        let lookupQuery = KeychainQuery(service: compilation.service,
                                        account: compilation.keychainSantanderKey.sankeyId,
                                        accessGroup: compilation.sharedTokenAccessGroup)
        if let deviceId = try? KeychainWrapper().fetch(query: lookupQuery) as? String {
            return deviceId
        }
        
        return nil
    }
    
    func getTokenPush() -> String? {
        let lookupQuery = KeychainQuery(compilation: compilation,
                                        accountPath: \.keychain.account.tokenPush)
        if let tokenPush = try? KeychainWrapper().fetch(query: lookupQuery) as? Data {
            return tokenPush.map { String(format: "%02.2hhx", $0) }.joined()
        }

        return nil
    }
}

extension SantanderKeyGetClientStatusUseCase: SantanderKeyGetClientStatusUseCaseProtocol {}

public struct SantanderKeyGetClientUseCaseOKOutput {
    public let clientStatus: SantanderKeyStatusRepresentable
}

