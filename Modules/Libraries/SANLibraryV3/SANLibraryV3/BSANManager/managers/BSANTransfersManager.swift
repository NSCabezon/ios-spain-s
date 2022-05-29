import Foundation
import CoreDomain
import SANLegacyLibrary

public class BSANTransfersManagerImplementation: BSANBaseManager, BSANTransfersManager {
    var sanSoapServices: SanSoapServices
    let sanRestServices: SanRestServices

    public init(bsanDataProvider: BSANDataProvider, sanSoapServices: SanSoapServices, sanRestServices: SanRestServices) {
        self.sanSoapServices = sanSoapServices
        self.sanRestServices = sanRestServices
        super.init(bsanDataProvider: bsanDataProvider)
    }
    
// MARK: Usual Transfer
    
    public func loadUsualTransfersOld() throws -> BSANResponse<Void> {
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = GetUsualTransfersOldRequest(
            BSANAssembleProvider.getTransfersAssemble(try bsanDataProvider.isPB()),
            try bsanDataProvider.getEnvironment().urlBase,
            GetUsualTransfersOldRequestParams(token: authCredentials.soapTokenCredential, userDataDTO: userDataDTO, version: bsanHeaderData.version, terminalId: bsanHeaderData.terminalID, language: bsanHeaderData.language))
        
        let response = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            if var payeeDTOs = response.payeeDTOs {
                for i in 0...payeeDTOs.count-1 {
                    payeeDTOs[i].transferAmount = nil
                    payeeDTOs[i].concept = nil
                }
                bsanDataProvider.storeUsualTransfers(payeeDTOs: payeeDTOs)
            }
            return BSANOkResponse(meta)
        }
        return BSANErrorResponse(meta)
    }
    
    public func loadUsualTransfers() throws -> BSANResponse<Void> {
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        var payeeDTOs = [PayeeDTO]()
        let request = GetUsualTransfersRequest(
            BSANAssembleProvider.getUsualTransfersAssemble(),
            try bsanDataProvider.getEnvironment().urlBase,
            GetUsualTransfersRequestParams(token: authCredentials.soapTokenCredential,
                                           userDataDTO: userDataDTO,
                                           language: bsanHeaderData.languageISO,
                                           dialect: bsanHeaderData.dialectISO,
                                           pagination: nil))
        var response: GetUsualTransfersResponse = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        guard (meta.isOK()) else { return BSANErrorResponse(meta) }
        BSANLogger.i(logTag, "Meta OK")
        if let payeeList = response.payeeDTOs {
            payeeDTOs.append(contentsOf: payeeList)
        }
        while response.paginationDTO != nil && response.paginationDTO?.endList == false {
            let request = GetUsualTransfersRequest(
                BSANAssembleProvider.getUsualTransfersAssemble(),
                try bsanDataProvider.getEnvironment().urlBase,
                GetUsualTransfersRequestParams(token: authCredentials.soapTokenCredential,
                                               userDataDTO: userDataDTO,
                                               language: bsanHeaderData.languageISO,
                                               dialect: bsanHeaderData.dialectISO,
                                               pagination: response.paginationDTO))
            response = try sanSoapServices.executeCall(request)
            let meta = try Meta.createMeta(request, response)
            if (meta.isOK()) {
                if let transfers = response.payeeDTOs {
                    payeeDTOs.append(contentsOf: transfers)
                }
            } else {
                BSANLogger.i(logTag, "Meta FAIL")
                break
            }
        }
        for var payee in payeeDTOs {
            payee.transferAmount = nil
            payee.concept = nil
        }
        bsanDataProvider.storeUsualTransfers(payeeDTOs: payeeDTOs)
        return BSANOkEmptyResponse()
    }
    
    public func sepaPayeeDetail(of alias: String, recipientType: String) throws -> BSANResponse<SepaPayeeDetailDTO> {
        let bsanAssemble = BSANAssembleProvider.getSepaPayeeDetailAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let parameters = SepaPayeeDetailRequestParams(
            language: bsanHeaderData.languageISO,
            dialect: bsanHeaderData.dialectISO,
            token: authCredentials.soapTokenCredential,
            userDataDTO: userDataDTO,
            alias: alias,
            recipientType: recipientType)
        let request = SepaPayeeDetailRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            parameters
        )
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, response.sepaPayeeDetailDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func validateCreateSepaPayee(alias: String, recipientType: FavoriteRecipientType?, beneficiary: String, iban: IBANDTO?, serviceType: String?, contractType: String?, accountIdType: String?, accountId: String?, streetName: String?, townName: String?, location: String?, country: String?, operationDate: Date?) throws -> BSANResponse<SignatureWithTokenDTO?> {
        let bsanAssemble = BSANAssembleProvider.getSepaPayeeDetailAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let parameters = ValidateCreateSepaPayeeRequestParams(
            token: authCredentials.soapTokenCredential,
            languageISO: bsanHeaderData.languageISO,
            dialectISO: bsanHeaderData.dialectISO,
            userDataDTO: userDataDTO,
            beneficiary: beneficiary,
            alias: alias,
            recipientType: recipientType?.rawValue ?? "",
            iban: iban,
            operationDate: operationDate ?? Date()
        )
        let request = ValidateCreateSepaPayeeRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            parameters
        )
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, response.signatureWithToken)
        }
        return BSANErrorResponse(meta)
    }
    
    public func validateCreateSepaPayeeOTP(signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<OTPValidationDTO> {
        let bsanAssemble = BSANAssembleProvider.getSepaPayeeDetailAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let parameters = ValidateCreateSepaPayeeOTPRequestParams(
            token: authCredentials.soapTokenCredential,
            userDataDTO: userDataDTO,
            languageISO: bsanHeaderData.languageISO,
            dialectISO: bsanHeaderData.dialectISO,
            signatureWithTokenDTO: signatureWithTokenDTO
        )
        let request = ValidateCreateSepaPayeeOTPRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            parameters
        )
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        
        if response.otpValidationDTO.otpExcepted || meta.code == BSANSoapResponse.RESULT_OTP_EXCEPTED_USER {
            meta.code = BSANSoapResponse.RESULT_OTP_EXCEPTED_USER
            return BSANOkResponse(meta, response.otpValidationDTO)
            
        } else {
            if meta.isOK() {
                BSANLogger.i(logTag, "Meta OK")
                return BSANOkResponse(meta, response.otpValidationDTO)
            }
            return BSANErrorResponse(meta)
        }
    }
    
    public func confirmCreateSepaPayee(otpValidationDTO: OTPValidationDTO?, otpCode: String?) throws -> BSANResponse<Void> {
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getSepaPayeeDetailAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ConfirmCreateSepaPayeeRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            ConfirmCreateSepaPayeeRequestParams(token: authCredentials.soapTokenCredential,
                                                userDataDTO: userDataDTO,
                                                languageISO: bsanHeaderData.languageISO,
                                                dialectISO: bsanHeaderData.dialectISO,
                                                otpToken: otpValidationDTO?.magicPhrase ?? "",
                                                otpTicket: otpValidationDTO?.ticket ?? "",
                                                otpCode: otpCode ?? ""))
        
        let response = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            bsanDataProvider.removeFavouriteTransfer()
            return BSANOkResponse(meta)
        }
        return BSANErrorResponse(meta)
    }
    
    public func validateRemoveSepaPayee(ofAlias alias: String, payeeCode: String, recipientType: String, accountType: String) throws -> BSANResponse<SignatureWithTokenDTO> {
        let bsanAssemble = BSANAssembleProvider.getSepaPayeeDetailAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let parameters = ValidateRemoveSepaPayeeRequestParams(
            token: authCredentials.soapTokenCredential,
            languageISO: bsanHeaderData.languageISO,
            dialectISO: bsanHeaderData.dialectISO,
            userDataDTO: userDataDTO,
            payeeCode: payeeCode,
            recipientType: recipientType,
            alias: alias,
            accountType: accountType
        )
        let request = ValidateRemoveSepaPayeeRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            parameters
        )
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, response.signatureWithToken)
        }
        return BSANErrorResponse(meta)
    }
    
    public func confirmRemoveSepaPayee(payeeId: String?, signatureWithTokenDTO: SignatureWithTokenDTO?) throws -> BSANResponse<SignatureWithTokenDTO?> {
        let bsanAssemble = BSANAssembleProvider.getSepaPayeeDetailAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        guard let signatureWithTokenDTO = signatureWithTokenDTO else {
            return BSANErrorResponse(nil)
        }
        let parameters = ConfirmRemoveSepaPayeeRequestParams(
            token: authCredentials.soapTokenCredential,
            languageISO: bsanHeaderData.languageISO,
            dialectISO: bsanHeaderData.dialectISO,
            userDataDTO: userDataDTO,
            signatureWithTokenDTO: signatureWithTokenDTO
        )
        let request = ConfirmRemoveSepaPayeeRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            parameters
        )
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.code == BSANSoapResponse.RESULT_OTP_EXCEPTED_USER {
            meta.code = BSANSoapResponse.RESULT_OTP_EXCEPTED_USER
            bsanDataProvider.removeFavouriteTransfer()
            return BSANOkResponse(meta)
        } else {
            if meta.isOK() {
                BSANLogger.i(logTag, "Meta OK")
                bsanDataProvider.removeFavouriteTransfer()
                return BSANOkResponse(meta)
            }
            return BSANErrorResponse(meta)
        }
    }
    
    public func validateUpdateSepaPayee(payeeId: String?, payee: PayeeRepresentable?, newCurrencyDTO: CurrencyDTO?, newBeneficiaryBAOName: String?, newIban: IBANDTO?) throws -> BSANResponse<SignatureWithTokenDTO> {
        guard let payee = payee as? PayeeDTO else { return BSANErrorResponse(nil) }
        let bsanAssemble = BSANAssembleProvider.getSepaPayeeDetailAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let parameters = ValidateUpdateSepaPayeeRequestParams(
            token: authCredentials.soapTokenCredential,
            userDataDTO: userDataDTO,
            languageISO: bsanHeaderData.languageISO,
            dialectISO: bsanHeaderData.dialectISO,
            payeeDTO: payee,
            newCurrencyDTO: newCurrencyDTO,
            newBeneficiaryBAOName: newBeneficiaryBAOName,
            newIban: newIban
        )
        let request = ValidateUpdateSepaPayeeRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            parameters
        )
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, response.signatureWithToken)
        }
        return BSANErrorResponse(meta)
    }
    
    public func validateUpdateSepaPayeeOTP(signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<OTPValidationDTO> {
        let bsanAssemble = BSANAssembleProvider.getSepaPayeeDetailAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let parameters = ValidateUpdateSepaPayeeOTPRequestParams(
            token: authCredentials.soapTokenCredential,
            userDataDTO: userDataDTO,
            languageISO: bsanHeaderData.languageISO,
            dialectISO: bsanHeaderData.dialectISO,
            signatureWithTokenDTO: signatureWithTokenDTO
        )
        let request = ValidateUpdateSepaPayeeOTPRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            parameters
        )
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        
        if response.otpValidationDTO.otpExcepted || meta.code == BSANSoapResponse.RESULT_OTP_EXCEPTED_USER {
            meta.code = BSANSoapResponse.RESULT_OTP_EXCEPTED_USER
            return BSANOkResponse(meta, response.otpValidationDTO)
            
        } else {
            if meta.isOK() {
                BSANLogger.i(logTag, "Meta OK")
                return BSANOkResponse(meta, response.otpValidationDTO)
            }
            return BSANErrorResponse(meta)
        }
    }
    
    public func confirmUpdateSepaPayee(otpValidationDTO: OTPValidationDTO?, otpCode: String?) throws -> BSANResponse<Void> {
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getSepaPayeeDetailAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ConfirmUpdateSepaPayeeRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            ConfirmUpdateSepaPayeeRequestParams(token: authCredentials.soapTokenCredential,
                                               userDataDTO: userDataDTO,
                                               languageISO: bsanHeaderData.languageISO,
                                               dialectISO: bsanHeaderData.dialectISO,
                                               otpToken: otpValidationDTO?.magicPhrase ?? "",
                                               otpTicket: otpValidationDTO?.ticket ?? "",
                                               otpCode: otpCode ?? ""))
        
        let response = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            bsanDataProvider.removeFavouriteTransfer()
            return BSANOkResponse(meta)
        }
        return BSANErrorResponse(meta)
    }
    
    public func getUsualTransfers() throws -> BSANResponse<[PayeeDTO]>{
        return BSANOkResponse(try bsanDataProvider.get(\.transferInfo).usualTransfersList)
    }
    
    public func validateUsualTransfer(originAccountDTO: AccountDTO, usualTransferInput: UsualTransferInput, payee: PayeeRepresentable) throws -> BSANResponse<ValidateAccountTransferDTO> {
        guard let payee = payee as? PayeeDTO else { return BSANErrorResponse(nil) }
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ValidateUsualTransferRequest(
            BSANAssembleProvider.getTransfersAssemble(try bsanDataProvider.isPB()),
            try bsanDataProvider.getEnvironment().urlBase,
            ValidateUsualTransferRequestParams(
                token: authCredentials.soapTokenCredential,
                userDataDTO: userDataDTO,
                version: bsanHeaderData.version,
                terminalId: bsanHeaderData.terminalID,
                language: bsanHeaderData.language,
                beneficiary: payee.beneficiary ?? "",
                ibandto: payee.ibanRepresentable,
                transferAmount: usualTransferInput.amountDTO,
                bankCode: originAccountDTO.oldContract?.bankCode ?? "",
                branchCode: originAccountDTO.oldContract?.branchCode ?? "",
                product: originAccountDTO.oldContract?.product ?? "",
                contractNumber: originAccountDTO.oldContract?.contractNumber ?? "",
                concept: usualTransferInput.concept,
                transferType: usualTransferInput.transferType
            )
        )
        
        let response = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(response.validateAccountTransferDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func confirmUsualTransfer(originAccountDTO: AccountDTO, usualTransferInput: UsualTransferInput, payee: PayeeRepresentable, signatureDTO: SignatureDTO) throws -> BSANResponse<TransferConfirmAccountDTO> {
        return try confirmUsualTransfer(originAccountDTO: originAccountDTO, usualTransferInput: usualTransferInput, payee: payee, signatureDTO: signatureDTO, trusteerInfo: nil)
    }
    
    public func confirmUsualTransfer(originAccountDTO: AccountDTO, usualTransferInput: UsualTransferInput, payee: PayeeRepresentable, signatureDTO: SignatureDTO, trusteerInfo: TrusteerInfoDTO?) throws -> BSANResponse<TransferConfirmAccountDTO> {
        guard let payee = payee as? PayeeDTO else { return BSANErrorResponse(nil) }
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let request = ConfirmUsualTransferRequest(
            BSANAssembleProvider.getTransfersAssemble(try bsanDataProvider.isPB()),
            try bsanDataProvider.getEnvironment().urlBase,
            ConfirmUsualTransferRequestParams(
                token: authCredentials.soapTokenCredential,
                userDataDTO: userDataDTO,
                version: bsanHeaderData.version,
                terminalId: bsanHeaderData.terminalID,
                language: bsanHeaderData.language,
                transferAmount: usualTransferInput.amountDTO,
                originBankCode: originAccountDTO.oldContract?.bankCode ?? "",
                originBranchCode: originAccountDTO.oldContract?.branchCode ?? "",
                originProduct: originAccountDTO.oldContract?.product ?? "",
                originContractNumber: originAccountDTO.oldContract?.contractNumber ?? "",
                beneficiary: payee.beneficiary ?? "",
                beneficiaryMail: usualTransferInput.beneficiaryMail,
                ibandto: payee.ibanRepresentable,
                concept: usualTransferInput.concept,
                signatureDTO: signatureDTO,
                transferType: usualTransferInput.transferType,
                trusteerInfo: trusteerInfo
            )
        )
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(response.transferConfirmAccountDTO)
        }
        return BSANErrorResponse(meta)
    }
    
// MARK: -
// MARK: Generic Scheduled Transfers
    
    public func getScheduledTransfers() throws -> BSANResponse<[String : TransferScheduledListDTO]> {
        return BSANOkResponse(try bsanDataProvider.get(\.transferInfo).transfersScheduledDictionary)
    }
    
    public func loadScheduledTransfers(account: AccountDTO, amountFrom: AmountDTO?, amountTo: AmountDTO?, pagination: PaginationDTO?) throws -> BSANResponse<TransferScheduledListDTO> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        if let contract = account.contract?.contratoPK {
            let transferScheduledListDTO = try bsanDataProvider.get(\.transferInfo).transfersScheduledDictionary[contract]

            if (transferScheduledListDTO != nil) {
                // Stored data
                if (pagination == nil) {
                    //show the first page
                    return BSANOkResponse(transferScheduledListDTO)
                }
    
                if let pagination = transferScheduledListDTO?.paginationDTO {
                    if (pagination.endList) {
                        return BSANOkResponse(transferScheduledListDTO)
                    }
                }
                
            }
            
            let request = GetScheduledTransfersRequest(
                BSANAssembleProvider.getScheduledTransfersAssemble(),
                try bsanDataProvider.getEnvironment().urlBase,
                GetScheduledTransfersRequestParams(token: authCredentials.soapTokenCredential,
                                                   userDataDTO: userDataDTO,
                                                   dialectISO: bsanHeaderData.dialectISO,
                                                   languageISO: bsanHeaderData.languageISO,
                                                   iban: account.iban!,
                                                   amountFrom: amountFrom,
                                                   amountTo: amountTo,
                                                   currency: CurrencyType.eur.name,
                                                   paginationDTO: pagination))
            
            let response: GetScheduledTransfersRespose = try sanSoapServices.executeCall(request)
            let meta = try Meta.createMeta(request, response)
            
            if (meta.isOK()) {
                BSANLogger.i(logTag, "Meta OK")
                bsanDataProvider.storeScheduledTransfers(transferScheduledListDTO: response.transferScheduledListDTO, contract: contract)
                if let result = try bsanDataProvider.get(\.transferInfo).transfersScheduledDictionary[contract] {
                    return BSANOkResponse(result)
                }
            }
            return BSANErrorResponse(meta)
        } else {
            return BSANErrorResponse(Meta.createKO())
        }
    }
    
    public func getScheduledTransferDetail(account: AccountDTO, transferScheduledDTO: TransferScheduledDTO) throws -> BSANResponse<TransferScheduledDetailDTO> {
        
        let contractNumber = transferScheduledDTO.numberOrderHeader ?? ""
        let transferNumber = transferScheduledDTO.concept ?? ""
        let transferId = contractNumber + transferNumber
        
        if let transferScheduledDetail = try bsanDataProvider.get(\.transferInfo).transfersScheduledDetailDictionary[transferId] {
            return BSANOkResponse(transferScheduledDetail)
        }
        
        let response =  try loadScheduledTransferDetail(account: account, transferScheduledDTO: transferScheduledDTO)
        if let transferScheduledDetail = try bsanDataProvider.get(\.transferInfo).transfersScheduledDetailDictionary[transferId] {
            return BSANOkResponse(transferScheduledDetail)
        }
        
        return BSANErrorResponse(Meta.createKO(try response.getErrorMessage() ?? ""))
    }
    
    public func loadScheduledTransferDetail(account: AccountDTO, transferScheduledDTO: TransferScheduledDTO) throws -> BSANResponse<Void> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
    
        let request = GetScheduledTransferDetailRequest(
            BSANAssembleProvider.getScheduledTransfersAssemble(),
            try bsanDataProvider.getEnvironment().urlBase,
            GetScheduledTransferDetailRequestParams(token: authCredentials.soapTokenCredential,
                                                    userDataDTO: userDataDTO,
                                                    dialectISO: bsanHeaderData.dialectISO,
                                                    languageISO: bsanHeaderData.languageISO,
                                                    numberOrderHeader: transferScheduledDTO.numberOrderHeader ?? "",
                                                    typeTransfer: transferScheduledDTO.typeTransfer ?? "",
                                                    typeSelection: transferScheduledDTO.typeSelection ?? "",
                                                    currency: CurrencyType.eur.name,
                                                    iban: account.iban!
        ))
        
        let response = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            
            let contractNumber = transferScheduledDTO.numberOrderHeader ?? ""
            let transferNumber = transferScheduledDTO.concept ?? ""
            let transferId = contractNumber + transferNumber
            
            if let transferScheduledDetail = response.transferScheduledDetailDTO {
                bsanDataProvider.storeScheduledTransferDetail(transferScheduledDetailDTO: transferScheduledDetail, idTransfer: transferId)
                return BSANOkResponse(meta)
            }
            return BSANErrorResponse(meta)
            
        }
        return BSANErrorResponse(meta)
        
    }
    
    public func removeScheduledTransfer(accountDTO: AccountDTO, orderIbanDTO: IBANDTO, transferScheduledDTO: TransferScheduledDTO,
                                        signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<Void> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        
        let request = RemoveScheduledTransferRequest(
            BSANAssembleProvider.getScheduledTransfersAssemble(),
            try bsanDataProvider.getEnvironment().urlBase,
            RemoveScheduledTransferRequestParams(token: authCredentials.soapTokenCredential,
                                                 userDataDTO: userDataDTO,
                                                 dialectISO: bsanHeaderData.dialectISO,
                                                 languageISO: bsanHeaderData.languageISO,
                                                 transferAmount: transferScheduledDTO.transferAmount ?? AmountDTO(),
                                                 signature: signatureWithTokenDTO ,
                                                 numberOrderHeader: transferScheduledDTO.numberOrderHeader ?? "",
                                                 typeTransfer: transferScheduledDTO.typeTransfer ?? "",
                                                 dateEndValidity: transferScheduledDTO.dateEndValidity ?? Date(),
                                                 iban: orderIbanDTO
        ))
        
        let response = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            if let contract = accountDTO.contract?.contratoPK {
                bsanDataProvider.deleteScheduledTransfer(transferScheduledDTO, contract: contract)
            }
            return BSANOkResponse(meta)
        }
        return BSANErrorResponse(meta)
    }
    
    public func getHistoricalTransferCompleted() throws -> Bool {
        return try self.bsanDataProvider.getHistoricalTransferCompleted()
    }
    
    public func storeGetHistoricalTransferCompleted(_ completed: Bool) throws {
        self.bsanDataProvider.storeGetHistoricalTransferCompleted(completed)
    }
    
