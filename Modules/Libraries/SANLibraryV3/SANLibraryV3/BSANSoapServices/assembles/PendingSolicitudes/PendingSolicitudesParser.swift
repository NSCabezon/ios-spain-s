import Foundation
import Fuzi

public class PendingSolicitudesParser: BSANParser<PendingSolicitudesResponse, PendingSolicitudesHandler> {
    
    override func setResponseData() {
        response.pendingSolicitudeList = handler.pendingSolicitudeList
    }
}

public class PendingSolicitudesHandler: BSANHandler {
    
    fileprivate var pendingSolicitudeList = PendingSolicitudeListDTO(solicitudesDTOs: [])
    
    override func parseResult(result: XMLElement) throws {
        try result.children.forEach(parseElement)
    }
    
    override func parseElement(element: XMLElement) throws {
        var pendingSolicitudesDTO = PendingSolicitudeDTO()
        pendingSolicitudesDTO.name = element.firstChild(tag: "nombreSolicitud")?.stringValue.trim()
        pendingSolicitudesDTO.startDate = DateFormats.safeDate(element.firstChild(tag: "fechaAlta")?.stringValue)
        pendingSolicitudesDTO.expirationDate = DateFormats.safeDate(element.firstChild(tag: "fechaVigencia")?.stringValue)
        pendingSolicitudesDTO.businessCode = element.firstChild(tag: "codProcesoNegocio")?.stringValue.trim()
        pendingSolicitudesDTO.solicitudeState = element.firstChild(tag: "estadoSolicitud")?.stringValue.trim()
        pendingSolicitudesDTO.solicitudeType = element.firstChild(tag: "tipoSolicitud")?.stringValue.trim()
        pendingSolicitudesDTO.chanel = element.firstChild(tag: "canal")?.stringValue.trim()
        pendingSolicitudesDTO.chanelDescription = element.firstChild(tag: "descCanal")?.stringValue.trim()
        pendingSolicitudesDTO.rightWithdrawal = element.firstChild(tag: "derechoDesistimiento")?.stringValue.trim()
        pendingSolicitudesDTO.sign = element.firstChild(tag: "indParamsFirma")?.stringValue.trim()
        pendingSolicitudesDTO.identifier = element.firstChild(tag: "idSolicitud")?.stringValue.trim()
        self.pendingSolicitudeList.solicitudesDTOs?.append(pendingSolicitudesDTO)
    }
}
