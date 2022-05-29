import CoreFoundationLib

protocol RegisteringOtpPushCapable: class {
    var useCaseProvider: UseCaseProvider { get }
    var useCaseHandler: UseCaseHandler { get }
    func registerOtpPushToken(newToken: Data, completion: @escaping (Bool, GenericUseCaseErrorOutput?) -> Void)
}

extension RegisteringOtpPushCapable {
    private func getLocalPushToken(newToken: Data, completion: @escaping (GetLocalPushTokenUseCaseOkOutput) -> Void) {
        let useCase = useCaseProvider.getGetLocalPushTokenUseCase()
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: nil, onSuccess: completion)
    }
    
    private func updateOtpPushToken(oldToken: Data?, newToken: Data, completion: @escaping (Bool, GenericUseCaseErrorOutput?) -> Void) {
        let useCase = useCaseProvider.getUpdateTokenPushUseCase(input: UpdateTokenPushUseCaseInput(oldTokenPush: oldToken, newTokenPush: newToken))
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: nil, onSuccess: { (_) in
            completion(true, nil)
        }, onError: { error in
            completion(false, error)
        })
    }
    
    func saveOtpPushToken(token: Data) {
        UseCaseWrapper(
            with: useCaseProvider.getSaveTokenPushUseCase(input: SaveTokenPushUseCaseInput(token: token)),
            useCaseHandler: useCaseHandler,
            errorHandler: nil
        )
    }
    
    func registerOtpPushToken(newToken: Data, completion: @escaping (Bool, GenericUseCaseErrorOutput?) -> Void) {
        getLocalPushToken(newToken: newToken) { [weak self] response in
            self?.updateOtpPushToken(oldToken: response.tokenPush, newToken: newToken, completion: completion)
        }
    }
}
