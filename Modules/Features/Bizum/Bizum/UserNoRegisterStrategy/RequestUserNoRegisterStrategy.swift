import CoreFoundationLib
import Operative

final class RequestUserNoRegisterStrategy: UserNoRegisterStrategy {
    let dependenciesResolver: DependenciesResolver
    let operativeData: BizumRequestMoneyOperativeData?

    init(dependenciesResolver: DependenciesResolver, operativeData: BizumRequestMoneyOperativeData?) {
        self.dependenciesResolver = dependenciesResolver
        self.operativeData = operativeData
    }

    func executeUserNotRegister(completion: @escaping () -> Void, onFailure: @escaping (String?) -> Void) {
        guard let entity = operativeData?.bizumValidateMoneyRequestEntity else { return }
        let inviteClientUseCase: BizumRequestMoneyInviteClientUseCase = dependenciesResolver.resolve()
        inviteClientUseCase.setRequestValues(requestValues: BizumRequestMoneyInviteClientUseCaseInput(validateMoneyRequestEntity: entity))
        UseCaseWrapper(with: inviteClientUseCase,
                       useCaseHandler: self.dependenciesResolver.resolve(),
                       onSuccess: { _ in
                        completion()
                       }, onError: { error in
                        let errorMessage = error.getErrorDesc()
                        onFailure(errorMessage)
                       })
    }
}
