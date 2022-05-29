//
//  BizumDonationNGOListPresenter.swift
//  Bizum

import CoreFoundationLib

protocol BizumDonationNGOListDelegate: class {
    func didSelectOrganization(viewModel: BizumNGOListViewModel)
}

protocol BizumDonationNGOListPresenterProtocol {
    func viewDidLoad()
    func organizationCodeDidSet(text: String)
    func didSelectOrganization(_ item: BizumNGOListViewModel)
}

final class BizumDonationNGOListPresenter {
    var view: BizumDonationNGOListViewProtocol?
    private let dependenciesResolver: DependenciesResolver
    weak var delegate: BizumDonationNGOListDelegate?
    private let operationsSuperUseCase: BizumGetOrganizationsSuperUseCase
    private var organizationsList: [BizumOrganizationEntity]?
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.operationsSuperUseCase = self.dependenciesResolver.resolve()
        self.operationsSuperUseCase.delegate = self
    }
}

extension BizumDonationNGOListPresenter: BizumDonationNGOListPresenterProtocol {
    func viewDidLoad() {
        self.loadAllOrganizationsList()
    }

    func organizationCodeDidSet(text: String) {
        self.view?.setState(.searching)
        self.filterNGOListWith(text: text)
    }
    
    func didSelectOrganization(_ item: BizumNGOListViewModel) {
        self.delegate?.didSelectOrganization(viewModel: item)
    }
}

private extension  BizumDonationNGOListPresenter {
    func loadAllOrganizationsList() {
        self.view?.showOrganizationLoading()
        self.operationsSuperUseCase.execute()
    }
    
    // MARK: Filter NGOs list
    func filterNGOListWith(text: String) {
        guard var organizations = self.organizationsList else { return }
        organizations.sort { $0.alias.localizedCaseInsensitiveCompare($1.alias) == .orderedAscending }
        if text.isEmpty {
            let NGOViewModels = organizations
                .map { BizumNGOListViewModel(identifier: $0.identifier, name: $0.name, alias: $0.alias) }
            self.view?.showFilteredOrganizations(NGOViewModels)
        } else {
            let filteredByAliasOrganizations: [BizumNGOListViewModel] = organizations
                .map { BizumNGOListViewModel(identifier: $0.identifier, name: $0.name, alias: $0.alias) }
                .filter { ngoItem in
                    let nameMatched = ngoItem.alias.uppercased().contains(text.uppercased())
                    return nameMatched
                }
            organizations.sort { $0.identifier.localizedCaseInsensitiveCompare($1.identifier) == .orderedAscending }
            let filteredByCodeOrganizations: [BizumNGOListViewModel] = organizations
                .map { BizumNGOListViewModel(identifier: $0.identifier, name: $0.name, alias: $0.alias) }
                .filter { ngoItem in
                    let identifierMatched = ngoItem.displayedIdentifier.uppercased().contains(text.uppercased())
                    return identifierMatched
                }
            var fullOrganizationsResult = [BizumNGOListViewModel]()
            fullOrganizationsResult.append(contentsOf: filteredByAliasOrganizations)
            fullOrganizationsResult.append(contentsOf: filteredByCodeOrganizations)
            let finalOrganizationsResult = self.removeViewModelDuplicates(fullOrganizationsResult)
            
            if finalOrganizationsResult.isEmpty {
                self.view?.setState(.empty)
            }
            self.view?.showFilteredOrganizations(finalOrganizationsResult)
        }
    }

    func handleOperationsSuccessFullRespose(_ operations: [BizumOrganizationEntity]) {
        let uniqueNGOEntities = self.removeEntityDuplicates(operations)
        let organizationsViewModels = uniqueNGOEntities
            .sorted { $0.alias.localizedCaseInsensitiveCompare($1.alias) == .orderedAscending }
            .map { BizumNGOListViewModel(identifier: $0.identifier, name: $0.name, alias: $0.alias) }
        self.organizationsList = uniqueNGOEntities
        self.view?.showAllOrganizationsList(organizationsViewModels)
        self.view?.hideOrganizationLoading(state: .initial)
    }

    func removeEntityDuplicates(_ NGOEntities: [BizumOrganizationEntity]) -> [BizumOrganizationEntity] {
        var uniqueEntities: [BizumOrganizationEntity] = []
        NGOEntities.forEach({ item in
            if !uniqueEntities.contains(where: {item.identifier == $0.identifier}) {
                uniqueEntities.append(item)
            }
        })
        return uniqueEntities
    }
    
    func removeViewModelDuplicates(_ NGOModelEntities: [BizumNGOListViewModel]) -> [BizumNGOListViewModel] {
        var uniqueViewModels: [BizumNGOListViewModel] = []
        NGOModelEntities.forEach({ item in
            if !uniqueViewModels.contains(where: {item.identifier == $0.identifier}) {
                uniqueViewModels.append(item)
            }
        })
        return uniqueViewModels
    }
}
extension BizumDonationNGOListPresenter: BizumGetOrganizationsSuperUseCaseDelegate {
    func didFinishSuccessFully(_ operations: [BizumOrganizationEntity]) {
        self.handleOperationsSuccessFullRespose(operations)
    }

    func didFinishWithError(_ error: String?) {
        self.view?.hideOrganizationLoading(state: .empty)
    }
}
