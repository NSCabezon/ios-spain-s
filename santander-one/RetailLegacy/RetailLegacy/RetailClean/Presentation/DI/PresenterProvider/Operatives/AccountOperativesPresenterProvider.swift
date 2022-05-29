//

import Foundation
import CoreFoundationLib

class AccountOperativesPresenterProvider {
    
    let navigatorProvider: NavigatorProvider
    let sessionManager: CoreSessionManager
    let dependencies: PresentationComponent
    
    init(navigatorProvider: NavigatorProvider, sessionManager: CoreSessionManager, dependencies: PresentationComponent) {
        self.navigatorProvider = navigatorProvider
        self.sessionManager = sessionManager
        self.dependencies = dependencies
    }
    
    var accountDestinationSelectionPresenter: InternalTransferAccountDestinationSelectionPresenter {
        return InternalTransferAccountDestinationSelectionPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var insertAmountPresenter: InternalTransferInsertAmountPresenter {
        return InternalTransferInsertAmountPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var confirmationPresenter: InternalTransferConfirmationPresenter {
        return InternalTransferConfirmationPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var confirmationDeferredInternalTransferPresenter: InternalDeferredTransferConfirmationPresenter {
        return InternalDeferredTransferConfirmationPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    //InternalPeriodicTransferConfirmationPresenter
    var confirmationPeriodicInternalTransferPresenter: InternalPeriodicTransferConfirmationPresenter {
        return InternalPeriodicTransferConfirmationPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    func transferSearchableConfigurationSelectionPresenter<Item: FilterableSortableAndTitleDescriptionRepresentable>(withItems items: [Item], account: Account?, selected: Item? = nil) -> TransferSearchableConfigurationSelectionPresenter<Item> {
        return TransferSearchableConfigurationSelectionPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.transferSearchableConfigurationSelectionNavigator, account: account, items: items, selected: selected)
    }
    
    var modifyDeferredTransferPresenter: ModifyDeferredTransferPresenter {
        return ModifyDeferredTransferPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var modifyDeferredTransferConfirmationPresenter: ModifyDeferredTransferConfirmationPresenter {
        return ModifyDeferredTransferConfirmationPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var modifyPeriodicTransferConfirmationPresenter: ModifyPeriodicTransferConfirmationPresenter {
        return ModifyPeriodicTransferConfirmationPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var modifyPeriodicTransferPresenter: ModifyPeriodicTransferPresenter {
        return ModifyPeriodicTransferPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var onePayNoSepaTransferConfirmationPresenter: OnePayNoSepaTransferConfirmationPresenter {
        return OnePayNoSepaTransferConfirmationPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var reemittedNoSepaTransferAccountPresenter: ReemittedNoSepaTransferAccountPresenter {
        return ReemittedNoSepaTransferAccountPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.noSepaNaviagator)
    }
    
    var reemittedNoSepaTransferConfirmattionPresenter: ReemittedNoSepaTransferConfirmationPresenter {
        return ReemittedNoSepaTransferConfirmationPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
}
