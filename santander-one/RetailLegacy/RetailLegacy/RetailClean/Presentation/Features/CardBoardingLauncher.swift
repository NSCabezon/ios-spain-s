import Cards
import CoreFoundationLib
import Operative

protocol CardBoardingLauncher: class {
    func gotoCardBoarding(delegate: CardboardingLauncherDelegate)
}

protocol CardboardingLauncherDelegate: AnyObject {
    var dependencies: PresentationComponent { get }
    var genericErrorHandler: GenericPresenterErrorHandler { get }
    func startLoading()
    func endLoading(completion: (() -> Void)?)
    func goToCardBoardingActivationWithCard(_ card: CardEntity)
    func gotoCardBoardingCustomizingCard(_ card: CardEntity)
    func gotoCardsSelectionHomeWithCards(_ cards: [CardEntity])
}

extension CardBoardingLauncher {
    func gotoCardBoarding(delegate: CardboardingLauncherDelegate) {
        delegate.startLoading()
        let usecase = delegate.dependencies.useCaseProvider.getVisibleCardsUseCase()
        let handler = delegate.dependencies.useCaseHandler
        Scenario(useCase: usecase)
            .execute(on: handler)
            .onSuccess { result in
                let cards = result.cards
                guard !cards.isEmpty else {
                    delegate.endLoading {
                        delegate.genericErrorHandler.onError(keyDesc: "deeplink_alert_cardBoarding",
                                                             completion: {})
                    }
                    return
                }
                delegate.endLoading {
                    if cards.count == 1, let lonelyCard = cards.first {
                        self.performOneCardFlowWithCard(lonelyCard, launcherDelegate: delegate)
                    } else {
                        self.performMultipleCardsFlow(cards: cards, launcherDelegate: delegate)
                    }
                }
            }
    }
}

private extension CardBoardingLauncher {
    func performOneCardFlowWithCard(_ card: CardEntity, launcherDelegate: CardboardingLauncherDelegate) {
        if card.inactive {
            launcherDelegate.goToCardBoardingActivationWithCard(card)
        } else if !card.inactive {
            launcherDelegate.gotoCardBoardingCustomizingCard(card)
        }
    }
    
    func performMultipleCardsFlow(cards: [CardEntity], launcherDelegate: CardboardingLauncherDelegate) {
        launcherDelegate.gotoCardsSelectionHomeWithCards(cards)
    }
}
