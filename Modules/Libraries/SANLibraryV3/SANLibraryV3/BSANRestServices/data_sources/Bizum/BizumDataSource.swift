import SANLegacyLibrary

public class BizumDataSource {
    let sanRestServices: SanRestServices
    private let bsanDataProvider: BSANDataProvider
    private let noBasePath = "/"
    private let bizumBasePath = "/bizum/"
    private let apiBasePath = "/api/v1/"
    private let checkPaymentPath = "payments/"
    private let validateMoneyTransferPath = "bizum-multi/"
    private let getSignPositionsPath = "swendi/"
    private let operationsPath = "bizum-txt-img/"
    private let operationsMultiPath = "bizum-multi/"
    private let organizationsPath = "bizum-boar/"
    private let validateMoneyTransferServiceName = "validate-money-transfer"
    private let validateMoneyRequestServiceName = "validate-money-request"
    private let validateMoneyRequestMultiServiceName = "validate-money-request-multi"
    private let moneyRequestServiceName = "money-request"
    private let moneyRequestMultiServiceName = "money-request-multi"
    private let validateMoneyTransferMultiServiceName = "validate-money-transfer-multi"
    private let getSignPositionsServiceName = "sign-positions"
    private let validateMoneyTransferOTPServiceName = "validate-money-transfer-otp"
    private let moneyTransferOTPServiceName = "money-transfer-otp"
    private let moneyTransferMultiServiceName = "money-transfer-multi"
    private let serviceNameCheckPayment = "check-payment"
    private let serviceNameGetContacts = "contacts"
    private let inviteNoClientOTPServiceName = "invite-no-client-otp"
    private let inviteNoClientServiceName = "invite-no-client"
    private let operationsServiceName = "multi-filter-query"
    private let operationsListMultipleServiceName = "list-multi-operations"
    private let operationsMultipleDetailServiceName = "multi-operation-details"
    private let cancelNotRegisterServiceName = "cancel-pending-transfer"
    private let refundMoneyServiceName = "money-refund"
    private let headers = ["X-Santander-Channel" : "RML"]
    private let getOrganizations = "get-organizations"
    private let redsysDocument = "customer-inquiry"

    public init(sanRestServices: SanRestServices, bsanDataProvider: BSANDataProvider) {
        self.sanRestServices = sanRestServices
        self.bsanDataProvider = bsanDataProvider
    }
}

extension BizumDataSource: BizumDataSourceProtocol {

    // MARK: - RestDataSource: DataSourceCheckExceptionErrorProtocol

    func checkServiceError(response: String) -> String? {
        guard let data = response.data(using: .utf8) else {
            return nil
        }
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        guard let jsonDictionary = json as? [String: Any] else {
            return nil
        }
        if let httpMessage = jsonDictionary["detailedMessage"] as? String {
            return httpMessage
        } else {
            return nil
        }
    }

    // MARK: - BizumDataSourceProtocol

