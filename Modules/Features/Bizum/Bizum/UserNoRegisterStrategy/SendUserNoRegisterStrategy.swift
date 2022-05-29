import CoreFoundationLib
import Operative

final class SendUserNoRegisterStrategy: UserNoRegisterStrategy {
    let dependenciesResolver: DependenciesResolver
    var container: OperativeContainerProtocol?
    let operativeData: BizumSendMoneyOperativeData?

    init(dependenciesResolver: DependenciesResolver, container: OperativeContainerProtocol?, operativeData: BizumSendMoneyOperativeData?) {
        self.dependenciesResolver = dependenciesResolver
        self.container = container
        self.operativeData = operativeData
    }

    func executeUserNotRegister(completion: @escaping () -> Void, onFailure: @escaping (String?) -> Void) {
        let signPosUseCase: SignPosSendMoneyUseCase = dependenciesResolver.resolve()
        UseCaseWrapper(with: signPosUseCase,
                       useCaseHandler: self.dependenciesResolver.resolve(),
                       onSuccess: { [weak self] response in
                        self?.container?.save(response.signatureWithTokenEntity)
                        completion()
                       }, onError: { error in
                        let errorMessage = error.getErrorDesc()
                        onFailure(errorMessage)
                       })
    }
}