// MARK: -
// MARK: Scheduled Transfers
    
    public func validateScheduledTransfer(originAcount: AccountDTO, scheduledTransferInput: ScheduledTransferInput) throws -> BSANResponse<ValidateScheduledTransferDTO> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ValidateScheduledTransferRequest(
            BSANAssembleProvider.getScheduledTransfersAssemble(),
            try bsanDataProvider.getEnvironment().urlBase,
            ValidateScheduledTransferRequestParams(token: authCredentials.soapTokenCredential,
                                                   userDataDTO: userDataDTO,
                                                   dialectISO: bsanHeaderData.dialectISO,
                                                   languageISO: bsanHeaderData.languageISO,
                                                   beneficiary: scheduledTransferInput.beneficiary ?? "",
                                                   dateStartValidity: scheduledTransferInput.dateStartValidity,
                                                   dateEndValidity: scheduledTransferInput.dateEndValidity,
                                                   transferAmount: scheduledTransferInput.transferAmount,
                                                   company: userDataDTO.company ?? "",
                                                   scheduledDayType: scheduledTransferInput.scheduledDayType ?? ScheduledDayDTO.none,
                                                   periodicalType: scheduledTransferInput.periodicalType ?? PeriodicalTypeTransferDTO.none,
                                                   indicatorResidence: scheduledTransferInput.indicatorResidence,
                                                   iban: scheduledTransferInput.ibanDestination,
                                                   concept: scheduledTransferInput.concept ?? "",
                                                   dateNextExecution: scheduledTransferInput.dateNextExecution,
                                                   currency: originAcount.currentBalance?.currency?.currencyName ?? "",
                                                   ibanOrigin: originAcount.iban!))
        
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, response.validateScheduledTransferDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func validateScheduledTransferOTP(signatureDTO: SignatureDTO, dataToken: String) throws -> BSANResponse<OTPValidationDTO> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ValidateScheduledTransferOTPRequest(
            BSANAssembleProvider.getScheduledTransfersAssemble(),
            try bsanDataProvider.getEnvironment().urlBase,
            ValidateScheduledTransferOTPRequestParams(token: authCredentials.soapTokenCredential,
                                                      userDataDTO: userDataDTO,
                                                      dialectISO: bsanHeaderData.dialectISO,
                                                      languageISO: bsanHeaderData.languageISO,
                                                      signatureDTO: signatureDTO,
                                                      dataToken: dataToken))
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        
        if response.otpValidationDTO.otpExcepted || meta.code == BSANSoapResponse.RESULT_OTP_EXCEPTED_USER {
            meta.code = BSANSoapResponse.RESULT_OTP_EXCEPTED_USER
            return BSANOkResponse(meta, response.otpValidationDTO)
            
        } else {
            if meta.isOK() {
                BSANLogger.i(logTag, "Meta OK")
                return BSANOkResponse(meta, response.otpValidationDTO)
            }
            return BSANErrorResponse(meta)
        }
    }
    
    public func confirmScheduledTransfer(originAccountDTO: AccountDTO, scheduledTransferInput: ScheduledTransferInput, otpValidationDTO: OTPValidationDTO, otpCode: String) throws -> BSANResponse<ValidateScheduledTransferDTO> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ConfirmScheduledTransferRequest(
            BSANAssembleProvider.getScheduledTransfersAssemble(),
            try bsanDataProvider.getEnvironment().urlBase,
            ConfirmScheduledTransferRequestParams(token: authCredentials.soapTokenCredential,
                                                  userDataDTO: userDataDTO,
                                                  dialectISO: bsanHeaderData.dialectISO,
                                                  languageISO: bsanHeaderData.languageISO,
                                                  beneficiary: scheduledTransferInput.beneficiary ?? "",
                                                  dateStartValidity: scheduledTransferInput.dateStartValidity,
                                                  dateEndValidity: scheduledTransferInput.dateEndValidity,
                                                  company: scheduledTransferInput.company ?? "",
                                                  scheduledDayType: scheduledTransferInput.scheduledDayType ?? ScheduledDayDTO.none,
                                                  periodicalType: scheduledTransferInput.periodicalType ?? PeriodicalTypeTransferDTO.none,
                                                  indicatorResidence: scheduledTransferInput.indicatorResidence,
                                                  concept: scheduledTransferInput.concept ?? "",
                                                  dateNextExecution: scheduledTransferInput.dateNextExecution,
                                                  currency: originAccountDTO.currentBalance?.currency?.currencyName ?? "",
                                                  nameBankIbanBeneficiary: scheduledTransferInput.nameBankIbanBeneficiary ?? "",
                                                  actuanteCompany: scheduledTransferInput.actuanteCompany ?? "",
                                                  actuanteCode: scheduledTransferInput.actuanteCode ?? "",
                                                  actuanteNumber: scheduledTransferInput.actuanteNumber ?? "",
                                                  saveAsUsual: scheduledTransferInput.saveAsUsual ?? false,
                                                  saveAsUsualAlias: scheduledTransferInput.saveAsUsualAlias ?? "",
                                                  dataToken: otpValidationDTO.magicPhrase ?? "",
                                                  ticketOTP: otpValidationDTO.ticket ?? "",
                                                  codeOTP: otpCode))
        
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta)
        }
        return BSANErrorResponse(meta)
    }

    public func modifyPeriodicTransferDetail(originAccountDTO: AccountDTO, transferScheduledDTO: TransferScheduledDTO, transferScheduledDetailDTO: TransferScheduledDetailDTO) throws -> BSANResponse<ModifyPeriodicTransferDTO> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ModifyPeriodicTransferRequest(
            BSANAssembleProvider.getScheduledTransfersAssemble(),
            try bsanDataProvider.getEnvironment().urlBase,
            ModifyPeriodicTransferRequestParams(token: authCredentials.soapTokenCredential,
                                                userDataDTO: userDataDTO,
                                                dialectISO: bsanHeaderData.dialectISO,
                                                languageISO: bsanHeaderData.languageISO,
                                                orderHeaderNumber: transferScheduledDTO.numberOrderHeader ?? "",
                                                orderingCurrency: originAccountDTO.currentBalance?.currency?.currencyName ?? "",
                                                iban: transferScheduledDetailDTO.iban!))
        
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, response.modifyPeriodicTransferDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func validateModifyPeriodicTransfer(originAccountDTO: AccountDTO, modifyScheduledTransferInput: ModifyScheduledTransferInput, modifyPeriodicTransferDTO: ModifyPeriodicTransferDTO, transferScheduledDetailDTO: TransferScheduledDetailDTO) throws -> BSANResponse<OTPValidationDTO> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ValidateModifyPeriodicTransferRequest(
            BSANAssembleProvider.getScheduledTransfersAssemble(),
            try bsanDataProvider.getEnvironment().urlBase,
            ValidateModifyPeriodicTransferRequestParams(token: authCredentials.soapTokenCredential,
                                                        userDataDTO: userDataDTO,
                                                        dialectISO: bsanHeaderData.dialectISO,
                                                        languageISO: bsanHeaderData.languageISO,
                                                        signatureDTO: modifyPeriodicTransferDTO.signatureDTO ?? SignatureDTO(),
                                                        dataToken: modifyPeriodicTransferDTO.dataToken ?? "",
                                                        orderingCurrency: originAccountDTO.currentBalance?.currency?.currencyName ?? "",
                                                        ibanOrderingCurrency: originAccountDTO.currentBalance?.currency?.currencyName ?? "",
                                                        originIban: transferScheduledDetailDTO.iban!,
                                                        beneficiaryIban: modifyScheduledTransferInput.beneficiaryIBAN,
                                                        actingBeneficiary: modifyPeriodicTransferDTO.actingBeneficiary ?? InstructionStatusDTO(),
                                                        nextExecutionDate: modifyScheduledTransferInput.nextExecutionDate,
                                                        amount: modifyScheduledTransferInput.amount,
                                                        concept: modifyScheduledTransferInput.concept ?? "",
                                                        indicatorResidence: modifyPeriodicTransferDTO.residenceIndicator ?? false,
                                                        operationType: modifyPeriodicTransferDTO.naturalezaPago ?? InstructionStatusDTO(),
                                                        sepaType: modifyPeriodicTransferDTO.sepaType ?? "",
                                                        actingNumber: modifyPeriodicTransferDTO.actingNumber ?? "",
                                                        indOperationType: modifyPeriodicTransferDTO.indOperationType ?? "",
                                                        countryCode: transferScheduledDetailDTO.iban?.countryCode ?? "",
                                                        startDateValidity: modifyScheduledTransferInput.startDateValidity,
                                                        endDateValidity: modifyScheduledTransferInput.endDateValidity,
                                                        dateIndicator: modifyPeriodicTransferDTO.dateIndicator ?? InstructionStatusDTO(),
                                                        periodicityIndicator: modifyPeriodicTransferDTO.periodicityIndicator ?? InstructionStatusDTO(),
                                                        scheduledDayType: modifyScheduledTransferInput.scheduledDayType ?? ScheduledDayDTO.next_day,
                                                        periodicalType: modifyScheduledTransferInput.periodicalType ?? PeriodicalTypeTransferDTO.monthly))
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, response.otpValidationDTO)
        }
        return BSANErrorResponse(meta)
    }
    

    public func confirmModifyPeriodicTransfer(originAccountDTO: AccountDTO, modifyScheduledTransferInput: ModifyScheduledTransferInput, modifyPeriodicTransferDTO: ModifyPeriodicTransferDTO, transferScheduledDTO: TransferScheduledDTO, transferScheduledDetailDTO: TransferScheduledDetailDTO, otpValidationDTO: OTPValidationDTO, otpCode: String, scheduledDayType: ScheduledDayDTO) throws -> BSANResponse<Void> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ConfirmModifyPeriodicTransferRequest(
            BSANAssembleProvider.getScheduledTransfersAssemble(),
            try bsanDataProvider.getEnvironment().urlBase,
            ConfirmModifyPeriodicTransferRequestParams(token: authCredentials.soapTokenCredential,
                                                       userDataDTO: userDataDTO,
                                                       dialectISO: bsanHeaderData.dialectISO,
                                                       languageISO: bsanHeaderData.languageISO,
                                                       otpCode: otpCode,
                                                       dataToken: otpValidationDTO.magicPhrase ?? "",
                                                       ticket: otpValidationDTO.ticket ?? "",
                                                       orderingCurrency: originAccountDTO.currentBalance?.currency?.currencyName ?? "",
                                                       originIban: transferScheduledDetailDTO.iban!,
                                                       beneficiaryIban: modifyScheduledTransferInput.beneficiaryIBAN,
                                                       actingBeneficiary: modifyPeriodicTransferDTO.actingBeneficiary ?? InstructionStatusDTO(),
                                                       indOperationType: modifyPeriodicTransferDTO.indOperationType ?? "",
                                                       nextExecutionDate: modifyScheduledTransferInput.nextExecutionDate,
                                                       amount: modifyScheduledTransferInput.amount,
                                                       concept: modifyScheduledTransferInput.concept ?? "",
                                                       indicatorResidence: modifyPeriodicTransferDTO.residenceIndicator ?? false,
                                                       operationType: modifyPeriodicTransferDTO.naturalezaPago ?? InstructionStatusDTO(),
                                                       headerOrderNumber: transferScheduledDTO.numberOrderHeader ?? "",
                                                       beneficiaryName: modifyScheduledTransferInput.beneficiary,
                                                       operationCode: modifyScheduledTransferInput.transferOperationType?.type ?? TransferOperationType.NATIONAL_SEPA.type,
                                                       country: modifyScheduledTransferInput.beneficiaryIBAN.countryCode,
                                                       startDateValidity: modifyScheduledTransferInput.startDateValidity,
                                                       endDateValidity: modifyScheduledTransferInput.endDateValidity,
                                                       periodicityIndicator: modifyPeriodicTransferDTO.periodicityIndicator ?? InstructionStatusDTO(),
                                                       periodicalType: modifyScheduledTransferInput.periodicalType ?? PeriodicalTypeTransferDTO.none,
                                                       scheduledDayType: scheduledDayType))
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta)
        }
        return BSANErrorResponse(meta)
    }
    
