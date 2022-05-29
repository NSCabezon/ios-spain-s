import UnitTestCommons
import CoreFoundationLib
@testable import Cards

final class CardBoardingProtocolMock: CardBoardingCoordinatorProtocol {
    var isGoingForward: SpyableObject<Bool> = SpyableObject(value: false)
    
    func didSelectGoFoward() {
        self.isGoingForward.value = true
    }
    
    func didSelectGoBackwards() {}
    func didSelectGoToMyCards(card: CardEntity) {}
    func didSelectGoToGlobalPosition() {}
    func reloadGlobalPosition() {}
}
