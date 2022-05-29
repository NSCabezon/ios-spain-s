import Foundation
import CoreFoundationLib
import SANLegacyLibrary

protocol CardModifyPaymentFormLauncher {
     func modifyPayment(product: Card?, delegate: OperativeLauncherDelegate)
}

extension CardModifyPaymentFormLauncher {
    func modifyPayment(product: Card?, delegate: OperativeLauncherDelegate) {
        let operative = CardModifyPaymentFormOperative(dependencies: delegate.dependencies)
        guard let container = delegate.navigatorOperativeLauncher.appendOperative(operative, dependencies: delegate.dependencies) else { return }
        let operativeData = CardModifyPaymentFormOperativeData(card: product)
        container.saveParameter(parameter: operativeData)
        operative.start(needsSelection: product == nil, container: container, delegate: delegate.operativeDelegate)
    }
}
