import Operative
import CoreFoundationLib

protocol DeleteFavouriteConfirmationPresenterProtocol: OperativeConfirmationPresenterProtocol, MenuTextWrapperProtocol {
    var view: DeleteFavouriteConfirmationViewProtocol? { get set }
    func viewDidLoad()
}

final class DeleteFavouriteConfirmationPresenter {
    weak var view: DeleteFavouriteConfirmationViewProtocol?
    let dependenciesResolver: DependenciesResolver
    var number: Int = 0
    var isBackButtonEnabled: Bool = true
    var isCancelButtonEnabled: Bool = false
    var container: OperativeContainerProtocol?
    var operativeData: DeleteFavouriteOperativeData {
        guard let container = self.container else { fatalError() }
        return container.get()
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    func didSelectContinue() {
        self.view?.showLoading()
        self.validate()
    }
}

extension DeleteFavouriteConfirmationPresenter: DeleteFavouriteConfirmationPresenterProtocol {
    func viewDidLoad() {
        self.trackScreen()
        self.createView()
    }
}

private extension DeleteFavouriteConfirmationPresenter {
    func createView() {
        let builder = DeleteFavouriteConfirmationBuilder(operativeData: self.operativeData, dependenciesResolver: self.dependenciesResolver)
        builder.addAlias()
        builder.addBeneficiary()
        builder.addIban()
        builder.addCountryDestination()
        self.view?.setContinueTitle(localized("generic_button_continue"))
        self.view?.add(builder.build())
    }
    
    func validate() {
        guard self.operativeData.favouriteType?.favorite.payeeId != nil else {
            self.view?.dismissLoading(completion: {
                self.container?.stepFinished(presenter: self)
            })
            return
        }
        let input = ConfirmDeleteFavouriteUseCaseInput(favoriteType: self.operativeData.favouriteType, signatureWithToken: nil)
        Scenario(useCase: self.dependenciesResolver.resolve(firstTypeOf: ConfirmDeleteFavouriteUseCaseProtocol.self), input: input)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { _ in
                self.view?.dismissLoading(completion: {
                    self.container?.stepFinished(presenter: self)
                })
            }
            .onError { errorResult in
                self.view?.dismissLoading(completion: {
                    switch errorResult {
                    case .error(error: let signatureError):
                        self.view?.showError(signatureError?.getErrorDesc())
                    case .generic, .intern, .networkUnavailable, .unauthorized:
                        self.container?.showGenericError()
                    }
                })
            }
    }
}

extension DeleteFavouriteConfirmationPresenter: AutomaticScreenTrackable {
    var trackerPage: StrategyPageTrackable {
        if (self.operativeData.favouriteType?.isSepa) != nil {
            return StrategyPageTrackable(strategy: DeleteFavouriteConfirmationSepaPage())
        } else {
            return StrategyPageTrackable(strategy: DeleteFavouriteConfirmationNoSepaPage())
        }
    }
    var trackerManager: TrackerManager {
        return self.dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
