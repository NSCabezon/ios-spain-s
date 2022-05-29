@testable import TransferOperatives
import CoreFoundationLib
import UI
import OpenCombine

final class MockOpinatorCoordinator: BindableCoordinator {
    var spyStartPublisher = CurrentValueSubject<Bool, Never>(false)
    var onFinish: (() -> Void)?
    var dataBinding: DataBinding = DataBindingObject()
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController?
    
    func start() {
        spyStartPublisher.send(true)
    }
}

class InternalTransferOperativeCoordinatorMock: InternalTransferOperativeCoordinator {
    private var dependencies: InternalTransferOperativeDependenciesResolver
    var stepsCoordinator: StepsCoordinator<InternalTransferStep> {
        fatalError()
    }
    lazy var dataBinding: DataBinding = dependencies.resolve()
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController?
    var onFinish: (() -> Void)?
    
    var progress: Progress = Progress(current: 0, total: 1)

    var errorShownInternalTransfer: InternalTransferOperativeError?
    var didGoNext = false
    var didGoBack = false
    var didGoBackToStep = false
    var stepBackedTo: InternalTransferStep?
    var opinatorCoordinator: BindableCoordinator {
        return MockOpinatorCoordinator()
    }

    init(dependencies: InternalTransferOperativeDependenciesResolver) {
        self.dependencies = dependencies
    }
    
    func start() {}
    
    func next() {
        didGoNext = true
    }
    
    func back() {
        didGoBack = true
    }
    
    func back(to step: InternalTransferStep) {
        didGoBackToStep = true
        stepBackedTo = step
    }
    
    func showInternalTransferError(_ error: InternalTransferOperativeError) {
        errorShownInternalTransfer = error
    }

    func goToSendMoneyHome() {
        print("goToSendMoneyHome")
    }

    func goToGlobalPosition() {
        print("goToGlobalPosition")
    }

    func goToDownloadPDF() {
        print("goToDownloadPDF")
    }

    func goToShareImage() {
        print("goToShareImage")
    }
    
    func showSuccessOpinator() {
        print("showSuccessOpinator")
    }
}
