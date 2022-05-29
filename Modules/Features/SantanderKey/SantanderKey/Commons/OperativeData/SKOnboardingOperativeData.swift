import Foundation
import CoreDomain
import CoreFoundationLib
import UIOneComponents
import SANSpainLibrary

public enum SKOnboardingStatus: Int {
    case alreadyRegistered = 0
    case registeredInOtherDevice = 1
    case safeDeviceWithoutSanKey = 2
    case notRegistered = 5
}

public enum SKAuthMethod {
    case pin
    case sign
}

public final class SKOnboardingOperativeData {
    public var clientStatus: SKOnboardingStatus?
    public var authMethod: SKAuthMethod?
    public var sanKeyId: String?
    public var cardList: [SantanderKeyCardRepresentable]?
    public var selectedCardPAN: String?
    public var cardType: String?
    public var selectedCardPIN: String?
    public var signPositions: String?
    public var otpReference: String?
    public var alias: String?
}
