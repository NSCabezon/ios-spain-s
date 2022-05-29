import Cards
import CoreDomain
import OpenCombine

final class MockGetCardDetailConfigurationUseCase: GetCardDetailConfigurationUseCase {
    var getCardDetailConfigUseCaseCalled: Bool = false
    let mockCardDetailConfiguration = CardDetailConfiguration(card: MockCard())
    
    func fetchCardDetailConfiguration(card: CardRepresentable) -> AnyPublisher<CardDetailConfiguration, Never> {
        getCardDetailConfigUseCaseCalled = true
        return Just(mockCardDetailConfiguration).eraseToAnyPublisher()
    }
    
}
