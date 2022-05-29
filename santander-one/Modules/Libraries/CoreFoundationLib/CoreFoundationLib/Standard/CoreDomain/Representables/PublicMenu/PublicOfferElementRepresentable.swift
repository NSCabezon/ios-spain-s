import CoreDomain

public protocol PublicOfferElementRepresentable {
    var titleKey: String { get }
    var imageURL: String { get }
    var description: String? { get }
    var offerId: String? { get }
    var tag: String? { get }
    var offerRepresentable: OfferRepresentable? { get }
    var keyWords: [String]? { get }
}
