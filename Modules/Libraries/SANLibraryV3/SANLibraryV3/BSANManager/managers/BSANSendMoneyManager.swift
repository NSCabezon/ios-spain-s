import CoreFoundationLib
import SANLegacyLibrary

public class BSANSendMoneyManagerImplementation: BSANBaseManager, BSANSendMoneyManager {
    
    var sanSoapServices: SanSoapServices
    
    public init(bsanDataProvider: BSANDataProvider, sanSoapServices: SanSoapServices) {
        self.sanSoapServices = sanSoapServices
        super.init(bsanDataProvider: bsanDataProvider)
    }

    public func getCMPSStatus() throws -> BSANResponse<CMPSDTO> {
        let cmpsDTO = try bsanDataProvider.get(\.cmpsDTO)
        return BSANOkResponse(cmpsDTO)
    }

    public func loadCMPSStatus() throws -> BSANResponse<CMPSDTO> {
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = GetCMPSStatusRequest(
            BSANAssembleProvider.getSendMoneyAssemble(),
            try bsanDataProvider.getEnvironment().urlBase, GetCMPSStatusRequestParams(token: authCredentials.soapTokenCredential, userDataDTO: userDataDTO, linkedCompany: bsanHeaderData.linkedCompany, dialectISO: bsanHeaderData.dialectISO, languageISO: bsanHeaderData.languageISO, benefPhoneCMPS: nil))
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK(), var cmpsdto = response.cmpsdto {
            BSANLogger.i(logTag, "Meta OK");
            let otpPhoneCiphered = response.telefonoOTPCifrado
            if let otpPhoneCiphered = otpPhoneCiphered, !otpPhoneCiphered.isEmpty {
                cmpsdto.otpPhoneDecrypted = decryptPhone(userDataDTO, otpPhoneCiphered)
            }
            bsanDataProvider.storeCMPS(cmpsdto: cmpsdto)
            return BSANOkResponse(meta, cmpsdto)
        }
        return BSANErrorResponse(meta)
    }
    
    private func decryptPhone(_  userDataDTO: UserDataDTO , _ otpPhoneCiphered: String) -> String {
        do {
            guard let contract = userDataDTO.contract else {
                return ""
            }
            let cmc = ("\(contract.bankCode ?? "")\(contract.branchCode ?? "")\(contract.product ?? "")\(contract.contractNumber ?? "")")
            let canalMarco = userDataDTO.channelFrame
            let tipoPersona = userDataDTO.clientPersonType
            let codigoPersona = userDataDTO.clientPersonCode
            var claveCifrado = "\(cmc)\(canalMarco ?? "")\(tipoPersona ?? "")\(codigoPersona ?? "")"
            BSANLogger.d(logTag, "Clave cifrado (pre-fill): " + claveCifrado)
            let count = claveCifrado.count
            if (count < 32) {
                for _ in (count..<32) {
                    claveCifrado += "0"
                }
            }
            if bsanDataProvider.isDemo() {
                //claveCifrado = "004900013390003256RMLF1246469960";
                //WTF Como se rellena esto? Faltan 2
                claveCifrado = "004969023390349696RMLF1102355900";
            }
            BSANLogger.d(logTag, "Clave cifrado: " + claveCifrado);
            BSANLogger.d(logTag, "Teléfono Cifrado: " + otpPhoneCiphered);
            guard let claveCifrado32 = claveCifrado.substring(0, 32) else {
                return ""
            }
            let telefonoDescifrado = try DataCipher.decryptDESde(otpPhoneCiphered, claveCifrado32)
            BSANLogger.d(logTag, "Teléfono OTP Descifrado correctamente! \"" + telefonoDescifrado + "\"");
            do {
                let testCipher = try DataCipher.encryptDESde(telefonoDescifrado, claveCifrado.substring(0, 32)!)
                BSANLogger.d(logTag, "Teléfono re-cifrado: " + testCipher)
            } catch let error {
                BSANLogger.e(logTag, "decryptPhone \(error.localizedDescription)")
            }
            return telefonoDescifrado
        } catch let error {
            BSANLogger.d(logTag, "Error al descifrar teléfono OTP!")
            BSANLogger.e(logTag, "decryptPhone \(error.localizedDescription)")
            return ""
        }
    }
}