    /// Get bizum contacs
    /// - Parameter params: BizumGetContactsParams data
    func getContacts(params: BizumGetContactsParams) throws -> BSANResponse<BizumGetContactsDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let url = source + self.bizumBasePath + self.serviceNameGetContacts
        return try self.executeRestCall(
            serviceName: self.serviceNameGetContacts,
            serviceUrl: url,
            params: params,
            contentType: ContentType.json,
            requestType: .post,
            headers: headers,
            responseEncoding: .utf8)
    }

    /// Get the operation Id to continue with the operation.
    /// - Parameter params: BizumGetContactsParams data
    func checkPayment() throws -> BSANResponse<BizumCheckPaymentDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let url = source + self.noBasePath + self.checkPaymentPath + self.serviceNameCheckPayment
        return try self.executeRestCall(
            serviceName: serviceNameCheckPayment,
            serviceUrl: url,
            params: EmptyParams(),
            contentType: ContentType.json,
            requestType: .post,
            headers: headers,
            responseEncoding: .utf8)
    }

    /// Validate individual transfer. Depends on checkPayment WS
    /// - Parameter params: BizumValidateMoneyTransferParams data
    func validateMoneyTransfer(params: BizumValidateMoneyTransferParams) throws -> BSANResponse<BizumValidateMoneyTransferDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let url = source + self.apiBasePath + self.validateMoneyTransferPath + self.validateMoneyTransferServiceName
        return try self.executeRestCall(
            serviceName: self.validateMoneyTransferServiceName,
            serviceUrl: url,
            params: params,
            contentType: ContentType.json,
            requestType: .post,
            headers: headers,
            responseEncoding: .utf8)
    }

    /// Validate money transfer operation for multi receiver transfers.
    /// - Parameter params: BizumValidateMoneyTransferMultiParams data
    func validateMoneyTransferMulti(params: BizumValidateMoneyTransferMultiParams) throws -> BSANResponse<BizumValidateMoneyTransferMultiDTO> {
       let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
       guard let source = bsanEnvironment.microURL else {
           return BSANErrorResponse(nil)
       }
       let url = source + self.apiBasePath + self.validateMoneyTransferPath + self.validateMoneyTransferMultiServiceName
       return try self.executeRestCall(
           serviceName: self.validateMoneyTransferMultiServiceName,
           serviceUrl: url,
           params: params,
           contentType: ContentType.json,
           requestType: .post,
           headers: headers,
           responseEncoding: .utf8)
    }

    /// Get sign positions to validate the transaction
    /// - Parameter params: SignPositionParams data
    func getSignPositions(params: SignPositionParams) throws -> BSANResponse<BizumSignPositionsDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let url = source + self.noBasePath + self.getSignPositionsPath + self.getSignPositionsServiceName
        return try self.executeRestCall(
            serviceName: self.getSignPositionsServiceName,
            serviceUrl: url,
            params: params,
            contentType: ContentType.json,
            requestType: .post,
            headers: headers,
            responseEncoding: .utf8)
    }

    /// Validate money transfer operation
    /// - Parameter params: BizumValidateMoneyTransferOTPParams data
    func validateMoneyTransferOTP(params: BizumValidateMoneyTransferOTPParams) throws -> BSANResponse<BizumValidateMoneyTransferOTPDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let url = source + self.apiBasePath + self.validateMoneyTransferPath + self.validateMoneyTransferOTPServiceName
        return try self.executeRestCall(
            serviceName: self.validateMoneyTransferOTPServiceName,
            serviceUrl: url,
            params: params,
            contentType: ContentType.json,
            requestType: .post,
            headers: headers,
            responseEncoding: .utf8)
    }

    /// Final bizum transfer step.
    /// - Parameter params: BizumMoneyTransferOTPParams data
    func moneyTransferOTP(params: BizumMoneyTransferOTPParams) throws -> BSANResponse<BizumMoneyTransferOTPDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let url = source + self.apiBasePath + self.validateMoneyTransferPath + self.moneyTransferOTPServiceName
        return try self.executeRestCall(
            serviceName: self.moneyTransferOTPServiceName,
            serviceUrl: url,
            params: params,
            contentType: ContentType.json,
            requestType: .post,
            headers: headers,
            responseEncoding: .utf8)
    }

    /// Final bizum multi-transfer final step.
    /// - Parameter params: BizumMoneyTransferOTPParams data
    func moneyTransferOTPMulti(params: BizumMoneyTransferMultiParams) throws -> BSANResponse<BizumTransferInfoDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let url = source + self.apiBasePath + self.validateMoneyTransferPath + self.moneyTransferMultiServiceName
        return try self.executeRestCall(
            serviceName: self.moneyTransferMultiServiceName,
            serviceUrl: url,
            params: params,
            contentType: ContentType.json,
            requestType: .post,
            headers: headers,
            responseEncoding: .utf8)
    }

    /// Invite a non-Bizum-client receiver with OTP
    /// - Parameter params: BizumInviteNoClientOTPParams data
    func inviteNoClientOTP(params: BizumInviteNoClientOTPParams) throws -> BSANResponse<BizumInviteNoClientDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let url = source + self.bizumBasePath + self.inviteNoClientOTPServiceName
        return try self.executeRestCall(
            serviceName: self.inviteNoClientOTPServiceName,
            serviceUrl: url,
            params: params,
            contentType: ContentType.json,
            requestType: .post,
            headers: headers,
            responseEncoding: .utf8)
    }

    /// Invite a non-Bizum-client receiver
    /// - Parameter params: BizumInviteNoClientParams data
    func inviteNoClient(params: BizumInviteNoClientParams) throws -> BSANResponse<BizumInviteNoClientDTO> {
         let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
         guard let source = bsanEnvironment.microURL else {
             return BSANErrorResponse(nil)
         }
         let url = source + self.bizumBasePath + self.inviteNoClientServiceName
         return try self.executeRestCall(
             serviceName: self.inviteNoClientServiceName,
             serviceUrl: url,
             params: params,
             contentType: ContentType.json,
             requestType: .post,
             headers: headers,
             responseEncoding: .utf8)
     }

    func getOperations(_ params: BizumOperationsParams) throws -> BSANResponse<BizumOperationListDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let url = source + self.apiBasePath + self.operationsPath + self.operationsServiceName
        return try self.executeRestCall(
            serviceName: self.operationsServiceName,
            serviceUrl: url,
            params: params,
            contentType: ContentType.json,
            requestType: .post,
            headers: headers,
            responseEncoding: .utf8)
    }

    func getOperationsMultiple(_ params: BizumOperationListMultiple) throws -> BSANResponse<BizumOperationMultiListDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let url = source + self.apiBasePath + self.operationsMultiPath + self.operationsListMultipleServiceName
        return try self.executeRestCall(
            serviceName: self.operationsListMultipleServiceName,
            serviceUrl: url,
            params: params,
            contentType: ContentType.json,
            requestType: .post,
            headers: headers,
            responseEncoding: .utf8)
    }

    func getOperationsMultipleDetail(_ params: BizumOperationMultipleDetail) throws -> BSANResponse<BizumOperationMultipleListDetailDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let url = source + self.apiBasePath + self.operationsMultiPath + self.operationsMultipleDetailServiceName
        return try self.executeRestCall(
            serviceName: self.operationsMultipleDetailServiceName,
            serviceUrl: url,
            params: params,
            contentType: ContentType.json,
            requestType: .post,
            headers: headers,
            responseEncoding: .utf8)
    }
    
    /// Validates simple money request.
    /// - Parameter params: BizumValidateMoneyRequestParams
    func validateMoneyRequest(_ params: BizumValidateMoneyRequestParams) throws -> BSANResponse<BizumValidateMoneyRequestDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let url = source + bizumBasePath + validateMoneyRequestServiceName
        return try executeRestCall(serviceName: validateMoneyRequestServiceName,
                                   serviceUrl: url,
                                   params: params,
                                   contentType: ContentType.json,
                                   requestType: .post,
                                   headers: headers,
                                   responseEncoding: .utf8)
    }
    
    func moneyRequest(_ params: BizumMoneyRequestParams) throws  -> BSANResponse<BizumMoneyRequestDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let url = source + bizumBasePath + moneyRequestServiceName
        return try executeRestCall(serviceName: moneyRequestServiceName,
                                   serviceUrl: url,
                                   params: params,
                                   contentType: ContentType.json,
                                   requestType: .post,
                                   headers: headers,
                                   responseEncoding: .utf8)
    }
    
    func validateMoneyRequestMulti(_ params: BizumValidateMoneyRequestMultiParams) throws -> BSANResponse<BizumValidateMoneyRequestMultiDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let url = source + bizumBasePath + validateMoneyRequestMultiServiceName
        return try executeRestCall(serviceName: validateMoneyRequestMultiServiceName,
                                   serviceUrl: url,
                                   params: params,
                                   contentType: ContentType.json,
                                   requestType: .post,
                                   headers: headers,
                                   responseEncoding: .utf8)
    }
    
    func moneyRequestMulti(_ params: BizumMoneyRequestMultiParams) throws -> BSANResponse<BizumMoneyRequestMultiDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let url = source + bizumBasePath + moneyRequestMultiServiceName
        return try executeRestCall(serviceName: moneyRequestMultiServiceName,
                                   serviceUrl: url,
                                   params: params,
                                   contentType: ContentType.json,
                                   requestType: .post,
                                   headers: headers,
                                   responseEncoding: .utf8)
    }
    
    func cancelPendingTransfer(_ params: BizumCancelNotRegisterParam) throws -> BSANResponse<BizumResponseInfoDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let url = source + apiBasePath + operationsMultiPath + cancelNotRegisterServiceName
        return try executeRestCall(serviceName: cancelNotRegisterServiceName,
                                   serviceUrl: url,
                                   params: params,
                                   contentType: ContentType.json,
                                   requestType: .post,
                                   headers: headers,
                                   responseEncoding: .utf8)
    }
    
    func refundMoneyRequest(_ params: BizumRefundMoneyRequestParams) throws -> BSANResponse<BizumRefundMoneyResponseDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let url = source + apiBasePath + operationsMultiPath + refundMoneyServiceName
        return try executeRestCall(serviceName: refundMoneyServiceName,
                                   serviceUrl: url,
                                   queryParam: nil,
                                   body: Body(bodyParam: params),
                                   requestType: .post,
                                   headers: headers,
                                   responseEncoding: .utf8)
    }
    
    func getOrganizations(_ params: BizumGetOrganizationsParams) throws -> BSANResponse<BizumOrganizationsListDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let url = source + self.apiBasePath + self.organizationsPath + self.getOrganizations
        return try self.executeRestCall(
            serviceName: self.getOrganizations,
            serviceUrl: url,
            params: params,
            contentType: ContentType.json,
            requestType: .post,
            headers: headers,
            responseEncoding: .utf8)
    }
    
    func getRedsysDocument(input params: BizumGetRedsysDocumentParams) throws -> BSANResponse<BizumRedsysDocumentDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let url = source + self.bizumBasePath + self.redsysDocument
        return try self.executeRestCall(
            serviceName: self.redsysDocument,
            serviceUrl: url,
            params: params,
            contentType: ContentType.json,
            requestType: .post,
            headers: headers,
            responseEncoding: .utf8
        )
    }
}
