import Foundation
import Bills

protocol BillsAndTaxesScannerLauncher {
    func showBillsAndTaxesScannerOperative(_ account: Account?, type: BillsAndTaxesTypeOperativePayment?, delegate: OperativeLauncherDelegate)
}

extension BillsAndTaxesScannerLauncher {    
    func showBillsAndTaxesScannerOperative(_ account: Account?, type: BillsAndTaxesTypeOperativePayment?, delegate: OperativeLauncherDelegate) {
        let operative = BillsAndTaxesOperative(dependencies: delegate.dependencies)
        let typeOperative = BillsAndTaxesTypeOperative(type: type)
        let operativeData = BillAndTaxesOperativeData(account: account, typeOperative: typeOperative)
        guard let container = delegate.navigatorOperativeLauncher.appendOperative(operative, dependencies: delegate.dependencies) else {
            return
        }
        container.saveParameter(parameter: operativeData)
        operative.start(needsSelection: account == nil, container: container, delegate: delegate.operativeDelegate)
    }
}
