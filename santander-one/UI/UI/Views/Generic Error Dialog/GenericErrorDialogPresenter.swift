import Foundation
import CoreFoundationLib

protocol GenericErrorDialogPresenterProtocol: AnyObject {
    var view: GenericErrorDialogViewProtocol? { get set }
    func viewDidLoad()
    func dismiss()
}

class GenericErrorDialogPresenter {
    
    weak var view: GenericErrorDialogViewProtocol?
    let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

private extension GenericErrorDialogPresenter {
    
    var getGenericErrorDialogDataUseCase: GetGenericErrorDialogDataUseCaseProtocol {
        return self.dependenciesResolver.resolve(firstTypeOf: GetGenericErrorDialogDataUseCaseProtocol.self)
    }
    
    var coordinator: GenericErrorDialogCoordinatorProtocol {
        return self.dependenciesResolver.resolve()
    }
    
    func handleSuccess(with data: GetGenericErrorDialogDataUseCaseOkOutput) {
        let builder = GenericErrorDialogViewModelBuilder(dependenciesResolver: self.dependenciesResolver, data: data)
        builder.addWeb()
        builder.addPhoneCall()
        builder.addBranchLocator()
        builder.addGlobalPosition()
        let viewModel = builder.build()
        self.view?.showWithViewModel(viewModel)
    }
}

extension GenericErrorDialogPresenter: GenericErrorDialogPresenterProtocol {
    
    func viewDidLoad() {
        MainThreadUseCaseWrapper(
            with: self.getGenericErrorDialogDataUseCase,
            onSuccess: self.handleSuccess
        )
    }
    
    func dismiss() {
        self.coordinator.dismiss()
    }
    
}
