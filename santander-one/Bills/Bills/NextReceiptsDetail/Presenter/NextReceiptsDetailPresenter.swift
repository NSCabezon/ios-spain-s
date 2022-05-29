//
//  NextReceiptsDetailPresenter.swift
//  Bills
//
//  Created by alvola on 03/06/2020.
//

import CoreFoundationLib

protocol NextReceiptsDetailPresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: NextReceiptsDetailViewProtocol? { get set }
    func viewDidLoad()
    func didSelectBack()
    func didSelectDrawer()
    func didSelectFutureBillViewModel(_ viewModel: FutureBillDetailViewModel)
    func didFocusOnBillIndex(_ index: Int)
}

final class NextReceiptsDetailPresenter {
    weak var view: NextReceiptsDetailViewProtocol?
    let dependenciesResolver: DependenciesResolver
    
    private var configuration: NextReceiptsDetailConfiguration {
        return self.dependenciesResolver.resolve(for: NextReceiptsDetailConfiguration.self)
    }
    
    private var coordinator: NextReceiptsDetailCoordinatorProtocol {
        return self.dependenciesResolver.resolve(for: NextReceiptsDetailCoordinatorProtocol.self)
    }
    
    private var coordinatorDelegate: BillHomeModuleCoordinatorDelegate {
        return self.dependenciesResolver.resolve(for: BillHomeModuleCoordinatorDelegate.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension NextReceiptsDetailPresenter: NextReceiptsDetailPresenterProtocol {
    func viewDidLoad() {
        let localizedDate  = LocalizedDate(dependenciesResolver: dependenciesResolver)
        let viewModels = configuration.bills.map {
            FutureBillDetailViewModel($0, account: configuration.entity, localizedDate: localizedDate)
        }
        let idx = configuration.bills.firstIndex { $0.isEqualTo(configuration.selectedBill) }
        self.view?.showNextReceipts(viewModels, withSelectedIndex: idx ?? 0)
    }
    
    func didSelectBack() {
        coordinator.end()
    }
    
    func didSelectDrawer() {
        coordinatorDelegate.didSelectMenu()
    }
    
    func didSelectFutureBillViewModel(_ viewModel: FutureBillDetailViewModel) {
        
    }
    
    func didFocusOnBillIndex(_ index: Int) {
        
    }
}
