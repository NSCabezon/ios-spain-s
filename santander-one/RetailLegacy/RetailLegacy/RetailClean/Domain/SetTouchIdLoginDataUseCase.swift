import CoreFoundationLib

class SetTouchIdLoginDataUseCase: UseCase<SetTouchIdLoginDataInput, Void, SetTouchIdLoginDataErrorOutput> {

    private let compilation: CompilationProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.compilation = dependenciesResolver.resolve(for: CompilationProtocol.self)
    }
    
    override public func executeUseCase(requestValues: SetTouchIdLoginDataInput) throws -> UseCaseResponse<Void, SetTouchIdLoginDataErrorOutput> {
        
        if let deviceMagicPhrase = requestValues.deviceMagicPhrase,
           let touchIDLoginEnabled = requestValues.touchIDLoginEnabled {
            let touchIdData = TouchIdData(deviceMagicPhrase: deviceMagicPhrase,
                                          touchIDLoginEnabled: touchIDLoginEnabled,
                                          footprint: UIDevice.current.getFootPrint())
            do {
                try KeychainWrapper().saveTouchIdData(touchIdData, compilation: compilation)
                return UseCaseResponse.ok()
            } catch {
                return UseCaseResponse.error(SetTouchIdLoginDataErrorOutput(error.localizedDescription))
            }
        } else {
            do {
                try KeychainWrapper().deleteTouchIdData(compilation: compilation)
                return UseCaseResponse.ok()
            } catch {
                return UseCaseResponse.error(SetTouchIdLoginDataErrorOutput(error.localizedDescription))
            }
        }
    }
}

struct SetTouchIdLoginDataInput {
    let deviceMagicPhrase: String?
    let touchIDLoginEnabled: Bool?
}

class SetTouchIdLoginDataErrorOutput: StringErrorOutput {
}
