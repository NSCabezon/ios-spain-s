//

import Foundation
import CoreFoundationLib

class BillsAndTaxesOperativesPresenterProvider {
    
    let navigatorProvider: NavigatorProvider
    let sessionManager: CoreSessionManager
    let dependencies: PresentationComponent
    
    init(navigatorProvider: NavigatorProvider, sessionManager: CoreSessionManager, dependencies: PresentationComponent) {
        self.navigatorProvider = navigatorProvider
        self.sessionManager = sessionManager
        self.dependencies = dependencies
    }
    
    var accountSelectorPresenter: AccountSelectorPresenter {
        return AccountSelectorPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    //Scanner
    var typeSelectorPresenter: BillsAndTaxesTypeSelectorPresenter {
         return BillsAndTaxesTypeSelectorPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var modeSelectorPresenter: ModeSelectorPresenter {
        return ModeSelectorPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var barcodeScannerPresenter: BarcodeScannerPresenter {
        return BarcodeScannerPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.scannerNavigator)
    }
    
    func scannerErrorPresenter(title: LocalizedStylableText, description: LocalizedStylableText) -> ScannerErrorPresenter {
        return ScannerErrorPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator, title: title, description: description)
    }
    
    var manualModePresenter: ManualModeBillsAndTaxesPresenter {
        return ManualModeBillsAndTaxesPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var billsAndTaxesConfirmationPresenter: BillsAndTaxesConfirmationPresenter {
        return BillsAndTaxesConfirmationPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    // Cancel Direct Billing
    
    var cancelDirectBillingConfirmationPresenter: CancelDirectBillingConfirmationPresenter {
        return CancelDirectBillingConfirmationPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var changeDirectDebitAccountSelectionPresenter: ChangeDirectDebitAccountSelectionPresenter {
        return ChangeDirectDebitAccountSelectionPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var confirmationChangeDirectDebitPresenter: ConfirmationChangeDirectDebitPresenter {
        return ConfirmationChangeDirectDebitPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
}
