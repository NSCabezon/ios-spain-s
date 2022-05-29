import Foundation
import Fuzi

public class CMCSignatureParser : BSANParser<CMCSignatureResponse, CMCSignatureHandler> {
    override func setResponseData(){
        response.signatureDataDTO = handler.signatureDataDTO
    }
}

public class CMCSignatureHandler: BSANHandler {
    
    var signatureDataDTO: SignatureDataDTO = SignatureDataDTO()
    
    override func parseResult(result: XMLElement) throws {
        signatureDataDTO = SignatureDataDTOParser.parse(result)
    }
}
