import Cards
import CoreDomain
import OpenCombine

final class MockGetCardDetailConfigurationUseCase: GetCardDetailConfigurationUseCase {
    var getCardDetailConfigUseCaseCalled: Bool = false
    let mockCardDetailConfiguration = CardDetailConfiguration(card: MockCard(), cardDetail: MockCardDetail())
    
    func fetchCardDetailConfiguration(card: CardRepresentable, cardDetail: CardDetailRepresentable) -> AnyPublisher<CardDetailConfiguration, Never> {
        getCardDetailConfigUseCaseCalled = true
        return Just(mockCardDetailConfiguration).eraseToAnyPublisher()
    }
}
