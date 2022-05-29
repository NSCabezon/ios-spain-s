import Operative
import CoreFoundationLib

protocol NewFavouriteConfirmationPresenterProtocol: OperativeConfirmationPresenterProtocol, MenuTextWrapperProtocol {
    var view: NewFavouriteConfirmationViewProtocol? { get set }
    func viewDidLoad()
}

final class NewFavouriteConfirmationPresenter {
    weak var view: NewFavouriteConfirmationViewProtocol?
    let dependenciesResolver: DependenciesResolver
    var number: Int = 2
    var isBackButtonEnabled: Bool = true
    var isCancelButtonEnabled: Bool = false
    var container: OperativeContainerProtocol?
    var operativeData: NewFavouriteOperativeData {
        guard let container = self.container else { fatalError() }
        return container.get()
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    func didSelectContinue() {
        self.view?.showLoading()
        let input = ValidateNewFavouriteUseCaseInput(
            alias: operativeData.alias ?? "",
            beneficiaryName: operativeData.beneficiaryName ?? "",
            accountId: operativeData.iban?.ibanString
        )
        self.validate(input)
    }
}

extension NewFavouriteConfirmationPresenter: NewFavouriteConfirmationPresenterProtocol {
    func viewDidLoad() {
        self.trackScreen()
        self.createView()
    }
}

private extension NewFavouriteConfirmationPresenter {
    func createView() {
        let builder = NewFavouriteConfirmationBuilder(operativeData: self.operativeData, dependenciesResolver: self.dependenciesResolver)
        builder.addAlias()
        builder.addBeneficiary()
        builder.addIban()
        builder.addCountryDestination()
        self.view?.setContinueTitle(localized("generic_button_confirm"))
        self.view?.add(builder.build())
    }
    
    func validate(_ input: ValidateNewFavouriteUseCaseInput) {
        Scenario(useCase: self.dependenciesResolver.resolve(for: ValidateNewFavouriteUseCaseProtocol.self), input: input)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { result in
                self.view?.dismissLoading(completion: {
                    self.container?.save(result.signatureWithToken)
                    self.container?.stepFinished(presenter: self)
                })
            }
            .onError { error in
                self.view?.dismissLoading(completion: {
                    self.view?.showError(error.getErrorDesc())
                })
            }
    }
}

extension NewFavouriteConfirmationPresenter: AutomaticScreenTrackable {
    var trackerPage: NewFavouriteConfirmationPage {
        return NewFavouriteConfirmationPage()
    }
    var trackerManager: TrackerManager {
        return self.dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
