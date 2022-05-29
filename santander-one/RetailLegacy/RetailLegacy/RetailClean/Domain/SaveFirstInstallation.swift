import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class SaveFirstInstallationUseCase: UseCase<Void, Void, StringErrorOutput> {
    
    private let compilation: CompilationProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.compilation = dependenciesResolver.resolve(for: CompilationProtocol.self)
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        UserDefaults.standard.set(true, forKey: compilation.userDefaults.key.firstOpen)
        return .ok()
    }
}
