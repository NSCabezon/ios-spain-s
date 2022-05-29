import Loans
import CoreFoundationLib

final class LoansHomeCoordinatorNavigator: ModuleCoordinatorNavigator {
    var operativeCoordinatorLauncher: OperativeCoordinatorLauncher {
        return self.dependenciesEngine.resolve()
    }
    
    func didSelectChangeLinkedAccount(for loan: LoanEntity) {
        changeLinkedAccount(forLoan: Loan(loan), withDelegate: self)
    }
    
    func goToWebView(configuration: WebViewConfiguration) {
        dependencies.navigatorProvider.privateHomeNavigator.goToWebView(with: configuration, linkHandler: nil, dependencies: self.dependencies, errorHandler: self.errorHandler, didCloseClosure: nil)
    }
}


extension LoansHomeCoordinatorNavigator: LoanOperativeLauncher {}
