import CoreFoundationLib

// MARK: - BizumHistoricSuperUseCaseDelegateHandler

final class BizumHistoricSuperUseCaseDelegateHandler {
    private let dependenciesResolver: DependenciesResolver
    weak var delegate: BizumHistoricSuperUseCaseDelegate?
    var operations: [BizumOperationEntity]
    var operationsDetail: [BizumOperationMultiDetailEntity]
    var bizumActionsByAppConfigStatus: BizumAppConfigOperationsStatus?
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.operationsDetail = []
        self.operations = []
    }
}

// MARK: - BizumHistoricSuperUseCaseDelegateHandler - SuperUseCaseDelegate

extension BizumHistoricSuperUseCaseDelegateHandler: SuperUseCaseDelegate {
    func onSuccess() {
        let input = BizumHistoricOperationMixerUseCaseInput(operations: self.operations,
                                                            operationsDetail: self.operationsDetail)
        let usecase = self.mixerUseCase.setRequestValues(requestValues: input)
        UseCaseWrapper(with: usecase, useCaseHandler: self.dependenciesResolver.resolve(), onSuccess: { [weak self] response in
            self?.delegate?.didFinishSuccessfully(response.operations, actionsStatus: self?.bizumActionsByAppConfigStatus)
        }, onError: { [weak self] error in
            self?.delegate?.didFinishWithError(error.getErrorDesc())
        })
    }
    
    func onError(error: String?) {
        self.delegate?.didFinishWithError(error)
    }
}

// MARK: - BizumHistoricSuperUseCaseDelegateHandler - Private

private extension BizumHistoricSuperUseCaseDelegateHandler {
    var mixerUseCase: BizumHistoricOperationMixerUseCase {
        return self.dependenciesResolver.resolve()
    }
}