// MARK: Deferred Transfer
    
    public func validateDeferredTransfer(originAcount: AccountDTO, scheduledTransferInput: ScheduledTransferInput) throws -> BSANResponse<ValidateScheduledTransferDTO> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ValidateDeferredTransferRequest(
            BSANAssembleProvider.getScheduledTransfersAssemble(),
            try bsanDataProvider.getEnvironment().urlBase,
            ValidateDeferredTransferRequestParams(token: authCredentials.soapTokenCredential,
                                                   userDataDTO: userDataDTO,
                                                   dialectISO: bsanHeaderData.dialectISO,
                                                   languageISO: bsanHeaderData.languageISO,
                                                   transferAmount: scheduledTransferInput.transferAmount,
                                                   beneficiary: scheduledTransferInput.beneficiary ?? "",
                                                   iban: scheduledTransferInput.ibanDestination,
                                                   indicatorResidence: scheduledTransferInput.indicatorResidence,
                                                   concept: scheduledTransferInput.concept ?? "",
                                                   dateNextExecution: scheduledTransferInput.dateNextExecution,
                                                   currency: originAcount.currentBalance?.currency?.currencyName ?? "",
                                                   ibanOrigin: originAcount.iban!))
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, response.validateDeferredTransferDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func validateDeferredTransferOTP(signatureDTO: SignatureDTO, dataToken: String) throws -> BSANResponse<OTPValidationDTO> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ValidateDeferredTransferOTPRequest(
            BSANAssembleProvider.getScheduledTransfersAssemble(),
            try bsanDataProvider.getEnvironment().urlBase,
            ValidateDeferredTransferOTPRequestParams(token: authCredentials.soapTokenCredential,
                                                      userDataDTO: userDataDTO,
                                                      dialectISO: bsanHeaderData.dialectISO,
                                                      languageISO: bsanHeaderData.languageISO,
                                                      signatureDTO: signatureDTO,
                                                      dataToken: dataToken))
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        
        if response.otpValidationDTO.otpExcepted || meta.code == BSANSoapResponse.RESULT_OTP_EXCEPTED_USER {
            meta.code = BSANSoapResponse.RESULT_OTP_EXCEPTED_USER
            return BSANOkResponse(meta, response.otpValidationDTO)
            
        } else {
            if meta.isOK() {
                BSANLogger.i(logTag, "Meta OK")
                return BSANOkResponse(meta, response.otpValidationDTO)
            }
            return BSANErrorResponse(meta)
        }
    }
    
    public func confirmDeferredTransfer(
        originAccountDTO: AccountDTO,
        scheduledTransferInput: ScheduledTransferInput,
        otpValidationDTO: OTPValidationDTO,
        otpCode: String,
        trusteerInfo: TrusteerInfoDTO?
    ) throws -> BSANResponse<Void> {
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let request = ConfirmDeferredTransferRequest(
            BSANAssembleProvider.getScheduledTransfersAssemble(),
            try bsanDataProvider.getEnvironment().urlBase,
            ConfirmDeferredTransferRequestParams(
                token: authCredentials.soapTokenCredential,
                userDataDTO: userDataDTO,
                dialectISO: bsanHeaderData.dialectISO,
                languageISO: bsanHeaderData.languageISO,
                beneficiary: scheduledTransferInput.beneficiary ?? "",
                trusteerInfo: trusteerInfo,
                indicatorResidence: scheduledTransferInput.indicatorResidence,
                concept: scheduledTransferInput.concept ?? "",
                dateNextExecution: scheduledTransferInput.dateNextExecution,
                currency: originAccountDTO.currentBalance?.currency?.currencyName ?? "",
                actuanteCompany: scheduledTransferInput.actuanteCompany ?? "",
                actuanteCode: scheduledTransferInput.actuanteCode ?? "",
                actuanteNumber: scheduledTransferInput.actuanteNumber ?? "",
                saveAsUsual: scheduledTransferInput.saveAsUsual ?? false,
                saveAsUsualAlias: scheduledTransferInput.saveAsUsualAlias ?? "",
                dataToken: otpValidationDTO.magicPhrase ?? "",
                ticketOTP: otpValidationDTO.ticket ?? "",
                codeOTP: otpCode
            )
        )
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        guard meta.isOK() else { return BSANErrorResponse(meta) }
        BSANLogger.i(logTag, "Meta OK")
        return BSANOkResponse(meta)
    }
    
    public func modifyDeferredTransferDetail(originAccountDTO: AccountDTO, transferScheduledDTO: TransferScheduledDTO, transferScheduledDetailDTO: TransferScheduledDetailDTO) throws -> BSANResponse<ModifyDeferredTransferDTO> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ModifyDeferredTransferRequest(
            BSANAssembleProvider.getScheduledTransfersAssemble(),
            try bsanDataProvider.getEnvironment().urlBase,
            ModifyDeferredTransferRequestParams(token: authCredentials.soapTokenCredential,
                                                 userDataDTO: userDataDTO,
                                                 dialectISO: bsanHeaderData.dialectISO,
                                                 languageISO: bsanHeaderData.languageISO,
                                                 orderHeaderNumber: transferScheduledDTO.numberOrderHeader ?? "",
                                                 orderingCurrency: originAccountDTO.currentBalance?.currency?.currencyName ?? "",
                                                 iban: transferScheduledDetailDTO.iban!))
        
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, response.modifyDeferredTransferDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func validateModifyDeferredTransfer(originAccountDTO: AccountDTO, modifyScheduledTransferInput: ModifyScheduledTransferInput, modifyDeferredTransferDTO: ModifyDeferredTransferDTO, transferScheduledDetailDTO: TransferScheduledDetailDTO) throws -> BSANResponse<OTPValidationDTO> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ValidateModifyDeferredTransferRequest(
            BSANAssembleProvider.getScheduledTransfersAssemble(),
            try bsanDataProvider.getEnvironment().urlBase,
            ValidateModifyDeferredTransferRequestParams(token: authCredentials.soapTokenCredential,
                                                userDataDTO: userDataDTO,
                                                dialectISO: bsanHeaderData.dialectISO,
                                                languageISO: bsanHeaderData.languageISO,
                                                signatureDTO: modifyDeferredTransferDTO.signatureDTO ?? SignatureDTO(),
                                                dataToken: modifyDeferredTransferDTO.dataToken ?? "",
                                                orderingCurrency: originAccountDTO.currentBalance?.currency?.currencyName ?? "",
                                                originIban: transferScheduledDetailDTO.iban!,
                                                beneficiaryIban: modifyScheduledTransferInput.beneficiaryIBAN,
                                                actingBeneficiary: modifyDeferredTransferDTO.actingBeneficiary ?? InstructionStatusDTO(),
                                                nextExecutionDate: modifyScheduledTransferInput.nextExecutionDate,
                                                amount: modifyScheduledTransferInput.amount,
                                                concept: modifyScheduledTransferInput.concept ?? "",
                                                indicatorResidence: modifyDeferredTransferDTO.residenceIndicator ?? false,
                                                operationType: modifyDeferredTransferDTO.operationType ?? InstructionStatusDTO(),
                                                sepaType: modifyDeferredTransferDTO.sepaType ?? "",
                                                actingNumber: modifyDeferredTransferDTO.actingNumber ?? "",
                                                indOperationType: modifyDeferredTransferDTO.indOperationType ?? ""))
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, response.otpValidationDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func confirmModifyDeferredTransfer(
        originAccountDTO: AccountDTO,
        modifyScheduledTransferInput: ModifyScheduledTransferInput,
        modifyDeferredTransferDTO: ModifyDeferredTransferDTO,
        transferScheduledDTO: TransferScheduledDTO,
        transferScheduledDetailDTO: TransferScheduledDetailDTO,
        otpValidationDTO: OTPValidationDTO,
        otpCode: String,
        trusteerInfo: TrusteerInfoDTO?
    ) throws -> BSANResponse<Void> {
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let request = ConfirmModifyDeferredTransferRequest(
            BSANAssembleProvider.getScheduledTransfersAssemble(),
            try bsanDataProvider.getEnvironment().urlBase,
            ConfirmModifyDeferredTransferRequestParams(
                token: authCredentials.soapTokenCredential,
                userDataDTO: userDataDTO,
                dialectISO: bsanHeaderData.dialectISO,
                languageISO: bsanHeaderData.languageISO,
                trusteerInfo: trusteerInfo,
                otpCode: otpCode,
                dataToken: otpValidationDTO.magicPhrase ?? "",
                ticket: otpValidationDTO.ticket ?? "",
                orderingCurrency: originAccountDTO.currentBalance?.currency?.currencyName ?? "",
                originIban: transferScheduledDetailDTO.iban!,
                beneficiaryIban: modifyScheduledTransferInput.beneficiaryIBAN,
                actingBeneficiary: modifyDeferredTransferDTO.actingBeneficiary ?? InstructionStatusDTO(),
                nextExecutionDate: modifyScheduledTransferInput.nextExecutionDate,
                amount: modifyScheduledTransferInput.amount,
                concept: modifyScheduledTransferInput.concept ?? "",
                indicatorResidence: modifyDeferredTransferDTO.residenceIndicator ?? false,
                operationType: modifyDeferredTransferDTO.operationType ?? InstructionStatusDTO(),
                headerOrderNumber: transferScheduledDTO.numberOrderHeader ?? "",
                beneficiaryName: modifyScheduledTransferInput.beneficiary,
                operationCode: modifyScheduledTransferInput.transferOperationType?.type ?? TransferOperationType.NATIONAL_SEPA.type,
                country: modifyScheduledTransferInput.beneficiaryIBAN.countryCode,
                indOperationType: modifyDeferredTransferDTO.indOperationType ?? ""
            )
        )
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        guard meta.isOK() else { return BSANErrorResponse(meta) }
        BSANLogger.i(logTag, "Meta OK")
        return BSANOkResponse(meta)
    }
    
