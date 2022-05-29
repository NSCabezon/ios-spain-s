//
//  BizumDonationNGOSelectorPresenter.swift
//  Bizum

import Foundation
import Operative
import CoreFoundationLib

protocol BizumDonationNGOSelectorPresenterProtocol: OperativeStepPresenterProtocol, ValidatableFormPresenterProtocol {
    var view: BizumDonationNGOSelectorViewProtocol? { get set }
    func viewDidLoad()
    func didSelectClose()
    func didSelectNGOViewModel(_ viewModel: BizumNGOCollectionViewCellViewModel)
    func didSelectShowAllOrganizations()
    func didSelectContinue()
    func updateOrganizationCode(_ value: String)
}

final class BizumDonationNGOSelectorPresenter {
    var view: BizumDonationNGOSelectorViewProtocol?
    var number: Int = 0
    var isBackButtonEnabled: Bool = true
    var isCancelButtonEnabled: Bool = true
    var container: OperativeContainerProtocol?
    var fields: [ValidatableField] = []
    var isValidForm: Bool {
        guard let view = self.view, let code = view.organizationCode
        else { return false }
        return code.count == organizationCodeLength
    }
    private var organizationCode: String = ""

    private let dependenciesResolver: DependenciesResolver
    private lazy var operativeData: BizumDonationOperativeData? = {
        guard let container = self.container else { return nil }
        return container.get()
    }()
    private var coordinator: OrganizationSelectorCoordinator {
        return dependenciesResolver.resolve()
    }

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension BizumDonationNGOSelectorPresenter: BizumDonationNGOSelectorPresenterProtocol {
    func viewDidLoad() {
        self.trackScreen()
        self.loadSelectedOrganizationsCarousel()
    }
    
    func didSelectClose() {
        self.container?.close()
    }
    
    func didSelectShowAllOrganizations() {
        coordinator.showAllOrganizations(listDelegate: self)
    }
    
    func didSelectNGOViewModel(_ viewModel: BizumNGOCollectionViewCellViewModel) {
        self.operativeData?.organization = BizumNGO(name: viewModel.name, alias: viewModel.alias, identifier: viewModel.identifier)
        self.container?.save(self.operativeData)
        self.container?.stepFinished(presenter: self)
    }
    
    func updateOrganizationCode(_ value: String) {
        self.organizationCode = value
        let code = String(format: "%@%@", organizationCodePrefix, self.organizationCode)
        self.operativeData?.organization = BizumNGO(name: "",
                                                    alias: "",
                                                    identifier: code)
    }

    func didSelectContinue() {
        self.trackStartDonationWithNGOCode()
        self.container?.save(self.operativeData)
        self.container?.stepFinished(presenter: self)
    }
}

extension BizumDonationNGOSelectorPresenter: ValidatableFormPresenterProtocol {
    func validatableFieldChanged() {
        self.view?.updateContinueAction(isValidForm)
    }
}

private extension BizumDonationNGOSelectorPresenter {
    // MARK: Load data
    func loadSelectedOrganizationsCarousel() {
        self.executeDefaultNGOsUseCase()
    }
    
    func executeDefaultNGOsUseCase() {
        let useCase = GetDefaultNGOsUseCase(dependenciesResolver: self.dependenciesResolver)
        Scenario(useCase: useCase)
            .execute(on: DispatchQueue.main)
            .onSuccess { [weak self] result in
                self?.handleDefaultNGOsUseCaseResult(result.bizumNGOs)
            }
            .onError { _ in
                self.view?.showOrganizationsCarousel([])
            }
    }
    
    func handleDefaultNGOsUseCaseResult(_ bizumNGOs: [BizumDefaultNGOEntity]) {
        let baseUrl = dependenciesResolver.resolve(for: BaseURLProvider.self).baseURL
        let colorsEngine: ColorsByNameEngine = self.dependenciesResolver.resolve()
        let viewModels = bizumNGOs.map({ BizumNGOCollectionViewCellViewModel(name: $0.name,
                                                                            identifier: $0.identifier,
                                                                            alias: $0.alias,
                                                                            colorsByName: ColorsByNameViewModel(colorsEngine.get($0.name)),
                                                                            baseUrl: baseUrl)
        })
        self.view?.showOrganizationsCarousel(viewModels)
    }
    
    func getColorsByNameViewModel(name: String) -> ColorsByNameViewModel {
        let colorsEngine = ColorsByNameEngine()
        let colorType = colorsEngine.get(name)
        let colorsByNameViewModel = ColorsByNameViewModel(colorType)
        return colorsByNameViewModel
    }
    
    func trackStartDonationWithNGOCode() {
        let eventName = String(format: "%@%@", BizumDonationTrackingEventNames().enterOrganizationCodePrefix, self.organizationCode)
        trackerManager.trackEvent(screenId: trackerPage.page,
                                  eventId: eventName,
                                  extraParameters: [:])
    }
}

extension BizumDonationNGOSelectorPresenter: AutomaticScreenActionTrackable {
    var trackerPage: BizumDonationSelectOrganizationPage {
        return BizumDonationSelectOrganizationPage()
    }
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
}

extension BizumDonationNGOSelectorPresenter: BizumDonationNGOListDelegate {
    func didSelectOrganization(viewModel: BizumNGOListViewModel) {
        self.trackEvent(.organizationSelected, parameters: [:])
        self.operativeData?.organization = BizumNGO(name: viewModel.name, alias: viewModel.alias, identifier: viewModel.identifier)
        self.container?.save(self.operativeData)
        self.container?.stepFinished(presenter: self)
        self.container?.restoreProgressBar()
    }
}
