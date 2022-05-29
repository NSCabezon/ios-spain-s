import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class SingleSignOnUseCase: UseCase<Void, Void, StringErrorOutput> {
    private let provider: BSANManagersProvider
    private let compilation: CompilationProtocol

    init(managersProvider: BSANManagersProvider, dependenciesResolver: DependenciesResolver) {
        self.provider = managersProvider
        self.compilation = dependenciesResolver.resolve(for: CompilationProtocol.self)
    }

    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let manager =  provider.getBsanAuthManager()
        let authCredentials = try manager.getAuthCredentials()
        let token = authCredentials.soapTokenCredential
        let passwordData = token.data(using: String.Encoding.utf8)
        let query = KeychainQuery(service: "Santander",
                                      account: "keychainTokenToShare",
                                      accessGroup: compilation.keychain.sharedTokenAccessGroup,
                                      data: passwordData as? NSCoding)
        do {
            try KeychainWrapper().save(query: query)
        } catch {}
        return UseCaseResponse.ok()
    }
}
