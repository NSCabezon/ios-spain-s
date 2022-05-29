import UnitTestCommons
import CoreFoundationLib
@testable import Cards

final class CardBoardingWelcomeViewMock: CardBoardingWelcomeViewProtocol {
    var isTipsCarouselVisible: SpyableObject<Bool> = SpyableObject(value: false)

    func showCard(viewModel: PlasticCardViewModel) { }

    func showOffers(_ offers: [OfferTipViewModel]) {
        guard offers.count > 0 else {
            self.isTipsCarouselVisible.value = false
            return
        }
        self.isTipsCarouselVisible.value = true
    }
}
