import Foundation
import CoreFoundationLib

final class UnreadAccountItemCrossSellingViewModel: UnreadCrossSellingViewProtocol {
    private let crossSellingParams: AccountsCTAParameters
    private let offers: [PullOfferLocation: OfferEntity]
    private let accountTransaction: AccountTransactionWithAccountEntity
    var crossSellingSelected: CrossSellingRepresentable?
    
    init(accountTransaction: AccountTransactionWithAccountEntity,
         crossSellingParams: AccountsCTAParameters,
         offers: [PullOfferLocation: OfferEntity]) {
        self.accountTransaction = accountTransaction
        self.crossSellingParams = crossSellingParams
        self.offers = offers
    }
    
    var index: Int {
        guard let accountCrossSelling = self.crossSellingSelected as? AccountMovementsCrossSellingProperties else { return -1 }
        return crossSellingParams
            .accountsCrossSelling
            .firstIndex(of: accountCrossSelling) ?? -1
    }
    
    var isCrossSellingEnabled: Bool {
        guard crossSellingParams.crossSellingEnabled,
              let accountCrossSelling = self.getAccountCrossSelling() else { return false }
        self.crossSellingSelected = accountCrossSelling
        return true
    }
    
    func getAccountCrossSelling() -> AccountMovementsCrossSellingProperties? {
        let values = getCrossSellingWithAccountValues()
        return CrossSellingBuilder(
            itemsCrossSelling: crossSellingParams.accountsCrossSelling,
            transaction: accountTransaction.accountTransactionEntity.dto.description,
            amount: accountTransaction.accountTransactionEntity.amount?.value,
            crossSellingValues: values
        )
        .getCrossSelling()
    }
}

private extension UnreadAccountItemCrossSellingViewModel {
    func getCrossSellingWithAccountValues() -> CrossSellingValues {
        let availableAmount = accountTransaction.accountEntity.availableAmount?.value ?? 0
        let accountValues = AccountValues(availableAmount)
        let values = CrossSellingValues(accountValues: accountValues)
        return values
    }
}

extension UnreadAccountItemCrossSellingViewModel: AccountEasyPayChecker { }
