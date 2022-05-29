import Foundation
import CoreFoundationLib

// MARK: - BizumHistoricSuperUseCaseDelegate

protocol BizumHistoricSuperUseCaseDelegate: class {
    func didFinishSuccessfully(_ operations: [BizumHistoricOperationEntity], actionsStatus: BizumAppConfigOperationsStatus?)
    func didFinishWithError(_ error: String?)
}

// MARK: - BizumHistoricSuperUseCase

final class BizumHistoricSuperUseCase: SuperUseCase<BizumHistoricSuperUseCaseDelegateHandler> {
    private let dependenciesResolver: DependenciesResolver
    private let handler: BizumHistoricSuperUseCaseDelegateHandler
    private var checkPayment: BizumCheckPaymentEntity?
    private let maxPages: Int = BizumConstants.maxTotalPages
    
    var delegate: BizumHistoricSuperUseCaseDelegate? {
        get {
            return self.handler.delegate
        }
        set {
            self.handler.delegate = newValue
        }
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.handler = BizumHistoricSuperUseCaseDelegateHandler(dependenciesResolver: self.dependenciesResolver)
        super.init(useCaseHandler: dependenciesResolver.resolve(for: UseCaseHandler.self),
                   delegate: self.handler)
    }
    
    // MARK: BizumHistoricSuperUseCase - Overrided methods
    
    override func setupUseCases() {
        self.handler.operations.removeAll()
        self.handler.operationsDetail.removeAll()
        self.getActionsStatus()
        self.getOperations(1)
        self.getOperationsMultiple(1)
    }
    
    // MARK: BizumHistoricSuperUseCase - Internal methods
    
    func setCheckPayment(_ checkPayment: BizumCheckPaymentEntity) {
        self.checkPayment = checkPayment
    }
}

// MARK: - BizumHistoricSuperUseCase - Private

private extension BizumHistoricSuperUseCase {
    var operationsUseCase: BizumOperationUseCase {
        return self.dependenciesResolver.resolve()
    }
    var operationsMultiUseCase: BizumOperationListMultipleUseCase {
        return self.dependenciesResolver.resolve()
    }
    var operationsMultiDetailUseCase: BizumOperationMultipleDetailUseCase {
        return self.dependenciesResolver.resolve()
    }
    var actionsEnabledByAppConfigUseCase: BizumActionsAppConfigUseCase {
        return self.dependenciesResolver.resolve(for: BizumActionsAppConfigUseCase.self)
    }
    func getOperations(_ page: Int) {
        guard let checkPayment = self.checkPayment else { return }
        let input = BizumOperationUseCaseInput(
            page: page,
            checkPayment: checkPayment,
            orderBy: .dischargeDate,
            orderType: .descendant
        )
        let usecase = self.operationsUseCase.setRequestValues(requestValues: input)
        self.add(usecase, isMandatory: true, onSuccess: { [weak self] result in
            guard let self = self else { return }
            self.handler.operations += result.operations.filter { self.filterOperations(operation: $0, checkPayment: checkPayment) }
            let nextPage = page + 1
            guard
                nextPage <= result.totalPages,
                nextPage <= self.maxPages,
                result.isMoreData
            else { return }
            self.getOperations(nextPage)
        })
    }
    
    func getOperationsMultiple(_ page: Int) {
        guard let checkPayment = self.checkPayment else { return }
        let input = BizumOperationListMultipleUseCaseInput(
            page: page,
            checkPayment: checkPayment
        )
        let usecase = self.operationsMultiUseCase.setRequestValues(requestValues: input)
        self.add(usecase, isMandatory: true, onSuccess: { [weak self] result in
            guard let self = self else { return }
            let nextPage = page + 1
            if nextPage <= result.totalPages, nextPage <= self.maxPages, result.isMoreData {
                self.getOperationsMultiple(nextPage)
            }
            result.operations.forEach { (operation: BizumOperationMultiEntity) in
                self.getOperationsDetail(operation)
            }
        })
    }
    
    func getOperationsDetail(_ operationMultiple: BizumOperationMultiEntity) {
        guard let checkPayment = self.checkPayment else { return }
        let input = BizumOperationMultipleDetailUseCaseInput(
            checkPayment: checkPayment,
            operation: operationMultiple
        )
        let usecase = self.operationsMultiDetailUseCase.setRequestValues(requestValues: input)
        self.add(usecase, isMandatory: true, onSuccess: { [weak self] result in
            let filterByValidated = result.detail.operations.filter { $0.dto.state == BizumOperationStateEntity.validated.rawValue }
            guard filterByValidated.isEmpty else { return }
            self?.handler.operationsDetail.append(result.detail)
        })
    }
    
    func getActionsStatus() {
        let useCase = self.actionsEnabledByAppConfigUseCase
        self.add(useCase, isMandatory: true) { [weak self] result in
            let status = BizumAppConfigOperationsStatus(accept: result.acceptEnabled,
                                                        refund: result.refundEnabled,
                                                        cancelNotRegistered: result.cancelEnabled)
            self?.handler.bizumActionsByAppConfigStatus = status
        }
    }
    
    func filterOperations(operation: BizumOperationEntity, checkPayment: BizumCheckPaymentEntity) -> Bool {
        // If the transaction is Validated, then we don't add it
        guard operation.dto.state != BizumOperationStateEntity.validated.rawValue else { return false }
        // If the transaction isn't multiple, then we check as simple operation
        guard operation.isMultiple else { return self.filterSimpleOperation(operation: operation) }
        return self.filterMultipleOperation(operation: operation, checkPayment: checkPayment)
    }
    
    func filterSimpleOperation(operation: BizumOperationEntity) -> Bool {
        // In simple operations when its status is different from Validated
        // is needed to check if we have any receptor to add the operation
        let receptorIdIsEmpty = operation.dto.receptorId?.isEmpty ?? true
        return !receptorIdIsEmpty
    }
    
    func filterMultipleOperation(operation: BizumOperationEntity, checkPayment: BizumCheckPaymentEntity) -> Bool {
        // Conditions for INPUT transactions that come from a multiple transaction.
        // e.g. someone requests bizum to multiple people.
        let isPullOrPush = operation.basicType == .c2CPush || operation.basicType == .c2CPull
        // Filtering the transactions where the user is the emitter.
        let operationIsFromEmitter = operation.emitterId?.trim() == checkPayment.phone?.trim()
        return !(isPullOrPush && operationIsFromEmitter)
    }
}
