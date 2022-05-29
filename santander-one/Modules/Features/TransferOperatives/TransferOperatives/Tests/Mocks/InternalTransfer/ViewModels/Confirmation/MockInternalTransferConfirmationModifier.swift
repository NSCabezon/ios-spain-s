import TransferOperatives
import CoreDomain

struct MockInternalTransferConfirmationModifier: InternalTransferConfirmationModifierProtocol {
    var additionalFeeKey: String { "" }
    var additionalFeeLinkKey: String? { nil }
    var additionalFeeLink: String? { nil }
    var additionalFeeIconKey: String { "" }
    
    func freeTransferFor(originAccount: AccountRepresentable, destinationAccount: AccountRepresentable, date: Date) -> Bool {
        return true
    }
}
