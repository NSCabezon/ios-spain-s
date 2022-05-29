import Foundation
import CoreFoundationLib

protocol AmountUseCaseStrategy {
    func executeSimpleAmountUseCase(completion: @escaping () -> Void, onFailure: @escaping (String?) -> Void)
    func executeMultipleAmountUseCase(completion: @escaping () -> Void, onFailure: @escaping (String?) -> Void)
}

final class AmountUseCases {
    let strategy: AmountUseCaseStrategy

    init(strategy: AmountUseCaseStrategy) {
        self.strategy = strategy
    }
    func executeSimpleAmountUseCase(completion: @escaping () -> Void, onFailure: @escaping (String?) -> Void) {
        strategy.executeSimpleAmountUseCase(completion: completion, onFailure: onFailure)
    }
    func executeMultipleAmountUseCase(completion: @escaping () -> Void, onFailure: @escaping (String?) -> Void) {
        strategy.executeMultipleAmountUseCase(completion: completion, onFailure: onFailure)
    }
}