// MARK: Emitted Transfers
    
    public func getEmittedTransfers() throws -> BSANResponse<[String : TransferEmittedListDTO]>{
        return BSANOkResponse(try bsanDataProvider.get(\.transferInfo).getTransfersEmitted())
    }
    
    public func loadEmittedTransfers(account: AccountRepresentable, amountFrom: AmountRepresentable?, amountTo: AmountRepresentable?, dateFilter: DateFilter, pagination: PaginationRepresentable?) throws -> BSANResponse<TransferEmittedListDTO> {
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let newGlobalPosition: GlobalPositionDTO = try bsanDataProvider.get(\.newGlobalPositionDTO)
        let requestAccount: AccountRepresentable = newGlobalPosition.accounts?.first(where: {
            guard let lhs = $0.ibanRepresentable,
                  let rhs = account.ibanRepresentable
            else { return false }
            return lhs.equalsTo(other: rhs)
        }) ?? account
        if let contract: ContractRepresentable = requestAccount.contractRepresentable {
            let contractKey: String = contract.fullContract
            let transferEmittedListDTO = try? bsanDataProvider.get(\.transferInfo).getTransferEmittedCacheFor(contractKey)
            let storedEmptyTransferEmittedListDTO = try? bsanDataProvider.get(\.transferInfo).getEmptyTransferEmittedCacheFor(contractKey)
            if (transferEmittedListDTO != nil) {
                // Stored data
                if (pagination == nil) {
                    //show the first page
                    return BSANOkResponse(transferEmittedListDTO)
                }
                if let pagination = transferEmittedListDTO?.paginationDTO,
                    pagination.endList {
                    return BSANOkResponse(transferEmittedListDTO)
                }
            } else if (storedEmptyTransferEmittedListDTO != nil) {
                return BSANErrorResponse(Meta.createKO())
            }
            let params = GetEmittedTransferRequestParams(token: authCredentials.soapTokenCredential,
                                                         userDataDTO: userDataDTO,
                                                         dialectISO: bsanHeaderData.dialectISO,
                                                         languageISO: bsanHeaderData.languageISO,
                                                         bankCode: contract.bankCode ?? "",
                                                         branchCode: contract.branchCode ?? "",
                                                         product: contract.product ?? "",
                                                         contractNumber: contract.contractNumber ?? "",
                                                         paginationDTO: pagination as? PaginationDTO,
                                                         amountFrom: amountFrom as? AmountDTO,
                                                         amountTo: amountTo as? AmountDTO,
                                                         dateFilter: dateFilter)
            let request = GetEmittedTransfersRequest(
                BSANAssembleProvider.getEmittedTransfersAssemble(),
                try bsanDataProvider.getEnvironment().urlBase,
                params
            )
            let response: GetEmittedTransfersResponse = try sanSoapServices.executeCall(request)
            let meta = try Meta.createMeta(request, response)
            if (meta.isOK()) {
                BSANLogger.i(logTag, "Meta OK")
                bsanDataProvider.storeEmittedTransfers(transferEmittedListDTO: response.transferEmittedListDTO, contract: contractKey)
                if let result = try bsanDataProvider.get(\.transferInfo).getTransferEmittedCacheFor(contractKey) {
                    return BSANOkResponse(result)
                }
            }
            bsanDataProvider.storeEmptyEmittedTransfers(contract: contractKey)
            return BSANErrorResponse(meta)
        } else {
            return BSANErrorResponse(Meta.createKO())
        }
    }
    
    public func getEmittedTransferDetail(transferEmittedDTO: TransferEmittedDTO) throws -> BSANResponse<TransferEmittedDetailDTO> {
        
        let contractNumber = transferEmittedDTO.serviceOrder?.contractNumber ?? ""
        let transferNumber = transferEmittedDTO.transferNumber ?? ""
        let transferId = contractNumber + transferNumber
        
        if let transferEmittedDetail = try bsanDataProvider.get(\.transferInfo).transfersEmittedDetailDictionary[transferId] {
            return BSANOkResponse(transferEmittedDetail)
        }
        
        let response =  try loadEmittedTransferDetail(transferEmittedDTO: transferEmittedDTO)
        if let transferEmittedDetail = try bsanDataProvider.get(\.transferInfo).transfersEmittedDetailDictionary[transferId] {
            return BSANOkResponse(transferEmittedDetail)
        }
        
        return BSANErrorResponse(Meta.createKO(try response.getErrorMessage() ?? ""))
    }
    
    public func loadEmittedTransferDetail(transferEmittedDTO: TransferEmittedDTO) throws -> BSANResponse<Void> {

        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = GetEmittedTransferDetailRequest(
            BSANAssembleProvider.getEmittedTransfersAssemble(),
            try bsanDataProvider.getEnvironment().urlBase,
            GetEmittedTransferDetailRequestParams(token: authCredentials.soapTokenCredential,
                                                  userDataDTO: userDataDTO,
                                                  dialectISO: bsanHeaderData.dialectISO,
                                                  languageISO: bsanHeaderData.languageISO,
                                                  bankCode: transferEmittedDTO.serviceOrder?.bankCode ?? "",
                                                  branchCode: transferEmittedDTO.serviceOrder?.branchCode ?? "",
                                                  product: transferEmittedDTO.serviceOrder?.product ?? "",
                                                  contractNumber: transferEmittedDTO.serviceOrder?.contractNumber ?? "",
                                                  transferNumber: transferEmittedDTO.transferNumber ?? "",
                                                  appCode: transferEmittedDTO.aplicationCode ?? ""
        ))
        let response = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            
            let contractNumber = transferEmittedDTO.serviceOrder?.contractNumber ?? ""
            let transferNumber = transferEmittedDTO.transferNumber ?? ""
            let transferId = contractNumber + transferNumber
            
            if let transferEmittedDetail = response.transferEmittedDetailDTO {
                bsanDataProvider.storeEmittedTransferDetail(transferEmittedDetailDTO: transferEmittedDetail, idTransfer: transferId)
                return BSANOkResponse(meta)
            }
            return BSANErrorResponse(meta)
            
        }
        return BSANErrorResponse(meta)

    }
    
    // MARK: - Received transfers
    
    public func getAccountTransactions(forAccount account: AccountRepresentable, pagination: PaginationRepresentable?, filter: AccountTransferFilterInput) throws -> BSANResponse<AccountTransactionsListDTO> {
        guard let account = account as? AccountDTO else { return BSANErrorResponse(nil)}
        let isPb = try bsanDataProvider.isPB()
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getAccountsAssemble(isPb)
        
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let previouslyCompleted = try bsanDataProvider.getHistoricalTransferCompleted()
        
        guard var contractString = account.contract?.formattedValue else {
            throw BSANIllegalStateException("Malformed account contract")
        }
        
        contractString += filter.string
        let accountTransactionList = try bsanDataProvider.get(\.accountInfo).accountTransactionsDictionary[contractString]
        
        if let accountTransactionList = accountTransactionList {
            if pagination != nil {
                if accountTransactionList.pagination.endList || previouslyCompleted {
                    return BSANOkResponse(accountTransactionList)
                }
            } else {
                return BSANOkResponse(accountTransactionList)
            }
        }
        
        let request = AccountTransactionsFilterRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            AccountTransactionsRequestParams(token: authCredentials.soapTokenCredential,
                                             userDataDTO: userDataDTO,
                                             bankCode: account.oldContract?.bankCode ?? "",
                                             branchCode: account.oldContract?.branchCode ?? "",
                                             product: account.oldContract?.product ?? "",
                                             contractNumber: account.oldContract?.contractNumber ?? "",
                                             terminalId: bsanHeaderData.terminalID,
                                             version: bsanHeaderData.version,
                                             language: bsanHeaderData.language,
                                             pagination: pagination as? PaginationDTO,
                                             dateFilter: filter.dateFilter,
                                             filter: filter))
        
        let response: AccountTransactionsResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");
            bsanDataProvider.store(accountTransactionsList: response.accountTransactions, forAccountId: contractString)
            // Return last page only (In Android they return all everytime)
            return BSANOkResponse(meta, response.accountTransactions);
        }
        return BSANErrorResponse(meta);
    }
    
    // MARK: -
    // MARK: No SEPA Transfer
    
    public func transferType(originAccountDTO: AccountDTO, selectedCountry: String, selectedCurrerncy: String) throws -> BSANResponse<TransfersType> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = TransferTypeRequest(
            BSANAssembleProvider.getNoSEPAssemble(),
            try bsanDataProvider.getEnvironment().urlBase,
            TransferTypeRequestParams(token:  authCredentials.soapTokenCredential,
                                    userDataDTO: userDataDTO,
                                    languageISO: bsanHeaderData.languageISO,
                                    dialectISO: bsanHeaderData.dialectISO,
                                    accountDTO: originAccountDTO,
                                    selectedCountry: selectedCountry,
                                    selectedCurrency: selectedCurrerncy))
        
        let response = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(response.transferType)
        }
        return BSANErrorResponse(meta)
    }
    
    public func validateSwift(noSepaTransferInput: NoSEPATransferInput) throws -> BSANResponse<ValidationSwiftDTO> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ValidationSwiftRequest(
            BSANAssembleProvider.getNoSEPAssemble(),
            try bsanDataProvider.getEnvironment().urlBase,
            ValidationSwiftRequestParams(token:  authCredentials.soapTokenCredential,
                                      userDataDTO: userDataDTO,
                                      languageISO: bsanHeaderData.languageISO,
                                      dialectISO: bsanHeaderData.dialectISO,
                                      noSepaTransferInput: noSepaTransferInput))
        
        let response = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(response.validationSwiftDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func validationIntNoSEPA(noSepaTransferInput: NoSEPATransferInput, validationSwiftDTO: ValidationSwiftDTO?) throws -> BSANResponse<ValidationIntNoSepaDTO> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ValidationNoSEPARequest(
            BSANAssembleProvider.getNoSEPAssemble(),
            try bsanDataProvider.getEnvironment().urlBase,
            ValidationIntNoSEPARequestParams(token:  authCredentials.soapTokenCredential,
                                         userDataDTO: userDataDTO,
                                         languageISO: bsanHeaderData.languageISO,
                                         dialectISO: bsanHeaderData.dialectISO,
                                         noSepaTransferInput: noSepaTransferInput,
                                         validationSwiftDTO: validationSwiftDTO))
        
        let response = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(response.validationIntNoSEPA)
        }
        return BSANErrorResponse(meta)
    }
    
    public func validationOTPIntNoSEPA(validationIntNoSepaDTO: ValidationIntNoSepaDTO, noSepaTransferInput: NoSEPATransferInput) throws -> BSANResponse<OTPValidationDTO> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ValidationOTPNoSEPARequest(
            BSANAssembleProvider.getNoSEPAssemble(),
            try bsanDataProvider.getEnvironment().urlBase,
            ValidationOTPNoSEPARequestParams(token:  authCredentials.soapTokenCredential,
                                             userDataDTO: userDataDTO,
                                             languageISO: bsanHeaderData.languageISO,
                                             dialectISO: bsanHeaderData.dialectISO,
                                             noSepaTransferInput: noSepaTransferInput,
                                             validationIntNoSepaDTO: validationIntNoSepaDTO))
        
        let response = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(response.otpValidationDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func confirmationIntNoSEPA(
        validationIntNoSepaDTO: ValidationIntNoSepaDTO,
        validationSwiftDTO: ValidationSwiftDTO?,
        noSepaTransferInput: NoSEPATransferInput,
        otpValidationDTO: OTPValidationDTO,
        otpCode: String,
        countryCode: String? = nil,
        aliasPayee: String? = nil,
        isNewPayee: Bool = false,
        trusteerInfo: TrusteerInfoDTO?
    ) throws -> BSANResponse<ConfirmationNoSEPADTO> {
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let refAcelera = validationIntNoSepaDTO.refAcelera ?? ""
        let request = ConfirmationNoSEPARequest(
            BSANAssembleProvider.getNoSEPAssemble(),
            try bsanDataProvider.getEnvironment().urlBase,
            ConfirmationNoSEPARequestParams(
                otpCode: otpCode,
                token: authCredentials.soapTokenCredential,
                userDataDTO: userDataDTO,
                languageISO: bsanHeaderData.languageISO,
                dialectISO: bsanHeaderData.dialectISO,
                noSepaTransferInput: noSepaTransferInput,
                validationIntNoSepaDTO: validationIntNoSepaDTO,
                validationSwiftDTO: validationSwiftDTO,
                otpValidationDTO: otpValidationDTO,
                beneficiaryEmail: noSepaTransferInput.beneficiaryEmail,
                countryCode: countryCode,
                aliasPayee: aliasPayee,
                newPayee: isNewPayee,
                refAcelera: refAcelera,
                trusteerInfo: trusteerInfo
            )
        )
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(response.confirmationNoSepa)
        }
        return BSANErrorResponse(meta)
    }
    
    public func loadEmittedNoSepaTransferDetail(transferEmittedDTO: TransferEmittedDTO) throws -> BSANResponse<NoSepaTransferEmittedDetailDTO> {
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
                
        let request = GetEmittedNoSepaTransferDetailRequest(
            BSANAssembleProvider.getEmittedTransfersAssemble(),
            try bsanDataProvider.getEnvironment().urlBase,
            GetEmittedNoSepaTransferDetailRequestParams(token: authCredentials.soapTokenCredential,
                                                  userDataDTO: userDataDTO,
                                                  dialectISO: bsanHeaderData.dialectISO,
                                                  languageISO: bsanHeaderData.languageISO,
                                                  bankCode: transferEmittedDTO.serviceOrder?.bankCode ?? "",
                                                  branchCode: transferEmittedDTO.serviceOrder?.branchCode ?? "",
                                                  product: transferEmittedDTO.serviceOrder?.product ?? "",
                                                  contractNumber: transferEmittedDTO.serviceOrder?.contractNumber ?? ""
        ))
        let response = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(response.noSepaTransferEmittedDetailDTO)
        }
        return BSANErrorResponse(meta)
    }


