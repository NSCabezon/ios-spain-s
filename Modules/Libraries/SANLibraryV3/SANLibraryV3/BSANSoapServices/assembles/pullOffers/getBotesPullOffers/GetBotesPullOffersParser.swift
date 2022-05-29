import Foundation
import Fuzi

public class GetBotesPullOffersParser : BSANParser<GetBotesPullOffersResponse, GetBotesPullOffersHandler> {
    override func setResponseData(){
        response.campaignDTOs = handler.campaignDTOs
    }
}

public class GetBotesPullOffersHandler: BSANHandler {
    
    var campaignDTOs: [CampaignDTO] = []
    
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
        case "info":
            break
        case "listaCamp":
            campaignDTOs = CampaignDTOsParser.parse(element)
            break
        default:
            BSANLogger.e("GetBotesPullOffersParser", "Nodo Sin Parsear! -> \(tag)")
        }
    }
    
}
