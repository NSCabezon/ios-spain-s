//

import Foundation
import SANLegacyLibrary

public class BSANPendingSolicitudesManagerImplementation: BSANBaseManager, BSANPendingSolicitudesManager {
    
    var sanSoapServices: SanSoapServices

    public init(bsanDataProvider: BSANDataProvider, sanSoapServices: SanSoapServices) {
        self.sanSoapServices = sanSoapServices
        super.init(bsanDataProvider: bsanDataProvider)
    }
    
    public func getPendingSolicitudes() throws -> BSANResponse<PendingSolicitudeListDTO> {
        
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getPendingSolicitudes()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()

        let userDataDTO = try bsanDataProvider.getUserData()
        let solicitudesDTOs = try bsanDataProvider.get(\.pendingSolicitudes)
        
        guard solicitudesDTOs == nil else {
            let pendingSolicitudesList = PendingSolicitudeListDTO(solicitudesDTOs: solicitudesDTOs ?? [])
            return BSANOkResponse(pendingSolicitudesList)
        }
        
        let params = PendingSolicitudesRequestParams(token: authCredentials.soapTokenCredential,
                                                     userDataDTO: userDataDTO,
                                                     language: bsanHeaderData.languageISO,
                                                     dialect: bsanHeaderData.dialectISO)
        
        let request = PendingSolicitudesRequest(bsanAssemble, bsanEnvironment.urlBase, params)
        
        let response: PendingSolicitudesResponse = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        
        guard meta.isOK() else {
            return BSANErrorResponse(meta)
        }
        
        BSANLogger.i(logTag, "Meta OK")
        bsanDataProvider.store(pendingSolicitudes: response.pendingSolicitudeList.solicitudesDTOs)
        return BSANOkResponse(meta, response.pendingSolicitudeList)
    }
    
    public func removePendingSolicitudes() {
         bsanDataProvider.store(pendingSolicitudes: nil)
    }
}
