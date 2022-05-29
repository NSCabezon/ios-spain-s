import CoreFoundationLib

final class AccountsTransactionDetailCoordinatorMock: AccountTransactionDetailCoordinatorDelegate {
    func didSelectOffer(offer: OfferEntity) {}
    func didSelectAction(_ action: AccountTransactionDetailAction, _ transaction: AccountTransactionEntity, detail: AccountTransactionDetailEntity?, account: AccountEntity) {}
    func didSelectMenu() {}
    func didSelectOffer(offer: OfferEntity, location: PullOfferLocation) {}
}
