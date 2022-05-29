import CoreFoundationLib
@testable import Cards
@testable import CoreFoundationLib

final class GetTipsUseCaseErrorMock: CardBoardingWelcomeUseCase {
    override public func executeUseCase(requestValues: GetCardBoardingWelcomeUseCaseInput) throws -> UseCaseResponse<GetCardBoardingWelcomeUseCaseOkOutput, StringErrorOutput> {
        return UseCaseResponse.error(StringErrorOutput(nil))
    }
}

final class GetTipsUseCaseEmptyMock: CardBoardingWelcomeUseCase {
    override public func executeUseCase(requestValues: GetCardBoardingWelcomeUseCaseInput) throws -> UseCaseResponse<GetCardBoardingWelcomeUseCaseOkOutput, StringErrorOutput> {
        return UseCaseResponse.ok(GetCardBoardingWelcomeUseCaseOkOutput(tips: []))
    }
}

final class GetTipsUseCaseNilMock: CardBoardingWelcomeUseCase {
    override public func executeUseCase(requestValues: GetCardBoardingWelcomeUseCaseInput) throws -> UseCaseResponse<GetCardBoardingWelcomeUseCaseOkOutput, StringErrorOutput> {
        return UseCaseResponse.ok(GetCardBoardingWelcomeUseCaseOkOutput(tips: nil))
    }
}

final class GetTipsUseCaseMock: CardBoardingWelcomeUseCase {
    override public func executeUseCase(requestValues: GetCardBoardingWelcomeUseCaseInput) throws -> UseCaseResponse<GetCardBoardingWelcomeUseCaseOkOutput, StringErrorOutput> {
        let tips = [PullOfferTipEntity(PullOffersConfigTipDTO(PullOffersHomeTipsContentDTO(title: "",
                                                                                           desc: "",
                                                                                           icon: "",
                                                                                           tag: "",
                                                                                           offerId: "",
                                                                                           keyWords: [])),
                                       offer: OfferDTO(product: OfferProductDTO(identifier: "",
                                                                                neverExpires: true,
                                                                                transparentClosure: true,
                                                                                description: "",
                                                                                rulesIds: [],
                                                                                iterations: 1,
                                                                                banners: [],
                                                                                bannersContract: [],
                                                                                action: .none,
                                                                                startDateUTC: Date(),
                                                                                endDateUTC: Date())))]
        return UseCaseResponse.ok(GetCardBoardingWelcomeUseCaseOkOutput(tips: tips))
    }
}
