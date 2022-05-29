import UI
import Foundation
import CoreFoundationLib
import SANLegacyLibrary

protocol OldLoanDetailPresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: OldLoanDetailViewProtocol? { get set }
    func viewDidLoad()
    func dismiss()
    func didSelectMenu()
    func didTapOnShareViewModel(_ viewModel: OldLoanDetailDataViewModel)
}

final class OldLoanDetailPresenter {
    weak var view: OldLoanDetailViewProtocol?
    internal let dependenciesResolver: DependenciesResolver
    private let loanDetailConfiguration: OldLoanDetailConfiguration
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.loanDetailConfiguration =  self.dependenciesResolver.resolve(for: OldLoanDetailConfiguration.self)
    }
    var coordinator: OldLoanDetailCoordinator {
        self.dependenciesResolver.resolve(for: OldLoanDetailCoordinator.self)
    }
}

extension OldLoanDetailPresenter: OldLoanDetailPresenterProtocol {
    func viewDidLoad() {
        let loanDetailDataViewModel = OldLoanDetailDataViewModel(loanEntity: self.loanDetailConfiguration.loan,
                                                              loanDetailEntity: self.loanDetailConfiguration.loanDetail,
                                                              dependenciesResolver: self.dependenciesResolver)
        self.view?.setupViews(viewModel: loanDetailDataViewModel)
    }
    
    @objc func dismiss() {
        self.coordinator.dismiss()
    }
    
    func didTapOnShareViewModel(_ viewModel: OldLoanDetailDataViewModel) {
        self.coordinator.doShare(for: viewModel)
    }

    func didSelectMenu() {
        self.coordinator.didSelectMenu()
    }
}
