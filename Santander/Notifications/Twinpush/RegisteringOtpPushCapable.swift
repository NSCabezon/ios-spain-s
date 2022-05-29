import CoreFoundationLib
import SantanderKey

protocol RegisteringOtpPushHandler: AnyObject {
    var dependenciesResolver: DependenciesResolver { get }
    func registerOtpPushToken(newToken: Data, completion: @escaping (Bool, GenericUseCaseErrorOutput?) -> Void)
    func saveDeviceId(deviceId: String)
}

extension RegisteringOtpPushHandler {
    private func getLocalPushToken(newToken: Data, completion: @escaping (GetLocalPushTokenUseCaseOkOutput) -> Void) {
        let useCase = GetLocalPushTokenUseCase(dependenciesResolver: self.dependenciesResolver)
        Scenario(useCase: useCase)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess(completion)
    }
    
    private func updateOtpPushToken(oldToken: Data?, newToken: Data, completion: @escaping (Bool, GenericUseCaseErrorOutput?) -> Void) {
        let useCase = UpdateTokenPushUseCase(dependenciesResolver: self.dependenciesResolver)
        let input = UpdateTokenPushUseCaseInput(oldTokenPush: oldToken, newTokenPush: newToken)
        Scenario(useCase: useCase, input: input)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { _ in
                completion(true, nil)
            }
            .onError { error in
                completion(false, error as? GenericUseCaseErrorOutput)
            }
    }
    
    func saveOtpPushToken(token: Data) {
        let useCase = SaveTokenPushUseCase(dependenciesResolver: self.dependenciesResolver)
        Scenario(useCase: useCase, input: SaveTokenPushUseCaseInput(token: token))
            .execute(on: self.dependenciesResolver.resolve())
    }

    func saveDeviceId(deviceId: String) {
        let useCase = SaveDeviceIdUseCase(dependenciesResolver: self.dependenciesResolver)
        Scenario(useCase: useCase, input: SaveDeviceIdUseCaseInput(deviceId: deviceId))
            .execute(on: self.dependenciesResolver.resolve())
    }

    func registerOtpPushToken(newToken: Data, completion: @escaping (Bool, GenericUseCaseErrorOutput?) -> Void) {
        getLocalPushToken(newToken: newToken) { [weak self] response in
            self?.updateOtpPushToken(oldToken: response.tokenPush, newToken: newToken, completion: completion)
        }
    }
}
