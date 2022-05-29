import Foundation

protocol BillOperative: Operative {}

extension BillOperative {
    
    func operativeDidFinish() {
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getRemoveBillListUseCase(),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: nil,
            onSuccess: { [weak self] in
                NotificationCenter.default.post(name: .billOperativeDidFinish, object: self)
            }
        )
    }
}
