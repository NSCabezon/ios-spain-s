import Foundation
import Fuzi

class CampaignDTOsParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> [CampaignDTO] {
        var campaignDTOs:  [CampaignDTO] = []
        for element in node.children {
            campaignDTOs.append(CampaignDTOParser.parse(element))
        }
        return campaignDTOs
    }
}
