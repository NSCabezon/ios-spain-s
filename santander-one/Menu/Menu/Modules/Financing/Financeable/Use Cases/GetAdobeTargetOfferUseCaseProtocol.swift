import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

public protocol GetAdobeTargetOfferUseCaseProtocol: UseCase<GetAdobeTargetOfferUseCaseInput, GetAdobeTargetOfferUseCaseOkOutput, StringErrorOutput> {}

public struct GetAdobeTargetOfferUseCaseInput: AdobeTargetOfferInputRepresentable {
    public var groupId: String?
    public var locationId: String?
    public var channelId: String?
    public var countryCode: String?
    public var languageCode: String?
    public var screenWidth: CGFloat?
    public var screenHeight: CGFloat?
    public var customerContext: String?
    public var customerContextId: String?
}

public struct GetAdobeTargetOfferUseCaseOkOutput {
    let adobeTargetOffer: AdobeTargetOfferRepresentable?

    public init(adobeTargetOfferRepresentable: AdobeTargetOfferRepresentable?) {
        self.adobeTargetOffer = adobeTargetOfferRepresentable
    }
}
