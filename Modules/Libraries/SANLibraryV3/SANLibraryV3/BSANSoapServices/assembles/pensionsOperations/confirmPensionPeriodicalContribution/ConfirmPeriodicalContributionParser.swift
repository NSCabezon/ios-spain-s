import Fuzi

public class ConfirmPeriodicalContributionParser: BSANParser<BSANSoapResponse, ConfirmPeriodicalContributionHandler> {
    override func setResponseData(){
    }
}

public class ConfirmPeriodicalContributionHandler: BSANHandler {
    override func parseResult(result: XMLElement) throws {
    }
}
