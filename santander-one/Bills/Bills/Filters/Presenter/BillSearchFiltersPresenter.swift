//
//  File.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 4/17/20.
//

import Foundation
import CoreFoundationLib

protocol BillSearchFiltersDelegate: AnyObject {
    func didSelectFilters(_ filter: BillFilter)
}

protocol BillSearchFiltersPresenterProtocol: MenuTextWrapperProtocol {
    var view: BillSearchFilterViewProtocol? { get set }
    func viewDidLoad()
    func didSelectDismiss()
    func didSelectBillStatus(at index: Int)
    func didSelectStartDate(_ date: Date)
    func didSelectEndDate(_ date: Date)
    func didSelectChangeAccount()
    func didSelectApplyFilters()
    func didSelectDateRange(at index: Int)
    func getLanguage() -> String
}

final class BillSearchFiltersPresenter {
    weak var view: BillSearchFilterViewProtocol?
    let dependenciesResolver: DependenciesResolver
    private var filterBuilder = FilterBuilder()
    private let filterValidator = FilterValidator()
    private var temporaryFilter: BillFilter?
    private weak var filterDelegate: BillSearchFiltersDelegate?
    
    private var configuration: FilterConfiguration {
        return self.dependenciesResolver.resolve(for: FilterConfiguration.self)
    }
    
    private var getAccountUseCase: GetAccountUseCase {
        return self.dependenciesResolver.resolve(for: GetAccountUseCase.self)
    }
    
    private var coordinatorDelegate: BillSearchFiltersCoordinatorDelegate {
        return self.dependenciesResolver.resolve(for: BillSearchFiltersCoordinatorDelegate.self)
    }
    
    private var coordinator: BillSearchFiltersCoordinatorProtocol {
        return self.dependenciesResolver.resolve(for: BillSearchFiltersCoordinatorProtocol.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.filterDelegate = self.dependenciesResolver.resolve(for: BillSearchFiltersDelegate.self)
    }
}

extension BillSearchFiltersPresenter: BillSearchFiltersPresenterProtocol {
    func viewDidLoad() {
        let filter = self.getSelectedFilters()
        self.setFilters(filter)
        trackScreen()
    }
    
    func didSelectChangeAccount() {
        self.coordinator.goToChangeAccount()
    }
    
    func didSelectDateRange(at index: Int) {
        self.filterBuilder.addDateRangeIndex(index)
    }
    
    func didSelectStartDate(_ date: Date) {
        self.filterBuilder.addStartDate(date)
    }
    
    func didSelectEndDate(_ date: Date) {
        self.filterBuilder.addEndDate(date)
    }
    
    func didSelectBillStatus(at index: Int) {
        let billStatus = LastBillStatus.allCases[index]
        self.filterBuilder.addBillStatus(billStatus)
    }
    
    func didSelectApplyFilters() {
        do {
            let filter = self.filterBuilder.build()
            try self.filterValidator.isValid(filter)
            trackEvent(.apply, parameters: [.textSearch: filter.account?.alias ?? "", .billStatus: filter.billStatus.trackName])
            self.filterDelegate?.didSelectFilters(filter)
            self.coordinator.dismiss()
        } catch {
            guard case let FilterError.invalidDateRange(localizedDescription) = error else { return }
            self.showError(localizedDescription)
        }
    }
    
    func didSelectDismiss() {
        self.coordinator.dismiss()
    }
    
    func getLanguage() -> String {
        return self.dependenciesResolver.resolve(forOptionalType: StringLoader.self)?.getCurrentLanguage().languageType.rawValue ?? "en"
    }
}

private extension BillSearchFiltersPresenter {
    func setFilters(_ filter: BillFilter) {
        let viewModel = FilterViewModel(filter: filter)
        self.view?.setAccountFilter(viewModel)
        self.view?.setDateFilter(viewModel)
        self.view?.setBillStatusFilter(viewModel)
    }
    
    func getSelectedFilters() -> BillFilter {
        guard let filter = self.configuration.filter else {
            return filterBuilder.build()
        }
        self.filterBuilder = FilterBuilder(filter)
        return filter
    }
    
    func showError(_ localizedDescription: String) {
        self.coordinatorDelegate.showAlertDialog(
            acceptTitle: localized("generic_button_accept"),
            cancelTitle: nil,
            title: localized("generic_alert_title_errorData"),
            body: localized(localizedDescription),
            acceptAction: nil,
            cancelAction: nil)
    }
}

extension BillSearchFiltersPresenter: BillAccountSelector {
    func didSelectAccount(_ account: AccountEntity) {
        self.filterBuilder.addAccount(account)
        self.setFilters(self.filterBuilder.build())
    }
}

extension BillSearchFiltersPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: BillSearchFiltersPage {
        return BillSearchFiltersPage()
    }
}
