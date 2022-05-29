import Foundation
import CoreFoundationLib
import ESCommons

class GetTouchIdLoginDataUseCase: UseCase<Void, GetTouchIdLoginDataOkOutput, StringErrorOutput> {
    private let compilation: CompilationProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.compilation = dependenciesResolver.resolve(for: CompilationProtocol.self)
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetTouchIdLoginDataOkOutput, StringErrorOutput> {
        guard let localAuthData = KeychainWrapper().touchIdData(compilation: compilation)
        else { return UseCaseResponse.error(StringErrorOutput(nil)) }
        return UseCaseResponse.ok(GetTouchIdLoginDataOkOutput(touchIdData: localAuthData))
    }
}

struct GetTouchIdLoginDataOkOutput {
    let touchIdData: TouchIdData
}
