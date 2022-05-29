import Foundation
import Fuzi

class CampaignDTOParser: DTOParser  {
    
    public static func parse(_ node: XMLElement) -> CampaignDTO {
        var campaignDTO = CampaignDTO()
        campaignDTO.title = node.firstChild(tag:"titulo")?.stringValue.trim()
        campaignDTO.urlCommercialContact = node.firstChild(tag:"urlContComercial")?.stringValue.trim()
        campaignDTO.urlCommercialContactEng = node.firstChild(tag:"urlContComercialIngles")?.stringValue.trim()
        campaignDTO.urlButton = node.firstChild(tag:"urlBoton")?.stringValue.trim()
        campaignDTO.buttonType = safeInteger(node.firstChild(tag:"tipoBoton")?.stringValue.trim())
        campaignDTO.indActivateFunction = safeInteger(node.firstChild(tag:"indActivarFuncion")?.stringValue)
        campaignDTO.indShowCheck = safeInteger(node.firstChild(tag:"indMostrarCheck")?.stringValue)
        campaignDTO.activationDate = DateFormats.safeDate(node.firstChild(tag:"fechaActivacion")?.stringValue)
        campaignDTO.deactivationDate = DateFormats.safeDate(node.firstChild(tag:"fechaDesactivacion")?.stringValue)
        campaignDTO.indPriority = safeInteger(node.firstChild(tag:"indPrioridad")?.stringValue)
        campaignDTO.idRule = node.firstChild(tag:"idCampanya")?.stringValue
        return campaignDTO
    }
}
