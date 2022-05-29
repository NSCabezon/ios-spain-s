import SANLegacyLibrary
import CoreDomain

public class BSANBillTaxesManagerImplementation: BSANBaseManager, BSANBillTaxesManager {
    
    var sanSoapServices: SanSoapServices
    private let sanRestServices: SanRestServices
    
    public init(bsanDataProvider: BSANDataProvider, sanSoapServices: SanSoapServices, sanRestServices: SanRestServices) {
        self.sanSoapServices = sanSoapServices
        self.sanRestServices = sanRestServices
        super.init(bsanDataProvider: bsanDataProvider)
    }
    
    public func validateBillAndTaxes(accountDTO: AccountDTO, barCode: String) throws -> BSANResponse<PaymentBillTaxesDTO> {
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getBillTaxesAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let newGlobalPosition = try bsanDataProvider.get(\.newGlobalPositionDTO)
        
        let requestAccount = newGlobalPosition.accounts?.first(where: { $0.iban == accountDTO.iban }) ?? accountDTO
        
        let request = ValidationBillTaxesRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            ValidationBillTaxesRequestParams(token: authCredentials.soapTokenCredential,
                                             userDataDTO: userDataDTO,
                                             bankCode: requestAccount.oldContract?.bankCode ?? "",
                                             branchCode: requestAccount.oldContract?.branchCode ?? "",
                                             product: requestAccount.oldContract?.product ?? "",
                                             contractNumber: requestAccount.oldContract?.contractNumber ?? "",
                                             barCode: barCode))
        
        let response: ValidationBillTaxesResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            bsanDataProvider.store(paymentBillTaxes: response.paymentBillTaxesDTO)
            return BSANOkResponse(meta, response.paymentBillTaxesDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func confirmationBillAndTaxes(chargeAccountDTO: AccountDTO,
                                         paymentBillTaxesDTO: PaymentBillTaxesDTO,
                                         billAndTaxesTokenDTO: BillAndTaxesTokenDTO,
                                         directDebit: Bool) throws -> BSANResponse<PaymentBillTaxesConfirmationDTO> {
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getBillTaxesAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let newGlobalPosition = try bsanDataProvider.get(\.newGlobalPositionDTO)
        
        let requestAccount = newGlobalPosition.accounts?.first(where: { $0.iban == chargeAccountDTO.iban }) ?? chargeAccountDTO
        
        let request = ConfirmationBillTaxesRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            ConfirmationBillTaxesRequestParams(
                signatureToken: billAndTaxesTokenDTO.token ?? "",
                userDataDTO: userDataDTO,
                chargeAccountBankCode: requestAccount.oldContract?.bankCode ?? "",
                chargeAccountBranchCode: requestAccount.oldContract?.branchCode ?? "",
                chargeAccountProduct: requestAccount.oldContract?.product ?? "",
                chargeAccountContractNumber: requestAccount.oldContract?.contractNumber ?? "",
                directDebitAccountBankCode: directDebit ? requestAccount.oldContract?.bankCode ?? "" : "",
                directDebitAccountBranchCode: directDebit ? requestAccount.oldContract?.branchCode ?? "" : "",
                directDebitAccountProduct: directDebit ? requestAccount.oldContract?.product ?? "" : "",
                directDebitAccountContractNumber: directDebit ? requestAccount.oldContract?.contractNumber ?? "" : "",
                billAmountValueForWS: AmountFormats.getValueForWS(value: paymentBillTaxesDTO.billAmount?.value),
                billAmountCurrency: paymentBillTaxesDTO.billAmount?.currency?.currencyName ?? "",
                issuing: paymentBillTaxesDTO.takingsIssuing?.issuing ?? "",
                product: paymentBillTaxesDTO.takingsIssuing?.product ?? "",
                takingsType: paymentBillTaxesDTO.takingsIssuing?.takingsSubType?.type ?? "",
                takingsSubtype: paymentBillTaxesDTO.takingsIssuing?.takingsSubType?.subtype ?? "",
                token: authCredentials.soapTokenCredential,
                formatDescriptionList: paymentBillTaxesDTO.list ?? []))
        
        let response: ConfirmationBillTaxesResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, response.paymentBillTaxesConfirmationDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func consultSignatureBillAndTaxes(chargeAccountDTO: AccountDTO, directDebit: Bool, amountDTO: AmountDTO) throws -> BSANResponse<SignatureWithTokenDTO>{
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getBillTaxesSignatureAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let newGlobalPosition = try bsanDataProvider.get(\.newGlobalPositionDTO)
        
        let requestAccount = newGlobalPosition.accounts?.first(where: { $0.iban == chargeAccountDTO.iban }) ?? chargeAccountDTO
        
        let request = ConsultSignatureBillTaxesRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            ConsultSignatureBillTaxesRequestParams(
                token: authCredentials.soapTokenCredential,
                directDebit: directDebit,
                userDataDTO: userDataDTO,
                amountValueForWS: AmountFormats.getValueForWS(value: amountDTO.value),
                chargeAccountBankCode: requestAccount.oldContract?.bankCode ?? "",
                chargeAccountBranchCode: requestAccount.oldContract?.branchCode ?? "",
                chargeAccountProduct: requestAccount.oldContract?.product ?? "",
                chargeAccountContractNumber: requestAccount.oldContract?.contractNumber ?? "",
                directDebitAccountBankCode: directDebit ? requestAccount.oldContract?.bankCode ?? "" : "",
                directDebitAccountBranchCode: directDebit ? requestAccount.oldContract?.branchCode ?? "" : "",
                directDebitAccountProduct: directDebit ? requestAccount.oldContract?.product ?? "" : "",
                directDebitAccountContractNumber: directDebit ? requestAccount.oldContract?.contractNumber ?? "" : ""))
        
        let response: ConsultSignatureBillTaxesResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, response.signatureWithTokenDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func confirmationSignatureBillAndTaxes(signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<BillAndTaxesTokenDTO> {
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getBillTaxesSignatureAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        
        let request = ConfirmationSignatureBillTaxesRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            ConfirmationSignatureBillTaxesRequestParams(
                token: authCredentials.soapTokenCredential,
                signatureToken: signatureWithTokenDTO.magicPhrase ?? "",
                signaturePositionsValues: getPositionsStringValues(values: signatureWithTokenDTO.signatureDTO?.values ?? [])))
        
        let response: ConfirmationSignatureBillTaxesResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            bsanDataProvider.store(tokenCredential: response.tokenCredential)
            return BSANOkResponse(meta, response.tokenCredential)
        }
        return BSANErrorResponse(meta)
    }
    
