//

import Foundation

public class EnvironmentOld: NSObject, NSCoding {
    public let name: String?
    public let endpointURL: String?
    public let sociusEndpointURL: String?
    public let bizumRegisterURL: String?
    public let bizumUrl: String?
    public let forgotPasswordUrl: String?
    public let activateKeysUrl: String?
    public let restAPIBaseUrl: String?
    public let restAPIClientId: String?
    public let restAPIClientSecret: String?
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(endpointURL, forKey: "endpointURL")
        aCoder.encode(sociusEndpointURL, forKey: "sociusEndpointURL")
        aCoder.encode(bizumRegisterURL, forKey: "bizumRegisterURL")
        aCoder.encode(bizumUrl, forKey: "bizumUrl")
        aCoder.encode(forgotPasswordUrl, forKey: "forgotPasswordUrl")
        aCoder.encode(activateKeysUrl, forKey: "activateKeysUrl")
        aCoder.encode(restAPIBaseUrl, forKey: "restAPIBaseUrl")
        aCoder.encode(restAPIClientId, forKey: "restAPIClientId")
        aCoder.encode(restAPIClientSecret, forKey: "restAPIClientSecret")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObject(forKey: "name") as? String
        self.endpointURL = aDecoder.decodeObject(forKey: "endpointURL") as? String
        self.sociusEndpointURL = aDecoder.decodeObject(forKey: "sociusEndpointURL") as? String
        self.bizumRegisterURL = aDecoder.decodeObject(forKey: "bizumRegisterURL") as? String
        self.bizumUrl = aDecoder.decodeObject(forKey: "bizumUrl") as? String
        self.forgotPasswordUrl = aDecoder.decodeObject(forKey: "forgotPasswordUrl") as? String
        self.activateKeysUrl = aDecoder.decodeObject(forKey: "activateKeysUrl") as? String
        self.restAPIBaseUrl = aDecoder.decodeObject(forKey: "restAPIBaseUrl") as? String
        self.restAPIClientId = aDecoder.decodeObject(forKey: "restAPIClientId") as? String
        self.restAPIClientSecret = aDecoder.decodeObject(forKey: "restAPIClientSecret") as? String
    }
}
