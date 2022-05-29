import Operative
import CoreFoundationLib

class FakeOperative: Operative {
    let dependencies: DependenciesInjector & DependenciesResolver
    weak var container: OperativeContainerProtocol? {
        didSet {
            self.buildSteps()
        }
    }
    lazy var operativeData: FakeOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    var steps: [OperativeStep] = []
    lazy var finishingCoordinator: OperativeFinishingCoordinator = {
        self.dependencies.resolve(for: FakeOperativeFinishingCoordinator.self)
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependencies = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
}

// MARK: - Private methods

private extension FakeOperative {
    func setupDependencies() {
        setupFakeStep()
        setupConfirmation()
        setupSummary()
    }
    
    func buildSteps() {
        self.steps.append(FakeStep(dependenciesResolver: dependencies))
        self.steps.append(FakeStep(dependenciesResolver: dependencies))
        self.steps.append(FakeStep(dependenciesResolver: dependencies))
        self.steps.append(SignatureStep(dependenciesResolver: dependencies))
        self.steps.append(OTPStep(dependenciesResolver: dependencies))
        self.steps.append(SummaryStep(dependenciesResolver: dependencies))
    }
    
    func setupConfirmation() {
    }
    
    func setupSummary() {
    }
    
    func setupFakeStep() {
        self.dependencies.register(for: FakeOperativeStepPresenterProtocol.self, with: { _ in
            return FakeOperativeStepPresenter()
        })
        self.dependencies.register(for: FakeOperativeViewProtocol.self, with: { _ in
            return self.dependencies.resolve(for: FakeOperativeViewController.self)
        })
        self.dependencies.register(for: FakeOperativeViewController.self, with: { _ in
            let presenter = self.dependencies.resolve(for: FakeOperativeStepPresenterProtocol.self)
            let viewController = FakeOperativeViewController(nibName: "FakeOperativeViewController", bundle: .main, presenter: presenter)
            presenter.setView(view: viewController)
            return viewController
        })
    }
}

// MARK: - OperativePresetupCapable

extension FakeOperative: OperativePresetupCapable {
    func performPreSetup(success: @escaping () -> Void, failed: @escaping (OperativeSetupError) -> Void) {
        //Caso de uso del presetup
        success()
    }
}

// MARK: - OperativeSetupCapable

extension FakeOperative: OperativeSetupCapable {
    func performSetup(success: @escaping () -> Void, failed:  @escaping (OperativeSetupError) -> Void) {
        //Caso de uso del setup
        success()
    }
}

// MARK: - OperativeRebuildStepsCapable

extension FakeOperative: OperativeRebuildStepsCapable {
    func rebuildSteps() {
        self.buildSteps()
    }
}

// MARK: - OperativeSignatureCapable

extension FakeOperative: OperativeSignatureCapable {
    func performSignature(for presenter: SignaturePresentationDelegate, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        //Caso de uso de la firma
        completion(true, nil)
    }
}

// MARK: - OperativeSignatureCapable

extension FakeOperative: OperativeOTPCapable {
    func performOTP(for presenter: OTPPresentationDelegate, completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
        //Caso de uso de OTP
        completion(true, nil)
    }
}

// MARK: - OperativeOpinatorCapable

extension FakeOperative: OperativeOpinatorCapable {
    var opinator: RegularOpinatorInfoEntity {
        RegularOpinatorInfoEntity(path: "app-traspasos-exito")
    }
}

// MARK: - OperativeGlobalPositionReloaderCapable

extension FakeOperative: OperativeGlobalPositionReloaderCapable {
    var dependenciesResolver: DependenciesResolver {
        return self.dependencies
    }
}

// MARK: - OperativeFinishingCoordinatorCapable

extension FakeOperative: OperativeFinishingCoordinatorCapable {}

// MARK: - OperativeGiveUpOpinatorCapable

extension FakeOperative: OperativeGiveUpOpinatorCapable {
    
    var giveUpOpinator: GiveUpOpinatorInfoEntity {
        GiveUpOpinatorInfoEntity(path: "app-traspasos-abandono")
    }
}

// MARK: - Steps

class FakeStep: OperativeStep {
    
    let dependenciesResolver: DependenciesResolver
    weak var view: OperativeView? {
        self.dependenciesResolver.resolve(for: FakeOperativeViewProtocol.self)
    }
    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: true, showsCancel: true)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}
