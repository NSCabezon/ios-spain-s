import CoreDomain

public protocol AdobeTargetRepository {
    func getAdobeTargetOfferRequest(input: AdobeTargetOfferInputRepresentable) throws -> Result<AdobeTargetOfferRepresentable, Error>
}
