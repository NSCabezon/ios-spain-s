import Foundation
import Operative
import CoreFoundationLib

protocol ColorsByNameProtocol: class {
    var dependenciesResolver: DependenciesResolver { get }
    func getColorByName(_ identifier: String) -> ColorsByNameViewModel
}
extension ColorsByNameProtocol {
    func getColorByName(_ identifier: String) -> ColorsByNameViewModel {
        let colorsEngine: ColorsByNameEngine = self.dependenciesResolver.resolve()
        let colorType = colorsEngine.get(identifier)
        return ColorsByNameViewModel(colorType)
    }
}

protocol BizumDonationConfirmationPresenterProtocol: OperativeConfirmationPresenterProtocol {
    var view: BizumDonationConfirmationViewProtocol? { get set }
    func viewDidLoad()
    func didTapClose()
    func getOrganization()
}

final class BizumDonationConfirmationPresenter {
    weak var view: BizumDonationConfirmationViewProtocol?
    var number: Int = 0
    var isBackButtonEnabled: Bool = true
    var isCancelButtonEnabled: Bool = true
    var container: OperativeContainerProtocol?
    var dependenciesResolver: DependenciesResolver
    private lazy var operativeData: BizumDonationOperativeData? = {
        guard let container = self.container else { return nil }
        return container.get()
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension BizumDonationConfirmationPresenter: BizumDonationConfirmationPresenterProtocol {
    
    func viewDidLoad() {
        self.trackScreen()
        self.loadData()
        self.view?.setContinueTitle(localized("generic_button_send"))
    }

    func didTapClose() {
        self.container?.close()
    }

    func getOrganization() {
        guard let organization = self.operativeData?.organization else { return }
        let name = !(organization.name.isEmpty) ? organization.name : organization.alias
        let viewModel = ConfirmationOrganizationDetailViewModel(
            name: name,
            identifier: organization.identifier,
            baseUrl: self.dependenciesResolver.resolve(for: BaseURLProvider.self).baseURL,
            colorsByNameViewModel: self.getColorByName(organization.name)
        )
        self.view?.setOrganization(viewModel)
    }

    func didSelectContinue() {
        self.view?.showLoading()
        Scenario(useCase: self.signPosUseCase)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess(self.handleSignPosSuccessFullRespose)
            .onError(self.handleSignPosFailure)
    }
}
extension BizumDonationConfirmationPresenter: ColorsByNameProtocol {}
extension BizumDonationConfirmationPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }

    var trackerPage: BizumAmountPage {
        let pageAssociated: TrackerPageAssociated
        pageAssociated = BizumDonationAmountPage()
        return BizumAmountPage(strategy: pageAssociated)
    }
}
private extension BizumDonationConfirmationPresenter {
    var signPosUseCase: SignPosSendMoneyUseCase {
        return dependenciesResolver.resolve(for: SignPosSendMoneyUseCase.self)
    }
    
    func loadData() {
        guard let data = self.operativeData else { return }
        let builder = BizumDonationConfirmationBuilder(data: data, dependenciesResolver: self.dependenciesResolver)
        builder.addAmountAndConcept(action: modifyAmount)
        builder.addMedia()
        builder.addOriginAccount()
        builder.addTransferType()
        builder.addDestination(action: modifyOrganization)
        builder.addTotal()
        self.view?.add(builder.build())
    }

    func modifyAmount() {
        self.container?.back(to: BizumDonationAmountPresenter.self)
    }
    func modifyOrganization() {
        self.container?.back(to: BizumDonationNGOSelectorPresenter.self)
    }

    func handleSignPosSuccessFullRespose(_ response: SignPosSendMoneyUseCaseOkOutput) {
        self.view?.dismissLoading(completion: {
            self.container?.rebuildSteps()
            self.container?.save(self.operativeData)
            self.container?.save(response.signatureWithTokenEntity)
            self.container?.stepFinished(presenter: self)
        })
    }

    func handleSignPosFailure(_ error: UseCaseError<StringErrorOutput>) {
        self.view?.dismissLoading(completion: {
            self.view?.showDialog(
                withDependenciesResolver: self.dependenciesResolver,
                description: error.getErrorDesc()
            )
        })
    }
}
