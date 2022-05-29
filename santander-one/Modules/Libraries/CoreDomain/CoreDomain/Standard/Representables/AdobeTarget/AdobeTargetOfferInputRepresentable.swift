import Foundation

public protocol AdobeTargetOfferInputRepresentable: Codable {
    var groupId: String? { get }
    var locationId: String? { get }
    var channelId: String? { get }
    var countryCode: String? { get }
    var languageCode: String? { get }
    var screenWidth: CGFloat? { get }
    var screenHeight: CGFloat? { get }
    var customerContext: String? { get }
    var customerContextId: String? { get }
}
