import Foundation

protocol UserNoRegisterStrategy {
    func executeUserNotRegister(completion: @escaping () -> Void, onFailure: @escaping (String?) -> Void)
}

final class UserNoRegisteredUseCase {
    let strategy: UserNoRegisterStrategy

    init(strategy: UserNoRegisterStrategy) {
        self.strategy = strategy
    }
    func executeUserNotRegister(completion: @escaping () -> Void, onFailure: @escaping (String?) -> Void) {
        strategy.executeUserNotRegister(completion: completion, onFailure: onFailure)
    }
}
