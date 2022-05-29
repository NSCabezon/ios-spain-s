import Foundation
import CoreDomain

public struct AdobeTargetOfferQueryInputDTO: Codable {
    public let groupId: String? = nil
    public let locationId: String? = nil
    public let channelId: String? = "MOV"
    public let countryCode: String? = "ES"
    public let languageCode: String? = "ES"
    public let screenWidth: CGFloat?
    public let screenHeight: CGFloat?
    public let customerContext: String? = "Retail"
    public let customerContextId: String? = nil

    public init(screenWidth: CGFloat, screenHeight: CGFloat) {
        self.screenWidth = screenWidth
        self.screenHeight = screenHeight
    }

    // Do not remove. We need to encode explicitly to be able to include requested customerContextId null value in body parameters
    public func encode(to encoder: Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encode(channelId, forKey: .channelId)
          try container.encode(countryCode, forKey: .countryCode)
          try container.encode(languageCode, forKey: .languageCode)
          try container.encode(screenWidth, forKey: .screenWidth)
          try container.encode(screenHeight, forKey: .screenHeight)
          try container.encode(customerContext, forKey: .customerContext)
          try container.encode(customerContextId, forKey: .customerContextId)
      }
}

 extension AdobeTargetOfferQueryInputDTO: AdobeTargetOfferInputRepresentable {}

