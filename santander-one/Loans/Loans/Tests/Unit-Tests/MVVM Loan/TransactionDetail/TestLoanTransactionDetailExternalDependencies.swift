import UI
import Foundation
import CoreDomain
import CoreTestData
import CoreFoundationLib
@testable import Loans

struct TestLoanTransactionDetailExternalDependencies: LoanHomeExternalDependenciesResolver {
    let injector: MockDataInjector
    let globalPositionRepository: MockGlobalPositionDataRepository
    var dataToTestPDF: Data?
    var actions: [LoanTransactionDetailActionRepresentable] = []
    var fields = LoanTransactionDetailConfigurationMock(.empty)
    
    init(injector: MockDataInjector) {
        self.injector = injector
        self.globalPositionRepository = MockGlobalPositionDataRepository(injector.mockDataProvider.gpData.getGlobalPositionMock)
    }
    
    func resolve() -> GlobalPositionDataRepository {
        return globalPositionRepository
    }
    
    func resolve() -> LoanReactiveRepository {
        MockLoanRepository(mockDataInjector: injector)
    }
    
    func resolve() -> AppConfigRepositoryProtocol {
        MockAppConfigRepository(mockDataInjector: injector)
    }
    
    func loanDetailCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func loanTransactionsSearchCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func loanTransactionDetailCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func resolve() -> TrackerManager {
        TrackerManagerMock()
    }
   
    func resolve() -> UINavigationController {
        UINavigationController()
    }
    
    func resolve() -> TimeManager {
        fatalError()
    }
    
    func resolve() -> DependenciesResolver {
        fatalError()
    }
    
    func resolve() -> NavigationBarItemBuilder {
        fatalError()
    }
    
    func privateMenuCoordinator() -> Coordinator {
        ToastCoordinator()
    }
    
    func globalSearchCoordinator() -> Coordinator {
        ToastCoordinator()
    }
    
    func loanRepaymentCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func loanChangeLinkedAccountCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
}

extension TestLoanTransactionDetailExternalDependencies: LoanTransactionDetailExternalDependenciesResolver {
    func resolve() -> GetLoanPDFInfoUseCase {
        return MockGetLoanPDFInfoUseCase(self.dataToTestPDF)
    }
    
    func resolve() -> GetLoanTransactionDetailActionUseCase {
        return MockGetLoanTransactionDetailActionUseCase(self.actions)
    }
    
    func resolve() -> GetLoanTransactionDetailConfigurationUseCase {
        return MockGetLoanTransactionDetailConfigurationUseCase(self.fields)
    }
    
    func resolve() -> AccountNumberFormatterProtocol {
        fatalError()
    }
    
    func loanTransactionDetailActionsCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
}
