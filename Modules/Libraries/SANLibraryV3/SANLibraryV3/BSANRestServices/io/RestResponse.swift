import SwiftyJSON

public class RestResponse: RestParser{
    
    var httpCode: Int?
    var httpMessage: String?
    var moreInformation: String?
    
    public required init(json: JSON) {
        self.httpCode = json["httpCode"].int
        self.httpMessage = json["httpMessage"].string
        self.moreInformation = json["moreInformation"].string
    }
}
