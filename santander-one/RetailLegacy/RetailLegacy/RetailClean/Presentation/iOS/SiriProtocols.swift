import CoreFoundationLib

typealias SiriIntentsOperator = SiriDonator & SiriDeleter

protocol SiriDonator: SiriUseCasesOperator {
}

extension SiriDonator {
    func donateSiriIntents() {
        operate(useCase: useCaseProvider.donateSiriIntentsUseCase())
    }
}

protocol SiriDeleter: SiriUseCasesOperator {}

extension SiriDeleter {
    func deleteSiriIntents() {
        operate(useCase: useCaseProvider.deleteSiriIntentsUseCase())
    }
}

protocol SiriUseCasesOperator {
    var useCaseProvider: UseCaseProvider { get }
    var useCaseHandler: UseCaseHandler { get }
}

extension SiriUseCasesOperator {
    func operate<UC: UseCase<Void, Void, StringErrorOutput>>(useCase: UC) {
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler)
    }
}