// MARK: -
// MARK: Generic Transfer
    
    public func validateGenericTransfer(originAccountDTO: AccountDTO, nationalTransferInput: GenericTransferInputDTO) throws -> BSANResponse<ValidateAccountTransferDTO> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ValidateGenericTransferRequest(
            BSANAssembleProvider.getTransfersAssemble(try bsanDataProvider.isPB()),
            try bsanDataProvider.getEnvironment().urlBase,
            ValidateGenericTransferRequestParams(token: authCredentials.soapTokenCredential,
                                                 userDataDTO: userDataDTO,
                                                 version: bsanHeaderData.version,
                                                 terminalId: bsanHeaderData.terminalID,
                                                 language: bsanHeaderData.language,
                                                 beneficiary: nationalTransferInput.beneficiary ?? "",
                                                 isSpanishResidentBeneficiary: nationalTransferInput.isSpanishResident ?? true,
                                                 saveAsUsualAlias: nationalTransferInput.saveAsUsualAlias,
                                                 saveAsUsual: nationalTransferInput.saveAsUsual ?? false,
                                                 beneficiaryMail: nationalTransferInput.beneficiaryMail ?? "",
                                                 ibandto: nationalTransferInput.ibandto,
                                                 transferAmount: nationalTransferInput.amountDTO,
                                                 bankCode: originAccountDTO.oldContract?.bankCode ?? "",
                                                 branchCode: originAccountDTO.oldContract?.branchCode ?? "",
                                                 product: originAccountDTO.oldContract?.product ?? "",
                                                 contractNumber: originAccountDTO.oldContract?.contractNumber ?? "",
                                                 concept: nationalTransferInput.concept ?? "",
                                                 transferType: nationalTransferInput.transferType))
        
        let response = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(response.validateAccountTransferDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func validateSanKeyTransfer(originAccountDTO: AccountDTO, nationalTransferInput: GenericTransferInputDTO) throws -> BSANResponse<ValidateAccountTransferDTO> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let request = ValidateSanKeyTransferRequest(
            BSANAssembleProvider.getTransfersAssemble(try bsanDataProvider.isPB()),
            try bsanDataProvider.getEnvironment().urlBase,
            ValidateSanKeyTransferRequestParams(
                token: authCredentials.soapTokenCredential,
                userDataDTO: userDataDTO,
                version: bsanHeaderData.version,
                terminalId: bsanHeaderData.terminalID,
                language: bsanHeaderData.language,
                beneficiary: nationalTransferInput.beneficiary ?? "",
                isSpanishResidentBeneficiary: nationalTransferInput.isSpanishResident ?? true,
                saveAsUsualAlias: nationalTransferInput.saveAsUsualAlias,
                saveAsUsual: nationalTransferInput.saveAsUsual ?? false,
                beneficiaryMail: nationalTransferInput.beneficiaryMail ?? "",
                ibandto: nationalTransferInput.ibandto,
                transferAmount: nationalTransferInput.amountDTO,
                bankCode: originAccountDTO.oldContract?.bankCode ?? "",
                branchCode: originAccountDTO.oldContract?.branchCode ?? "",
                product: originAccountDTO.oldContract?.product ?? "",
                contractNumber: originAccountDTO.oldContract?.contractNumber ?? "",
                concept: nationalTransferInput.concept ?? "",
                transferType: nationalTransferInput.transferType,
                tokenPush: nationalTransferInput.tokenPush
            )
        )
        
        let response = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(response.validateAccountTransferDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func validateGenericTransferOTP(originAccountDTO: AccountDTO, nationalTransferInput: NationalTransferInput, signatureDTO: SignatureDTO) throws -> BSANResponse<OTPValidationDTO> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ValidateGenericTransferOTPRequest(
            BSANAssembleProvider.getTransfersAssemble(try bsanDataProvider.isPB()),
            try bsanDataProvider.getEnvironment().urlBase,
            ValidateGenericTransferOTPRequestParams(token: authCredentials.soapTokenCredential,
                                                    userDataDTO: userDataDTO,
                                                    version: bsanHeaderData.version,
                                                    terminalId: bsanHeaderData.terminalID,
                                                    ibandto: nationalTransferInput.ibandto,
                                                    transferAmount: nationalTransferInput.amountDTO,
                                                    bankCode: originAccountDTO.oldContract?.bankCode ?? "",
                                                    branchCode: originAccountDTO.oldContract?.branchCode ?? "",
                                                    product: originAccountDTO.oldContract?.product ?? "",
                                                    contractNumber: originAccountDTO.oldContract?.contractNumber ?? "",
                                                    signatureDTO: signatureDTO,
                                                    language: bsanHeaderData.language,
                                                    dialectISO: bsanHeaderData.dialectISO))
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        
        if response.otpValidationDTO.otpExcepted || meta.code == BSANSoapResponse.RESULT_OTP_EXCEPTED_USER {
            meta.code = BSANSoapResponse.RESULT_OTP_EXCEPTED_USER
            return BSANOkResponse(meta, response.otpValidationDTO)
            
        } else {
            if meta.isOK() {
                BSANLogger.i(logTag, "Meta OK")
                return BSANOkResponse(meta, response.otpValidationDTO)
            }
            return BSANErrorResponse(meta)
        }
    }
    
    public func validateSanKeyTransferOTP(originAccountDTO: AccountDTO,
                                          nationalTransferInput: NationalTransferInput,
                                          signatureDTO: SignatureDTO?,
                                          tokenSteps: String,
                                          footPrint: String?,
                                          deviceToken: String?) throws -> BSANResponse<SanKeyOTPValidationDTO> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ValidateSanKeyTransferOTPRequest(
            BSANAssembleProvider.getTransfersAssemble(try bsanDataProvider.isPB()),
            try bsanDataProvider.getEnvironment().urlBase,
            ValidateSanKeyTransferOTPRequestParams(token: authCredentials.soapTokenCredential,
                                                    userDataDTO: userDataDTO,
                                                    version: bsanHeaderData.version,
                                                    terminalId: bsanHeaderData.terminalID,
                                                    ibandto: nationalTransferInput.ibandto,
                                                    transferAmount: nationalTransferInput.amountDTO,
                                                    bankCode: originAccountDTO.oldContract?.bankCode ?? "",
                                                    branchCode: originAccountDTO.oldContract?.branchCode ?? "",
                                                    product: originAccountDTO.oldContract?.product ?? "",
                                                    contractNumber: originAccountDTO.oldContract?.contractNumber ?? "",
                                                    signatureDTO: signatureDTO,
                                                    language: bsanHeaderData.language,
                                                    dialectISO: bsanHeaderData.dialectISO,
                                                    tokenPasos: tokenSteps,
                                                    footPrint: footPrint ?? "",
                                                    deviceToken: deviceToken ?? ""))
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        
        if response.sanKeyOtpValidationDTO.otpValidationDTO?.otpExcepted ?? false || meta.code == BSANSoapResponse.RESULT_OTP_EXCEPTED_USER {
            meta.code = BSANSoapResponse.RESULT_OTP_EXCEPTED_USER
            return BSANOkResponse(meta, response.sanKeyOtpValidationDTO)
            
        } else {
            if meta.isOK() {
                BSANLogger.i(logTag, "Meta OK")
                return BSANOkResponse(meta, response.sanKeyOtpValidationDTO)
            }
            return BSANErrorResponse(meta)
        }
    }

    public func confirmGenericTransfer(originAccountDTO: AccountDTO, nationalTransferInput: GenericTransferInputDTO, otpValidationDTO: OTPValidationDTO?, otpCode: String?) throws -> BSANResponse<TransferConfirmAccountDTO> {
        return try confirmGenericTransfer(originAccountDTO: originAccountDTO, nationalTransferInput: nationalTransferInput, otpValidationDTO: otpValidationDTO, otpCode: otpCode, trusteerInfo: nil)
    }
    
    public func confirmGenericTransfer(originAccountDTO: AccountDTO, nationalTransferInput: GenericTransferInputDTO, otpValidationDTO: OTPValidationDTO?, otpCode: String?, trusteerInfo: TrusteerInfoDTO?) throws -> BSANResponse<TransferConfirmAccountDTO> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ConfirmGenericTransferRequest(
            BSANAssembleProvider.getTransfersAssemble(try bsanDataProvider.isPB()),
            try bsanDataProvider.getEnvironment().urlBase,
            ConfirmGenericTransferRequestParams(token: authCredentials.soapTokenCredential,
                                                userDataDTO: userDataDTO,
                                                version: bsanHeaderData.version,
                                                terminalId: bsanHeaderData.terminalID,
                                                language: bsanHeaderData.language,
                                                beneficiary: nationalTransferInput.beneficiary ?? "",
                                                isSpanishResidentBeneficiary: nationalTransferInput.isSpanishResident ?? false,
                                                saveAsUsualAlias: nationalTransferInput.saveAsUsualAlias,
                                                saveAsUsual: nationalTransferInput.saveAsUsual ?? false,
                                                beneficiaryMail: nationalTransferInput.beneficiaryMail ?? "",
                                                ibandto: nationalTransferInput.ibandto,
                                                transferAmount: nationalTransferInput.amountDTO,
                                                bankCode: originAccountDTO.oldContract?.bankCode ?? "",
                                                branchCode: originAccountDTO.oldContract?.branchCode ?? "",
                                                product: originAccountDTO.oldContract?.product ?? "",
                                                contractNumber: originAccountDTO.oldContract?.contractNumber ?? "",
                                                concept: nationalTransferInput.concept ?? "",
                                                otpTicket: otpValidationDTO?.ticket ?? "",
                                                otpToken: otpValidationDTO?.magicPhrase ?? "",
                                                otpCode: otpCode ?? "",
                                                transferType: nationalTransferInput.transferType,
                                                trusteerInfo: trusteerInfo))
        
        let response = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(response.transferConfirmAccountDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func confirmSanKeyTransfer(originAccountDTO: AccountDTO,
                                      nationalTransferInput: GenericTransferInputDTO,
                                      otpValidationDTO: OTPValidationDTO?,
                                      otpCode: String?,
                                      tokenSteps: String) throws -> BSANResponse<TransferConfirmAccountDTO> {
        return try confirmSanKeyTransfer(
            originAccountDTO: originAccountDTO,
            nationalTransferInput: nationalTransferInput,
            otpValidationDTO: otpValidationDTO,
            otpCode: otpCode,
            trusteerInfo: nil,
            tokenSteps: tokenSteps
        )
    }
    
    public func confirmSanKeyTransfer(originAccountDTO: AccountDTO,
                                      nationalTransferInput: GenericTransferInputDTO,
                                      otpValidationDTO: OTPValidationDTO?,
                                      otpCode: String?,
                                      trusteerInfo: TrusteerInfoDTO?,
                                      tokenSteps: String) throws -> BSANResponse<TransferConfirmAccountDTO> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let params = ConfirmSanKeyTransferRequestParams(
            token: authCredentials.soapTokenCredential,
            userDataDTO: userDataDTO,
            version: bsanHeaderData.version,
            terminalId: bsanHeaderData.terminalID,
            language: bsanHeaderData.language,
            beneficiary: nationalTransferInput.beneficiary ?? "",
            isSpanishResidentBeneficiary: nationalTransferInput.isSpanishResident ?? false,
            saveAsUsualAlias: nationalTransferInput.saveAsUsualAlias,
            saveAsUsual: nationalTransferInput.saveAsUsual ?? false,
            beneficiaryMail: nationalTransferInput.beneficiaryMail ?? "",
            ibandto: nationalTransferInput.ibandto,
            transferAmount: nationalTransferInput.amountDTO,
            bankCode: originAccountDTO.oldContract?.bankCode ?? "",
            branchCode: originAccountDTO.oldContract?.branchCode ?? "",
            product: originAccountDTO.oldContract?.product ?? "",
            contractNumber: originAccountDTO.oldContract?.contractNumber ?? "",
            concept: nationalTransferInput.concept ?? "",
            otpTicket: otpValidationDTO?.ticket ?? "",
            otpToken: otpValidationDTO?.magicPhrase ?? "",
            otpCode: otpCode ?? "",
            transferType: nationalTransferInput.transferType,
            trusteerInfo: trusteerInfo,
            tokenSteps: tokenSteps
        )
        let request = ConfirmSanKeyTransferRequest(
            BSANAssembleProvider.getTransfersAssemble(try bsanDataProvider.isPB()),
            try bsanDataProvider.getEnvironment().urlBase,
            params
        )
        
        let response = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(response.transferConfirmAccountDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func validateAccountTransfer(originAccountDTO: AccountDTO, destinationAccountDTO: AccountDTO, accountTransferInput: AccountTransferInput) throws -> BSANResponse<TransferAccountDTO> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ValidateAccountTransferRequest(
            BSANAssembleProvider.getTransfersAssemble(try bsanDataProvider.isPB()),
            try bsanDataProvider.getEnvironment().urlBase,
            ValidateAccountTransferRequestParams(token: authCredentials.soapTokenCredential,
                                                 userDataDTO: userDataDTO,
                                                 version: bsanHeaderData.version,
                                                 terminalId: bsanHeaderData.terminalID,
                                                 language: bsanHeaderData.language,
                                                 transferAmount: accountTransferInput.amountDTO,
                                                 originBankCode: originAccountDTO.oldContract?.bankCode ?? "",
                                                 originBranchCode: originAccountDTO.oldContract?.branchCode ?? "",
                                                 originProduct: originAccountDTO.oldContract?.product ?? "",
                                                 originContractNumber: originAccountDTO.oldContract?.contractNumber ?? "",
                                                 destinationBankCode: destinationAccountDTO.oldContract?.bankCode ?? "",
                                                 destinationBranchCode: destinationAccountDTO.oldContract?.branchCode ?? "",
                                                 destinationProduct: destinationAccountDTO.oldContract?.product ?? "",
                                                 destinationContractNumber: destinationAccountDTO.oldContract?.contractNumber ?? "",
                                                 concept: accountTransferInput.concept))
        
        let response = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(response.transferAccountDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func confirmAccountTransfer(originAccountDTO: AccountDTO, destinationAccountDTO: AccountDTO, accountTransferInput: AccountTransferInput, signatureDTO: SignatureDTO) throws -> BSANResponse<Void> {
        return try confirmAccountTransfer(originAccountDTO: originAccountDTO, destinationAccountDTO: destinationAccountDTO, accountTransferInput: accountTransferInput, signatureDTO: signatureDTO, trusteerInfo: nil)
    }
    
    public func confirmAccountTransfer(originAccountDTO: AccountDTO, destinationAccountDTO: AccountDTO, accountTransferInput: AccountTransferInput, signatureDTO: SignatureDTO, trusteerInfo: TrusteerInfoDTO?) throws -> BSANResponse<Void> {
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let request = ConfirmAccountTransferRequest(
            BSANAssembleProvider.getTransfersAssemble(try bsanDataProvider.isPB()),
            try bsanDataProvider.getEnvironment().urlBase,
            ConfirmAccountTransferRequestParams(
                token: authCredentials.soapTokenCredential,
                userDataDTO: userDataDTO,
                version: bsanHeaderData.version,
                terminalId: bsanHeaderData.terminalID,
                language: bsanHeaderData.language,
                transferAmount: accountTransferInput.amountDTO,
                originBankCode: originAccountDTO.oldContract?.bankCode ?? "",
                originBranchCode: originAccountDTO.oldContract?.branchCode ?? "",
                originProduct: originAccountDTO.oldContract?.product ?? "",
                originContractNumber: originAccountDTO.oldContract?.contractNumber ?? "",
                destinationBankCode: destinationAccountDTO.oldContract?.bankCode ?? "",
                destinationBranchCode: destinationAccountDTO.oldContract?.branchCode ?? "",
                destinationProduct: destinationAccountDTO.oldContract?.product ?? "",
                destinationContractNumber: destinationAccountDTO.oldContract?.contractNumber ?? "",
                concept: accountTransferInput.concept,
                signatureDTO: signatureDTO,
                trusteerInfo: trusteerInfo
            )
        )
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        guard meta.isOK() else {  return BSANErrorResponse(meta) }
        BSANLogger.i(logTag, "Meta OK")
        return BSANOkResponse(meta)
    }
    
    public func checkEntityAdhered(genericTransferInput: GenericTransferInputDTO) throws -> BSANResponse<Void> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = CheckEntityAdheredRequest(
            BSANAssembleProvider.getInstantTransfersAssemble(),
            try bsanDataProvider.getEnvironment().urlBase,
            CheckEntityAdheredRequestParams(token: authCredentials.soapTokenCredential,
                                            userDataDTO: userDataDTO,
                                            languageISO: bsanHeaderData.languageISO,
                                            dialectISO: bsanHeaderData.dialectISO,
                                            linkedCompany: bsanHeaderData.linkedCompany,
                                            ibanTransferencia: genericTransferInput.ibandto,
                                            company: userDataDTO.company ?? ""))
        
        let response = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta)
        }
        return BSANErrorResponse(meta)
    }
    
    public func checkTransferStatus(referenceDTO: ReferenceDTO) throws -> BSANResponse<CheckTransferStatusDTO> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = CheckTransferStatusRequest(
            BSANAssembleProvider.getInstantTransfersAssemble(),
            try bsanDataProvider.getEnvironment().urlBase,
            CheckTransferStatusRequestParams(token: authCredentials.soapTokenCredential,
                                             userDataDTO: userDataDTO,
                                             languageISO: bsanHeaderData.languageISO,
                                             dialectISO: bsanHeaderData.dialectISO,
                                             linkedCompany: bsanHeaderData.linkedCompany,
                                             reference: referenceDTO))
        
        let response = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(response.checkTransferStatusDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func loadAllUsualTransfers() throws -> BSANResponse<[PayeeDTO]> {
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        var payees = [PayeeDTO]()
        let request = GetUsualTransfersRequest(
            BSANAssembleProvider.getUsualTransfersAssemble(),
            try bsanDataProvider.getEnvironment().urlBase,
            GetUsualTransfersRequestParams(token: authCredentials.soapTokenCredential,
                                           userDataDTO: userDataDTO,
                                           language: bsanHeaderData.languageISO,
                                           dialect: bsanHeaderData.dialectISO,
                                           pagination: nil))
        var response: GetUsualTransfersResponse = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        guard (meta.isOK()) else { return BSANErrorResponse(meta) }
        BSANLogger.i(logTag, "Meta OK")
        if let payeeList = response.payeeDTOs {
            payees.append(contentsOf: payeeList)
        }
        while response.paginationDTO != nil && response.paginationDTO?.endList == false {
            let request = GetUsualTransfersRequest(
                BSANAssembleProvider.getUsualTransfersAssemble(),
                try bsanDataProvider.getEnvironment().urlBase,
                GetUsualTransfersRequestParams(token: authCredentials.soapTokenCredential,
                                               userDataDTO: userDataDTO,
                                               language: bsanHeaderData.languageISO,
                                               dialect: bsanHeaderData.dialectISO,
                                               pagination: response.paginationDTO))
            response = try sanSoapServices.executeCall(request)
            let meta = try Meta.createMeta(request, response)
            if (meta.isOK()) {
                if let payeeList = response.payeeDTOs {
                    payees.append(contentsOf: payeeList)
                }
            } else {
                BSANLogger.i(logTag, "Meta FAIL")
                break
            }
        }
        for var payee in payees {
            payee.transferAmount = nil
            payee.concept = nil
        }
        return BSANOkResponse(meta, payees)
    }
    
    public func noSepaPayeeDetail(of alias: String, recipientType: String) throws -> BSANResponse<NoSepaPayeeDetailDTO> {
        let bsanAssemble = BSANAssembleProvider.getSepaPayeeDetailAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let parameters = NoSepaPayeeDetailRequestParams(
            token: authCredentials.soapTokenCredential,
            userDataDTO: userDataDTO,
            languageISO: bsanHeaderData.languageISO,
            dialectISO: bsanHeaderData.dialectISO,
            alias: alias,
            recipientType: recipientType)
        let request = NoSepaPayeeDetailRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            parameters
        )
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, response.noSepaPayeeDetailDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func validateCreateNoSepaPayee(newAlias: String, newCurrency: CurrencyDTO?, noSepaPayeeDTO: NoSepaPayeeDTO?) throws -> BSANResponse<SignatureWithTokenDTO> {
        let bsanAssemble = BSANAssembleProvider.getSepaPayeeDetailAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let parameters = ValidateCreateNoSepaPayeeRequestParams(
            token: authCredentials.soapTokenCredential,
            userDataDTO: userDataDTO,
            languageISO: bsanHeaderData.languageISO,
            dialectISO: bsanHeaderData.dialectISO,
            newAlias: newAlias,
            newCurrencyDTO: newCurrency,
            noSepaPayeeDTO: noSepaPayeeDTO,
            bankAddress: getBankAddress(noSepaPayeeDTO),
            bankTown: getBankTown(noSepaPayeeDTO),
            bankCountryName: getBankCountryName(noSepaPayeeDTO))
        let request = ValidateCreateNoSepaPayeeRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            parameters
        )
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, response.signatureWithToken)
        }
        return BSANErrorResponse(meta)
    }
    
    public func validateCreateNoSepaPayeeOTP(signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<OTPValidationDTO> {
        let bsanAssemble = BSANAssembleProvider.getSepaPayeeDetailAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let parameters = ValidateCreateNoSepaPayeeOTPRequestParams(
            token: authCredentials.soapTokenCredential,
            userDataDTO: userDataDTO,
            languageISO: bsanHeaderData.languageISO,
            dialectISO: bsanHeaderData.dialectISO,
            signatureWithTokenDTO: signatureWithTokenDTO
        )
        let request = ValidateCreateNoSepaPayeeOTPRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            parameters
        )
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        
        if response.otpValidationDTO.otpExcepted || meta.code == BSANSoapResponse.RESULT_OTP_EXCEPTED_USER {
            meta.code = BSANSoapResponse.RESULT_OTP_EXCEPTED_USER
            return BSANOkResponse(meta, response.otpValidationDTO)
            
        } else {
            if meta.isOK() {
                BSANLogger.i(logTag, "Meta OK")
                return BSANOkResponse(meta, response.otpValidationDTO)
            }
            return BSANErrorResponse(meta)
        }
    }
    
    public func confirmCreateNoSepaPayee(otpValidationDTO: OTPValidationDTO?, otpCode: String?) throws -> BSANResponse<ConfirmCreateNoSepaPayeeDTO> {
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getSepaPayeeDetailAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ConfirmCreateNoSepaPayeeRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            ConfirmCreateNoSepaPayeeRequestParams(token: authCredentials.soapTokenCredential,
                                                userDataDTO: userDataDTO,
                                                languageISO: bsanHeaderData.languageISO,
                                                dialectISO: bsanHeaderData.dialectISO,
                                                otpToken: otpValidationDTO?.magicPhrase ?? "",
                                                otpTicket: otpValidationDTO?.ticket ?? "",
                                                otpCode: otpCode ?? ""))
        
        let response = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            bsanDataProvider.removeFavouriteTransfer()
            return BSANOkResponse(meta, response.confirmCreateNoSepaPayeeDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func validateUpdateNoSepaPayee(alias: String, noSepaPayeeDTO: NoSepaPayeeDTO?, newCurrencyDTO: CurrencyDTO?) throws -> BSANResponse<SignatureWithTokenDTO> {
        let bsanAssemble = BSANAssembleProvider.getSepaPayeeDetailAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let parameters = ValidateUpdateNoSepaPayeeRequestParams(
            token: authCredentials.soapTokenCredential,
            userDataDTO: userDataDTO,
            languageISO: bsanHeaderData.languageISO,
            dialectISO: bsanHeaderData.dialectISO,
            alias: alias,
            noSepaPayeeDTO: noSepaPayeeDTO,
            newCurrencyDTO: newCurrencyDTO,
            bankAddress: getBankAddress(noSepaPayeeDTO),
            bankTown: getBankTown(noSepaPayeeDTO),
            bankCountryName: getBankCountryName(noSepaPayeeDTO)
        )
        let request = ValidateUpdateNoSepaPayeeRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            parameters
        )
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, response.signatureWithToken)
        }
        return BSANErrorResponse(meta)
    }
    
    public func validateUpdateNoSepaPayeeOTP(signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<OTPValidationDTO> {
        let bsanAssemble = BSANAssembleProvider.getSepaPayeeDetailAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let parameters = ValidateUpdateNoSepaPayeeOTPRequestParams(
            token: authCredentials.soapTokenCredential,
            userDataDTO: userDataDTO,
            languageISO: bsanHeaderData.languageISO,
            dialectISO: bsanHeaderData.dialectISO,
            signatureWithTokenDTO: signatureWithTokenDTO
        )
        let request = ValidateUpdateNoSepaPayeeOTPRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            parameters
        )
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        
        if response.otpValidationDTO.otpExcepted || meta.code == BSANSoapResponse.RESULT_OTP_EXCEPTED_USER {
            meta.code = BSANSoapResponse.RESULT_OTP_EXCEPTED_USER
            return BSANOkResponse(meta, response.otpValidationDTO)
            
        } else {
            if meta.isOK() {
                BSANLogger.i(logTag, "Meta OK")
                return BSANOkResponse(meta, response.otpValidationDTO)
            }
            return BSANErrorResponse(meta)
        }
    }
    
    public func confirmUpdateNoSepaPayee(otpValidationDTO: OTPValidationDTO?, otpCode: String?) throws -> BSANResponse<Void> {
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getSepaPayeeDetailAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ConfirmUpdateNoSepaPayeeRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            ConfirmUpdateNoSepaPayeeRequestParams(token: authCredentials.soapTokenCredential,
                                                  userDataDTO: userDataDTO,
                                                  languageISO: bsanHeaderData.languageISO,
                                                  dialectISO: bsanHeaderData.dialectISO,
                                                  otpToken: otpValidationDTO?.magicPhrase ?? "",
                                                  otpTicket: otpValidationDTO?.ticket ?? "",
                                                  otpCode: otpCode ?? ""))
        
        let response = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            bsanDataProvider.removeFavouriteTransfer()
            return BSANOkResponse(meta)
        }
        return BSANErrorResponse(meta)
    }
    
    public func loadTransferSubTypeCommissions(originAccount: AccountDTO, destinationAccount: IBANDTO, amount: AmountDTO, beneficiary: String, concept: String) throws -> BSANResponse<TransferSubTypeCommissionDTO> {
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let userDataDTO = try bsanDataProvider.getUserData()
        let dataSource = TransferSubTypeCommissionDataSource(sanRestServices: sanRestServices, bsanDataProvider: bsanDataProvider)
        return try dataSource.loadTransferTypeComissions(
            params: TransferSubTypeComissionRequestParams(
                beneficiaryName: beneficiary,
                originAccountNumber: originAccount.iban?.description ?? "",
                originAccountOwner: "",
                destinationAccountNumber: destinationAccount.codBban,
                destinationAccountCountry: destinationAccount.countryCode,
                destinationAccountDigit: destinationAccount.checkDigits,
                amountWholeNumberPart: amount.wholePart,
                amountFractionalPart: amount.getDecimalPart(),
                concept: concept,
                multichannelContract: userDataDTO.contract?.description.trim() ?? "",
                language: bsanHeaderData.language,
                personType: userDataDTO.clientPersonType ?? "",
                personCode: userDataDTO.clientPersonCode ?? ""
            )
        )
    }
    
    private func getBankAddress(_ noSepaPayeeDTO: NoSepaPayeeDTO?) -> String {
        //ÑAPA OBLIGATORIA
        if noSepaPayeeDTO?.swiftCode == nil {
            let address = noSepaPayeeDTO?.bankAddress ?? ""
            return address.isEmpty ? "@" : address
        }
        return ""
    }
    
    private func getBankTown(_ noSepaPayeeDTO: NoSepaPayeeDTO?) -> String {
        //ÑAPA OBLIGATORIA
        if noSepaPayeeDTO?.swiftCode == nil {
            let town = noSepaPayeeDTO?.bankTown ?? ""
            return town.isEmpty ? "@" : town
        }
        return ""
    }
    
    private func getBankCountryName(_ noSepaPayeeDTO: NoSepaPayeeDTO?) -> String {
        //ÑAPA OBLIGATORIA
        if noSepaPayeeDTO?.swiftCode == nil {
            let countryName = noSepaPayeeDTO?.bankCountryName ?? ""
            return countryName.isEmpty ? "@" : countryName
        }
        return ""
    }
}
