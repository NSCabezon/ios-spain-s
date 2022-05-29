import Foundation
import CoreFoundationLib
import SANLegacyLibrary

public class SANUserOld: NSObject, NSCoding {
    public let password: String?
    public let document: String?
    public let loginType: Int? //UserLoginType
    public let clientName: String?
    public let userType: Int? //UserType
    public let userData: UserDataOld? //UserData
    public let userSegment: UserSegmentOld? //UserSegment
    public let deviceToken: String?
    public let environment: EnvironmentOld? //Environment
    public let retailUser: Bool?
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(password, forKey: "password")
        aCoder.encode(document, forKey: "document")
        aCoder.encode(loginType, forKey: "loginType")
        aCoder.encode(clientName, forKey: "clientName")
        aCoder.encode(userType, forKey: "userType")
        aCoder.encode(userData, forKey: "userData")
        aCoder.encode(userSegment, forKey: "userSegment")
        aCoder.encode(deviceToken, forKey: "deviceToken")
        aCoder.encode(environment, forKey: "environment")
        aCoder.encode(retailUser, forKey: "retailUser")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.password = aDecoder.decodeObject(forKey: "password") as? String
        self.document = aDecoder.decodeObject(forKey: "document") as? String
        self.loginType = aDecoder.decodeObject(forKey: "loginType") as? Int
        self.clientName = aDecoder.decodeObject(forKey: "clientName") as? String
        self.userType = aDecoder.decodeObject(forKey: "userType") as? Int
        self.userData = aDecoder.decodeObject(forKey: "userData") as? UserDataOld
        self.userSegment = aDecoder.decodeObject(forKey: "userSegment") as? UserSegmentOld
        self.deviceToken = aDecoder.decodeObject(forKey: "deviceToken") as? String
        self.environment = aDecoder.decodeObject(forKey: "environment") as? EnvironmentOld
        self.retailUser = aDecoder.decodeObject(forKey: "retailUser") as? Bool
    }
    
    func getUserLoginType() -> UserLoginType {
        switch loginType {
        case 0:
            return UserLoginType.N
        case 1:
            return UserLoginType.C
        case 2:
            return UserLoginType.S
        case 3:
            return UserLoginType.I
        case 4:
            return UserLoginType.U
        default:
            return UserLoginType.U
        }
    }
    
    func isPB() -> Bool {
        guard let retailUser = retailUser else { return false }
        return !retailUser
    }
    
    func channelFrame() -> String {
        guard let channel = userData?.canalMarco else { return "" }
        return channel
    }
    
    func getBdpCode() -> String {
        guard let bdpCode = userSegment?.segmentoBDP else { return "" }
        return bdpCode
    }
    
    func getCommercialCode() -> String {
        guard let commercialCode = userSegment?.segmentoComercial else { return "" }
        return commercialCode
    }
}
