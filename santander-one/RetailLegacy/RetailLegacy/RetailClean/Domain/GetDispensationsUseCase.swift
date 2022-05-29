import CoreFoundationLib

class GetDispensationsUseCase: UseCase<GetDispensationsUseCaseInput, GetDispensationsUseCaseOkOutput, StringErrorOutput> {
    
    private var _container: OperativeContainerProtocol?
    
    override func executeUseCase(requestValues: GetDispensationsUseCaseInput) throws -> UseCaseResponse<GetDispensationsUseCaseOkOutput, StringErrorOutput> {
        _container = requestValues.container
        return UseCaseResponse.ok(GetDispensationsUseCaseOkOutput(dispensationsList: containerParameter()))
    }
}

extension GetDispensationsUseCase: ContainerCollector {
    var container: OperativeContainerProtocol? {
        return _container
    }
}

struct GetDispensationsUseCaseInput {
    let container: OperativeContainerProtocol
}

struct GetDispensationsUseCaseOkOutput {
    let dispensationsList: DispensationsList
}
