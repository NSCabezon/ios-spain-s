import OpenCombine
import SavingProducts

final class MockGetSavingProductComplementaryDataUseCase: GetSavingProductComplementaryDataUseCase {
    func fechComplementaryDataPublisher() -> AnyPublisher<[String : [DetailTitleLabelType]], Never> {
        return Just([
         "SAVINGS": [.balanceInclPending, .pending, .interestRate],
         "BONDS": [.availableBalance, .interestRate],
         "ISA": [.availableBalance, .interestRate, .contributionsToDate, .contributionsRemaining]
        ]).eraseToAnyPublisher()
    }
}
