import Operative
import CoreFoundationLib
import SANLegacyLibrary

final class DeleteFavouriteOperative: Operative {
    let dependencies: DependenciesInjector & DependenciesResolver
    weak var container: OperativeContainerProtocol?
    private lazy var operativeData: DeleteFavouriteOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    var steps: [OperativeStep] = []
    lazy var finishingCoordinator: OperativeFinishingCoordinator = {
          self.dependencies.resolve(for: DeleteFavouriteFinishingCoordinatorProtocol.self)
    }()
    private var predefinedSCA: PredefinedSCAEntity? {
        let entity: PredefinedSCAEntity? = self.container?.getOptional()
        return entity
    }
    private var sca: SCA? {
        let entity: SCAEntity? = self.container?.getOptional()
        return entity?.sca
    }

    enum FinishingOption {
        case home
        case globalPosition
        case operativeFinished
    }
    
    init(dependencies: DependenciesInjector & DependenciesResolver) {
        self.dependencies = dependencies
        self.setupDependencies()
    }
}

private extension DeleteFavouriteOperative {
    func buildSteps() {
        self.steps.append(DeleteFavouriteConfirmationStep(dependenciesResolver: self.dependencies))
        if let predefinedSCA = predefinedSCA, predefinedSCA == .signature {
            self.sca?.prepareForVisitor(self)
        }
        self.steps.append(DeleteFavouriteSummaryStep(dependenciesResolver: self.dependencies))
    }
    
    func setupDependencies() {
        self.commonDependencies()
        self.setupConfirmationDependecies()
        self.setupSummaryDependencies()
    }
    
    func commonDependencies() {
        self.dependencies.register(for: PreSetupDeleteFavouriteUseCaseProtocol.self) { resolver in
            return PreSetupDeleteFavouriteUseCase(dependencies: resolver)
        }
        self.dependencies.register(for: SetupDeleteFavouriteUseCaseProtocol.self) { resolver in
            return SetupDeleteFavouriteUseCase(dependencies: resolver)
        }
    }
    
    func setupConfirmationDependecies() {
        self.dependencies.register(for: DeleteFavouriteConfirmationPresenterProtocol.self) { resolver in
            DeleteFavouriteConfirmationPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: DeleteFavouriteConfirmationViewProtocol.self) { resolver in
            resolver.resolve(for: DeleteFavouriteConfirmationViewController.self)
        }
        self.dependencies.register(for: DeleteFavouriteConfirmationViewController.self) { resolver in
            let presenter = resolver.resolve(for: DeleteFavouriteConfirmationPresenterProtocol.self)
            let viewController = DeleteFavouriteConfirmationViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
    
    func setupSummaryDependencies() {
        self.dependencies.register(for: DeleteFavouriteSummaryPresenterProtocol.self) { resolver in
            DeleteFavouriteSummaryPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: OperativeSummaryViewProtocol.self) { resolver in
            resolver.resolve(for: OperativeSummaryViewController.self)
        }
        self.dependencies.register(for: OperativeSummaryViewController.self) { resolver in
            let presenter = resolver.resolve(for: DeleteFavouriteSummaryPresenterProtocol.self)
            let viewController = DeleteFavouriteSummaryViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
}

extension DeleteFavouriteOperative: OperativePresetupCapable {
    func performPreSetup(success: @escaping () -> Void, failed: @escaping (OperativeSetupError) -> Void) {
        Scenario(useCase: self.dependencies.resolve(firstTypeOf: PreSetupDeleteFavouriteUseCaseProtocol.self))
            .execute(on: self.dependencies.resolve())
            .onSuccess { result in
                self.operativeData.sepaList = result.sepaList
                self.container?.save(self.operativeData)
                success()
            }
            .onError { result in
                failed(OperativeSetupError(title: nil, message: result.getErrorDesc()))
            }
    }
}

extension DeleteFavouriteOperative: OperativeSetupCapable {
    func performSetup(success: @escaping () -> Void, failed: @escaping (OperativeSetupError) -> Void) {
        guard let favorite = self.operativeData.favouriteType?.favorite else {
            failed(OperativeSetupError(title: nil, message: nil))
            return
        }
        let input = SetupDeleteFavouriteUseCaseInput(favourite: favorite)
        Scenario(useCase: self.dependencies.resolve(firstTypeOf: SetupDeleteFavouriteUseCaseProtocol.self), input: input)
            .execute(on: self.dependencies.resolve())
            .onSuccess { [weak self] result in
                self?.container?.save(result.signatureWithToken)
                self?.container?.save(result.predefinedSCA)
                if let scaRepresentable = result.signatureWithToken?.signatureWithTokenDTO {
                    self?.container?.save(SCAEntity(scaRepresentable))
                }
                self?.buildSteps()
                success()
            }
            .onError { result in
                failed(OperativeSetupError(title: nil, message: result.getErrorDesc()))
            }
    }
}

extension DeleteFavouriteOperative: SCASignatureWithTokenCapable {
    func prepareForSignatureWithToken(_ signature: SignatureWithTokenEntity) {
        self.container?.save(signature)
        self.steps.append(SignatureStep(dependenciesResolver: dependencies))
    }
}

extension DeleteFavouriteOperative: SCACapable { }

extension DeleteFavouriteOperative: OperativeSignatureCapable {
    func performSignature(for presenter: SignaturePresentationDelegate, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        guard let signature: SignatureWithTokenEntity = self.container?.get() else {
            return completion(false, nil)
        }
        let input = ConfirmDeleteFavouriteUseCaseInput(favoriteType: nil, signatureWithToken: signature)
        Scenario(useCase: self.dependencies.resolve(firstTypeOf: ConfirmDeleteFavouriteUseCaseProtocol.self), input: input)
            .execute(on: self.dependencies.resolve())
            .onSuccess { _ in
                completion(true, nil)
            }
            .onError { errorResult in
                switch errorResult {
                case .error(error: let signatureError): completion(false, signatureError)
                default: completion(false, nil)
                }
            }
    }
}

extension DeleteFavouriteOperative: OperativeFinishingCoordinatorCapable { }

extension DeleteFavouriteOperative: OperativeOpinatorCapable {
    var opinator: RegularOpinatorInfoEntity {
        if (self.operativeData.favouriteType?.isSepa) != nil {
            return RegularOpinatorInfoEntity(path: "app-baja-fav-SEPA-exito")
        } else {
            return RegularOpinatorInfoEntity(path: "app-baja-fav-NOSEPA-exito")
        }
    }
}

extension DeleteFavouriteOperative: OperativeGiveUpOpinatorCapable {
    var giveUpOpinator: GiveUpOpinatorInfoEntity {
        if (self.operativeData.favouriteType?.isSepa) != nil {
            return GiveUpOpinatorInfoEntity(path: "app-baja-fav-SEPA-abandono")
        } else {
            return GiveUpOpinatorInfoEntity(path: "app-baja-fav-NOSEPA-abandono")
        }
    }
}

extension DeleteFavouriteOperative: OperativeGlobalPositionReloaderCapable {
    var dependenciesResolver: DependenciesResolver {
        self.dependencies
    }
}

extension DeleteFavouriteOperative: OperativeDialogFinishCapable {}

extension DeleteFavouriteOperative: OperativeSignatureTrackerCapable {
    var screenIdSignature: String {
        if (self.operativeData.favouriteType?.isSepa) != nil {
            return DeleteFavouriteSepaSignaturePage().pageAssociated
        } else {
            return DeleteFavouriteNoSepaSignaturePage().pageAssociated
        }
    }
}
