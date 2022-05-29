import CoreFoundationLib
import Foundation

class IsFirstInstallationUseCase: UseCase<Void, IsFirstInstallationUseCaseOkOutput, StringErrorOutput> {
    private let compilation: CompilationProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.compilation = dependenciesResolver.resolve(for: CompilationProtocol.self)
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<IsFirstInstallationUseCaseOkOutput, StringErrorOutput> {
        return .ok(IsFirstInstallationUseCaseOkOutput(isFirstInstallation: !UserDefaults.standard.bool(forKey: compilation.userDefaults.key.firstOpen)))
    }
}

struct IsFirstInstallationUseCaseOkOutput {
    let isFirstInstallation: Bool
}
