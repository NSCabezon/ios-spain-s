import Foundation
import Fuzi

public class ConfirmCVVParser : BSANParser <ConfirmCVVResponse, ConfirmCVVHandler> {
    override func setResponseData(){
        response.numberCipherDTO = handler.numberCipherDTO
    }
}

public class ConfirmCVVHandler: BSANHandler {
    
    var numberCipherDTO = NumberCipherDTO()
    
    override func parseResult(result: XMLElement) throws {
        numberCipherDTO = NumberCipherDTOParser.parse(result)
    }
}
