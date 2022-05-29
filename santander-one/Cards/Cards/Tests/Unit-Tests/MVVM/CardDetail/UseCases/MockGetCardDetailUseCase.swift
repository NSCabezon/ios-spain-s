import Cards
import CoreDomain
import OpenCombine

final class MockGetCardDetailUseCase: GetCardDetailUseCase {
    
    var getCardDetailUseCaseCalled: Bool = false
    var getGlobalPositionUseCalled: Bool = false
    
    func fetchCardDetail(card: CardRepresentable) -> AnyPublisher<CardDetailRepresentable, Error> {
        getCardDetailUseCaseCalled = true
        return Just(MockCardDetail()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func fetchCardGlobalPosition(card: CardRepresentable) -> AnyPublisher<CardRepresentable?, Never> {
        getGlobalPositionUseCalled = true
        return Just(MockCard()).eraseToAnyPublisher()
    }
}
