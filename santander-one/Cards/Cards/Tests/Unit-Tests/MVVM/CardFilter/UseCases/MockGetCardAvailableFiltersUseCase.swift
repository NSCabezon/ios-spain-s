import Cards
import CoreDomain
import OpenCombine
import CoreFoundationLib

final class MockGetCardAvailableFiltersUseCase: CardTransactionAvailableFiltersUseCase {
    var getCardAvailableFiltersCaseCalled: Bool = false
    let mockAvailableFilters = CardAvailableFilters()
    
    func fetchAvailableFiltersPublisher() -> AnyPublisher<CardTransactionAvailableFiltersRepresentable, Never> {
        getCardAvailableFiltersCaseCalled = true
        return Just(mockAvailableFilters).eraseToAnyPublisher()
    }
    
}
