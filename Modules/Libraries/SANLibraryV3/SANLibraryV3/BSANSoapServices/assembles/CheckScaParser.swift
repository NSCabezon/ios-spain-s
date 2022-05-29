import Foundation
import Fuzi

public class CheckScaParser: BSANParser<CheckScaResponse, CheckScaHandler> {
        
    override func setResponseData() {
        response.checkScaDTO = handler.checkScaDTO
    }
}

public class CheckScaHandler: BSANHandler {
    fileprivate var checkScaDTO: CheckScaDTO?
    
    override func parseResult(result: XMLElement) throws {
       let loginIndicator: ScaLoginState? = ScaLoginState(rawValue: result.firstChild(tag: "indLoginSCA")?.stringValue.trim() ?? "")
       let accountIndicator: ScaAccountState? = ScaAccountState(rawValue: result.firstChild(tag: "indCtasSCA")?.stringValue.trim() ?? "")
       let penalizeDate: Date? = DateFormats.safeDate(result.firstChild(tag: "fechaPenaliza")?.stringValue.trim(), format: .DDMMYYYY_HHmmssSSSSSS)
       let systemDate: Date? = DateFormats.safeDate(result.firstChild(tag: "fechaSistema")?.stringValue.trim(), format: .DDMMYYYY_HHmmssSSSSSS)
       checkScaDTO = CheckScaDTO(loginIndicator: loginIndicator, accountIndicator: accountIndicator, penalizeDate: penalizeDate, systemDate: systemDate)
    }
}