    public func consultFormats(of account: AccountDTO, emitterCode: String, productIdentifier: String, collectionTypeCode: String, collectionCode: String) throws -> BSANResponse<ConsultTaxCollectionFormatsDTO> {
        
        let bsanAssemble = BSANAssembleProvider.getBillTaxesAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let newGlobalPosition = try bsanDataProvider.get(\.newGlobalPositionDTO)
        let requestAccount = newGlobalPosition.accounts?.first(where: { $0.iban == account.iban }) ?? account

        let request = ConsultTaxCollectionRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            ConsultTaxCollectionRequestParams(token: authCredentials.soapTokenCredential,
                                              userDataDTO: userDataDTO,
                                              language: bsanHeaderData.languageISO,
                                              dialect: bsanHeaderData.dialectISO,
                                              accountDTO: requestAccount,
                                              emitterCode: emitterCode,
                                              productIdentifier: productIdentifier,
                                              collectionTypeCode: collectionTypeCode,
                                              collectionCode: collectionCode)
        )
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            if let consultTaxCollection = response.consultTaxCollection {
                return BSANOkResponse(consultTaxCollection)
            }
        }
        return BSANErrorResponse(meta)
    }
    
    public func loadBills(of account: AccountDTO, from fromDate: DateModel, to toDate: DateModel, status: BillListStatus) throws -> BSANResponse<BillListDTO> {
        try loadBills(of: account, pagination: nil, from: fromDate, to: toDate, status: status)
    }

    public func loadBills(of account: AccountDTO, pagination: PaginationDTO?, from fromDate: DateModel, to toDate: DateModel, status: BillListStatus) throws -> BSANResponse<BillListDTO> {
        guard let contract = account.contract?.contratoPK else {
            return BSANErrorResponse(Meta.createKO())
        }
        
        let requestKey = contract + fromDate.string + toDate.string + status.description
        let billListDTO = try bsanDataProvider.get(\.billAndTaxesInfo).billAndTaxesCacheFor(requestKey)
        
        if (billListDTO != nil) {
            if pagination == nil || billListDTO?.pagination?.endList == true {
                return BSANOkResponse(billListDTO)
            }
        }
        
        let bsanAssemble = BSANAssembleProvider.getBillsManagementAsemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let newGlobalPosition = try bsanDataProvider.get(\.newGlobalPositionDTO)
        
        let requestAccount = newGlobalPosition.accounts?.first(where: { $0.iban == account.iban }) ?? account
        
        let request = BillListRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            BillListRequestParams(
                token: authCredentials.soapTokenCredential,
                userDataDTO: userDataDTO,
                language: bsanHeaderData.language,
                dialect: bsanHeaderData.dialectISO,
                accountDTO: requestAccount,
                paginationDTO: pagination,
                fromDate: fromDate,
                toDate: toDate,
                status: status
            )
        )
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            if let billList = response.billList {
                bsanDataProvider.storeBillAndTaxesList(billListDTO: billList, key: requestKey)
            }
            if let result = try bsanDataProvider.get(\.billAndTaxesInfo).billAndTaxesCacheFor(requestKey) {
                return BSANOkResponse(result)
            }
            
        }
        return BSANErrorResponse(meta)
    }
    
    public func deleteBillList() throws -> BSANResponse<Void> {
        bsanDataProvider.deleteBillList()
        return BSANOkEmptyResponse()
    }
    
    public func billAndTaxesDetail(of account: AccountDTO, bill: BillDTO, enableBillAndTaxesRemedy: Bool) throws -> BSANResponse<BillDetailDTO> {
        let bsanAssemble = BSANAssembleProvider.getBillTaxesDetailAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let newGlobalPosition = try bsanDataProvider.get(\.newGlobalPositionDTO)
        
        let requestAccount = newGlobalPosition.accounts?.first(where: { $0.iban == account.iban }) ?? account
        
        let parameters = BillAndTaxesDetailRequestParams(
            language: bsanHeaderData.language,
            token: authCredentials.soapTokenCredential,
            userDataDTO: userDataDTO,
            billDTO: bill,
            accountDTO: requestAccount,
            billOrderServiceBankCode: bill.creditorCompanyId,
            billOrderServiceBranchCode: enableBillAndTaxesRemedy ? bill.company.centro : bill.company.empresa,
            billOrderServiceProduct: bill.codProd,
            billOrderServiceContractNumber: bill.paymentOrderCode)
        let request = BillAndTaxesDetailRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            parameters
        )
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, response.billDetailDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    
    private func getPositionsStringValues(values: [String]) -> String {
        var result = ""
        for value in values {
            result += value + " "
        }
        if !result.isEmpty {
            result.removeLast()
        }
        return result
    }
    
    public func cancelDirectBilling(account: AccountDTO, bill: BillDTO, enableBillAndTaxesRemedy: Bool) throws -> BSANResponse<GetCancelDirectBillingDTO> {
        let bsanAssemble = BSANAssembleProvider.getBillsManagementAsemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let newGlobalPosition = try bsanDataProvider.get(\.newGlobalPositionDTO)
        
        let requestAccount = newGlobalPosition.accounts?.first(where: { $0.iban == account.iban }) ?? account
        
        let request = GetCancelDirectBillingRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            GetCancelDirectBillingRequestParams(
                token: authCredentials.soapTokenCredential,
                userDataDTO: userDataDTO,
                language: bsanHeaderData.languageISO,
                dialect: bsanHeaderData.dialectISO,
                accountDTO: requestAccount,
                billDTO: bill,
                enableBillAndTaxesRemedy: enableBillAndTaxesRemedy
            )
        )
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK(), let cancelDirectBilling = response.getCancelDirectBillingDTO {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, cancelDirectBilling)
        }
        return BSANErrorResponse(meta)
    }
    
    public func confirmCancelDirectBilling(account: AccountDTO, bill: BillDTO, signature: SignatureDTO, getCancelDirectBillingDTO: GetCancelDirectBillingDTO) throws -> BSANResponse<Void> {
        let bsanAssemble = BSANAssembleProvider.getBillsManagementAsemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let newGlobalPosition = try bsanDataProvider.get(\.newGlobalPositionDTO)
        
        let requestAccount = newGlobalPosition.accounts?.first(where: { $0.iban == account.iban }) ?? account
        
        let request = ConfirmCancelDirectBillingRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            ConfirmCancelDirectBillingRequestParams(
                token: authCredentials.soapTokenCredential,
                userDataDTO: userDataDTO,
                language: bsanHeaderData.languageISO,
                dialect: bsanHeaderData.dialectISO,
                signature: signature,
                accountDTO: requestAccount,
                billDTO: bill,
                getCancelDirectBillingDTO: getCancelDirectBillingDTO
            )
        )
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, nil)
        }
        return BSANErrorResponse(meta)
    }
    
    public func duplicateBill(account: AccountDTO, bill: BillDTO, enableBillAndTaxesRemedy: Bool) throws -> BSANResponse<DuplicateBillDTO> {
        let bsanAssemble = BSANAssembleProvider.getBillsManagementAsemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let newGlobalPosition = try bsanDataProvider.get(\.newGlobalPositionDTO)
        
        let requestAccount = newGlobalPosition.accounts?.first(where: { $0.iban == account.iban }) ?? account
        
        let request = GetDuplicateBillRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            GetDuplicateBillRequestParams(
                token: authCredentials.soapTokenCredential,
                userDataDTO: userDataDTO,
                language: bsanHeaderData.languageISO,
                dialect: bsanHeaderData.dialectISO,
                accountDTO: requestAccount,
                billDTO: bill,
                enableBillAndTaxesRemedy: enableBillAndTaxesRemedy
            )
        )
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK(), let duplicateBill = response.duplicateBillDTO {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, duplicateBill)
        }
        return BSANErrorResponse(meta)
    }
    
    public func confirmDuplicateBill(account: AccountDTO, bill: BillDTO, signature: SignatureDTO, enableBillAndTaxesRemedy: Bool) throws -> BSANResponse<Void> {
        let bsanAssemble = BSANAssembleProvider.getBillsManagementAsemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let newGlobalPosition = try bsanDataProvider.get(\.newGlobalPositionDTO)
        
        let requestAccount = newGlobalPosition.accounts?.first(where: { $0.iban == account.iban }) ?? account
        
        let request = ConfirmDuplicateBillRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            ConfirmDuplicateBillRequestParams(
                token: authCredentials.soapTokenCredential,
                userDataDTO: userDataDTO,
                language: bsanHeaderData.languageISO,
                dialect: bsanHeaderData.dialectISO,
                signature: signature,
                accountDTO: requestAccount,
                billDTO: bill, enableBillAndTaxesRemedy: enableBillAndTaxesRemedy
            )
        )
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, nil)
        }
        return BSANErrorResponse(meta)
    }
    
    public func confirmReceiptReturn(account: AccountDTO, bill: BillDTO, billDetail: BillDetailDTO, signature: SignatureDTO, enableBillAndTaxesRemedy: Bool) throws -> BSANResponse<Void> {
        let bsanAssemble = BSANAssembleProvider.getReceiptReturnBillsManagementAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let newGlobalPosition = try bsanDataProvider.get(\.newGlobalPositionDTO)
        
        let requestAccount = newGlobalPosition.accounts?.first(where: { $0.iban == account.iban }) ?? account
        
        let request = ConfirmReceiptReturnRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            ConfirmReceiptReturnRequestParams(
                token: authCredentials.soapTokenCredential,
                userDataDTO: userDataDTO,
                language: bsanHeaderData.language,
                signature: signature,
                accountDTO: requestAccount,
                billDTO: bill,
                billDetaildDTO: billDetail,
                enableBillAndTaxesRemedy: enableBillAndTaxesRemedy
            )
        )
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, nil)
        }
        return BSANErrorResponse(meta)
    }
    
    public func confirmChangeDirectDebit(account: AccountDTO, bill: BillDTO, signature: SignatureWithTokenDTO) throws -> BSANResponse<Void> {
        let bsanAssemble = BSANAssembleProvider.getBillsManagementAsemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let newGlobalPosition = try bsanDataProvider.get(\.newGlobalPositionDTO)
        
        let requestAccount = newGlobalPosition.accounts?.first(where: { $0.iban == account.iban }) ?? account
        
        let request = ConfirmChangeDirectDebitRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            ConfirmChangeDirectDebitRequestParams(
                token: authCredentials.soapTokenCredential,
                userDataDTO: userDataDTO,
                language: bsanHeaderData.languageISO,
                dialect: bsanHeaderData.dialectISO,
                signature: signature,
                accountDTO: requestAccount,
                billDTO: bill
            )
        )
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, nil)
        }
        return BSANErrorResponse(meta)
    }
    
    public func downloadPdfBill(account: AccountDTO, bill: BillDTO, enableBillAndTaxesRemedy: Bool) throws -> BSANResponse<DocumentDTO> {
        let bsanAssemble = BSANAssembleProvider.getBillsManagementAsemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let newGlobalPosition = try bsanDataProvider.get(\.newGlobalPositionDTO)
        
        let requestAccount = newGlobalPosition.accounts?.first(where: { $0.iban == account.iban }) ?? account
        
        let request = DownloadPdfBillRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            DownloadPdfBillRequestParams(
                token: authCredentials.soapTokenCredential,
                userDataDTO: userDataDTO,
                language: bsanHeaderData.languageISO,
                dialect: bsanHeaderData.dialectISO,
                accountDTO: requestAccount,
                billDTO: bill,
                enableBillAndTaxesRemedy: enableBillAndTaxesRemedy
            )
        )
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, response.documentDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    
    /// Method that call `validaCambioMasivoSepaLa` service
    public func validateChangeMassiveDirectDebitsAccount(originAccount: AccountDTO, destinationAccount: AccountDTO) throws -> BSANResponse<SignatureWithTokenDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let newGlobalPosition = try bsanDataProvider.get(\.newGlobalPositionDTO)
        
        let requestOriginAccount = newGlobalPosition.accounts?.first(where: { $0.iban == originAccount.iban }) ?? originAccount
        let requestDestinationAccount = newGlobalPosition.accounts?.first(where: { $0.iban == destinationAccount.iban }) ?? destinationAccount

        let request = ValidateChangeMassiveDirectDebitsAccountRequest(
            BSANAssembleProvider.getBillsManagementAsemble(),
            bsanEnvironment.urlBase,
            ValidateChangeMassiveDirectDebitsAccountRequestParams(
                token: authCredentials.soapTokenCredential,
                userDataDTO: userDataDTO,
                language: bsanHeaderData.languageISO,
                dialect: bsanHeaderData.dialectISO,
                originAccount: requestOriginAccount,
                destinationAccount: requestDestinationAccount
            )
        )
        let response: ValidateChangeMassiveDirectDebitsAccountResponse = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK(), let signature = response.signature {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, signature)
        }
        return BSANErrorResponse(meta)
    }
    
    
    /// Method that call `confirmaCambioMasivoSepaLa` service
    @available(iOS, deprecated: 5.0.10, message: "new method confirmChangeMassiveDirectDebitsAccount(originAccount: AccountDTO, signature: SignatureWithTokenDTO)")
    public func confirmChangeMassiveDirectDebitsAccount(signature: SignatureWithTokenDTO) throws -> BSANResponse<Void> {
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ConfirmChangeMassiveDirectDebitsAccountRequest(
            BSANAssembleProvider.getBillsManagementAsemble(),
            bsanEnvironment.urlBase,
            ConfirmChangeMassiveDirectDebitsAccountRequestParams(
                token: authCredentials.soapTokenCredential,
                userDataDTO: userDataDTO,
                language: bsanHeaderData.languageISO,
                dialect: bsanHeaderData.dialectISO,
                signature: signature
            )
        )
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, nil)
        }
        return BSANErrorResponse(meta)
    }
    
    public func confirmChangeMassiveDirectDebitsAccount(originAccount: AccountDTO, signature: SignatureWithTokenDTO) throws -> BSANResponse<Void> {
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let newGlobalPosition = try bsanDataProvider.get(\.newGlobalPositionDTO)
        
        let requestAccount = newGlobalPosition.accounts?.first(where: { $0.iban == originAccount.iban }) ?? originAccount
        
        let request = ConfirmChangeMassiveDirectDebitsAccountRequest(
            BSANAssembleProvider.getBillsManagementAsemble(),
            bsanEnvironment.urlBase,
            ConfirmChangeMassiveDirectDebitsAccountRequestParams(
                token: authCredentials.soapTokenCredential,
                userDataDTO: userDataDTO,
                accountDTO: requestAccount,
                language: bsanHeaderData.languageISO,
                dialect: bsanHeaderData.dialectISO,
                signature: signature
            )
        )
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, nil)
        }
        return BSANErrorResponse(meta)
    }
    
    public func loadFutureBills(account: AccountDTO, status: String, numberOfElements: Int, page: Int) throws -> BSANResponse<AccountFutureBillListDTO> {
        let newGlobalPosition = try bsanDataProvider.get(\.newGlobalPositionDTO)
        let requestAccount = newGlobalPosition.accounts?.first(where: { $0.iban == account.iban }) ?? account
        let iban = requestAccount.contract?.formattedValue ?? ""
        let params = AccountFutureBillParams(
            iban: iban,
            status: status,
            numberOfElements: numberOfElements,
            page: page
        )
        let requestKey = iban + status.description + page.description
        let storedFutureBills: AccountFutureBillListDTO? = try bsanDataProvider.get(\.billAndTaxesInfo).futureBillCacheFor(requestKey)
        if let billList = storedFutureBills?.billList, billList.count > 0 {
            return BSANOkResponse(storedFutureBills)
        }
        let dataSource = AccountFutureBillListDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: bsanDataProvider)
        let response = try dataSource.loadAccountFutureBillList(params: params)
        if response.isSuccess(), let accountFutureBillDTO = try response.getResponseData() {
            bsanDataProvider.storeFutureBillList(requestKey, futureBillList: accountFutureBillDTO)
        } else {
            bsanDataProvider.removeFutureBillList()
        }
        return response
    }
    
    public func emittersConsult(params: EmittersConsultParamsDTO) throws -> BSANResponse<EmittersConsultDTO> {
        let assemble = BSANAssembleProvider.getBillTaxesAssemble()
        let environment = try bsanDataProvider.getEnvironment()
        let userData = try bsanDataProvider.getUserData()
        let auth = try bsanDataProvider.getAuthCredentials()
        
        let params = EmittersConsultRequestParams(
            token: auth.soapTokenCredential,
            userDataDTO: userData,
            bankCode: params.account.oldContract?.bankCode ?? "",
            branchCode: params.account.oldContract?.branchCode ?? "",
            product: params.account.oldContract?.product ?? "",
            contractNumber: params.account.oldContract?.contractNumber ?? "",
            emitterCode: params.emitterCode,
            emitterName: params.emitterName,
            paginationXML: params.pagination.getRepositionXML())
        
        let request = EmittersConsultRequest(assemble, environment.urlBase, params)
        let response: EmittersConsultResponse = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        guard meta.isOK() else { return BSANErrorResponse(meta) }
        return BSANOkResponse(meta, response.emittersConsult)
    }
    
    public func loadBillCollectionList(emitterCode: String, account: AccountDTO) throws -> BSANResponse<BillCollectionListDTO> {
        try loadBillCollectionList(emitterCode: emitterCode, account: account, pagination: nil)
    }
    
    public func loadBillCollectionList(emitterCode: String, account: AccountDTO, pagination: PaginationDTO?) throws -> BSANResponse<BillCollectionListDTO> {
        guard (account.contract?.contratoPK) != nil else {
            return BSANErrorResponse(Meta.createKO())
        }
        let bsanAssemble = BSANAssembleProvider.getBillTaxesAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let params = BillCollectionListRequestParams(
            token: authCredentials.soapTokenCredential,
            userDataDTO: userDataDTO,
            language: bsanHeaderData.languageISO,
            dialect: bsanHeaderData.dialectISO,
            paginationDTO: pagination,
            accountDTO: account,
            transmitterCode: emitterCode
        )
        let request = BillCollectionListRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            params
        )
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(response.billCollectionList)
        }
        return BSANErrorResponse(meta)
    }
    
    public func emittersPaymentConfirmation(account: AccountDTO, signature: SignatureDTO, amount: AmountDTO, emitterCode: String, productIdentifier: String, collectionTypeCode: String, collectionCode: String, billData: [String]) throws -> BSANResponse<BillEmittersPaymentConfirmationDTO> {
        let assemble = BSANAssembleProvider.getBillTaxesAssemble()
        let environment = try bsanDataProvider.getEnvironment()
        let userData = try bsanDataProvider.getUserData()
        let auth = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let params = BillEmittersPaymentConfirmationRequestParams(
            token: auth.soapTokenCredential,
            userDataDTO: userData,
            language: bsanHeaderData.languageISO,
            dialect: bsanHeaderData.dialectISO,
            account: account,
            signature: signature,
            amount: amount,
            emitterCode: emitterCode,
            productIdentifier: productIdentifier,
            collectionTypeCode: collectionTypeCode,
            collectionCode: collectionCode,
            billData: billData
        )
        let request = BillEmittersPaymentConfirmationRequest(assemble, environment.urlBase, params)
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        guard meta.isOK(), let confirmationData = response.confirmation else { return BSANErrorResponse(meta) }
        return BSANOkResponse(meta, confirmationData)
    }
}
