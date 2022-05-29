import SANLegacyLibrary

public class BSANBizumManagerImplementation: BSANBaseManager, BSANBizumManager {
    private let sanRestServices: SanRestServices
    private let language = " pi-PI"
    
    public init(bsanDataProvider: BSANDataProvider, sanRestServices: SanRestServices) {
        self.sanRestServices = sanRestServices
        super.init(bsanDataProvider: bsanDataProvider)
    }
    
    public func checkPayment(defaultXPAN: String) throws -> BSANResponse<BizumCheckPaymentDTO> {
        let checkPaymentDataSource = BizumDataSource(sanRestServices: sanRestServices,
                                                     bsanDataProvider: bsanDataProvider)
        if let checkPayment = try bsanDataProvider.get(\.bizumInfo).bizumCheckPayment {
            return BSANOkResponse(updateXPANIfNecessary(defaultXPAN, data: checkPayment))
        }
        let checkPaymentDTOResponse = try checkPaymentDataSource.checkPayment()
        if checkPaymentDTOResponse.isSuccess(), let data = try checkPaymentDTOResponse.getResponseData() {
            self.bsanDataProvider.storeBizumCheckPayment(operationList: updateXPANIfNecessary(defaultXPAN, data: data))
        }
        return checkPaymentDTOResponse
    }
    
    public func getContacts(_ input: BizumGetContactsInputParams) throws -> BSANResponse<BizumGetContactsDTO> {
        let dataSource = BizumDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: self.bsanDataProvider)
        let userData = try self.bsanDataProvider.getUserData()
        let params = BizumGetContactsParams(cmc: userData.getCMC,
                                            language: self.language,
                                            phoneNumber: input.checkPayment.phone,
                                            contactList: input.contactList)
        let key = params.phoneNumber.trim()
        if let contactList = try bsanDataProvider.get(\.bizumInfo).bizumGetContactsDictionary[key] {
            return BSANOkResponse(contactList)
        }
        let response = try dataSource.getContacts(params: params)
        if response.isSuccess(), let data = try response.getResponseData() {
            self.bsanDataProvider.storeBizumContactList(operationList: data, key: key)
        }
        return response
    }
    
    public func validateMoneyTransfer(_ input: BizumValidateMoneyTransferInputParams) throws -> BSANResponse<BizumValidateMoneyTransferDTO> {
        let dataSource = BizumDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: self.bsanDataProvider)
        let userData = try self.bsanDataProvider.getUserData()
        let bizumCheckPaymentDTO = input.checkPayment
        let dateTime = DateFormats.toString(date: input.dateTime, output: DateFormats.TimeFormat.YYYYMMDD_HHmmssSSS)
        let params = BizumValidateMoneyTransferParams(operationId: "",
                                                      transactionId: "",
                                                      state: "",
                                                      cmc: userData.getCMC,
                                                      language: self.language,
                                                      dateTime: dateTime,
                                                      concept: input.concept,
                                                      amount: input.amount,
                                                      emitterLanguage: "spa",
                                                      emitterAlias: "",
                                                      emitterName: "",
                                                      emitterUserId: bizumCheckPaymentDTO.phone.trim(),
                                                      receiverUserId: input.receiverUserId,
                                                      emitterVirtualElement: bizumCheckPaymentDTO.xpan?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
                                                      emitterDocumentType: input.document.document.type,
                                                      emitterDocumentCode: input.document.document.code,
                                                      emitterIban: input.account?.iban?.description ?? bizumCheckPaymentDTO.ibanCode.description,
                                                      emitterIbanCurrency: "EUR")
        return try dataSource.validateMoneyTransfer(params: params)
    }
    
    public func validateMoneyTransferMulti(_ input: BizumValidateMoneyTransferMultiInputParams) throws -> BSANResponse<BizumValidateMoneyTransferMultiDTO> {
        let dataSource = BizumDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: self.bsanDataProvider)
        let userData = try self.bsanDataProvider.getUserData()
        let dateTime = DateFormats.toString(date: input.dateTime, output: DateFormats.TimeFormat.YYYYMMDD_HHmmssSSS)
        let params = BizumValidateMoneyTransferMultiParams(cmc: userData.getCMC,
                                                           language: self.language,
                                                           dateTime: dateTime,
                                                           concept: input.concept,
                                                           amount: input.amount,
                                                           emitterLanguage: "spa",
                                                           emitterAlias: "",
                                                           emitterName: "",
                                                           emitterUserId: input.checkPayment.phone,
                                                           receiverUserIds: input.receiverUserIds,
                                                           emitterVirtualElement: input.checkPayment.xpan?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
                                                           emitterDocumentType: input.document.document.type,
                                                           emitterDocumentCode: input.document.document.code,
                                                           emitterIban: input.account?.iban?.description ?? input.checkPayment.ibanCode.description,
                                                           emitterIbanCurrency: "EUR")
        return try dataSource.validateMoneyTransferMulti(params: params)
    }
    
    public func getSignPositions() throws -> BSANResponse<BizumSignPositionsDTO> {
        let dataSource = BizumDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: self.bsanDataProvider)
        let userData = try self.bsanDataProvider.getUserData()
        return try dataSource.getSignPositions(params: SignPositionParams(cmc: userData.getCMC,
                                                                          language: self.language,
                                                                          application: "PAINOP"))
    }
    
    public func validateMoneyTransferOTP(_ input: BizumValidateMoneyTransferOTPInputParams) throws -> BSANResponse<BizumValidateMoneyTransferOTPDTO> {
        let dataSource = BizumDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: self.bsanDataProvider)
        let userData = try self.bsanDataProvider.getUserData()
        let params = BizumValidateMoneyTransferOTPParams(
            cmc: userData.getCMC,
            language: self.language,
            signPositions: self.convertToSingPositions(input.signatureWithTokenDTO.signatureDTO),
            securityToken: input.signatureWithTokenDTO.magicPhrase ?? "",
            emitterIban: input.account?.iban?.description ?? input.checkPayment.ibanCode.description,
            emitterIbanCurrency: "EUR",
            amount: input.amount,
            numberOfRecipients: input.numberOfRecipients,
            operation: input.operation,
            footPrint: input.footPrint,
            deviceMagicPhrase: input.deviceMagicPhrase
        )
        return try dataSource.validateMoneyTransferOTP(params: params)
    }
    
    public func signRefundMoney(with input: BizumSignRefundMoneyInputParams) throws -> BSANResponse<BizumValidateMoneyTransferOTPDTO> {
        let dataSource = BizumDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: self.bsanDataProvider)
        let userData = try self.bsanDataProvider.getUserData()
        let params = BizumValidateMoneyTransferOTPParams(cmc: userData.getCMC,
                                                         language: self.language,
                                                         signPositions: self.convertToSingPositions(input.signatureWithTokenDTO.signatureDTO),
                                                         securityToken: input.signatureWithTokenDTO.magicPhrase ?? "",
                                                         emitterIban: input.iban.description,
                                                         emitterIbanCurrency: input.amount.currency?.currencyType.name ?? "",
                                                         amount: AmountFormats.formattedAmountForWS(amount: input.amount.value ?? 0),
                                                         numberOfRecipients: 1,
                                                         operation: "C2CDD",
                                                         footPrint: nil,
                                                         deviceMagicPhrase: nil)
        return try dataSource.validateMoneyTransferOTP(params: params)
    }
    
    private func convertToSingPositions(_ signtaure: SignatureDTO?) -> [String: String] {
        var filleds: [String: String] = [:]
        let count = signtaure?.positions?.count ?? 0
        for index in 0..<count {
            if let position = signtaure?.positions?[index],
               let value = signtaure?.values?[index] {
                filleds["c\(position)"] = value
            }
        }
        return filleds
    }
    
    private func updateXPANIfNecessary(_ defaultXPAN: String, data: BizumCheckPaymentDTO) -> BizumCheckPaymentDTO {
        guard (data.xpan ?? "").isEmpty else { return data }
        return BizumCheckPaymentDTO(phone: data.phone,
                                    contractIdentifier: data.contractIdentifier,
                                    initialDate: data.initialDate,
                                    endDate: data.endDate,
                                    back: data.back,
                                    message: data.message,
                                    ibanCode: data.ibanCode,
                                    offset: data.offset,
                                    offsetState: data.offsetState,
                                    indMigrad: data.indMigrad,
                                    xpan: defaultXPAN)
    }
    
    public func acceptRequestMoneyTransferOTP(_ input: BizumAcceptRequestMoneyTransferOTPInputParams) throws -> BSANResponse<BizumMoneyTransferOTPDTO> {
        let dataSource = BizumDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: self.bsanDataProvider)
        let userData = try self.bsanDataProvider.getUserData()
        let dateTime = DateFormats.toString(date: input.dateTime, output: DateFormats.TimeFormat.YYYYMMDD_HHmmssSSS)
        let params = BizumMoneyTransferOTPParams(operation: "A",
                                                 securityToken: input.otpValidationDTO.magicPhrase ?? "",
                                                 otpTicket: input.otpValidationDTO.ticket ?? "",
                                                 otpCode: input.otpCode,
                                                 operationId: input.operationId,
                                                 transactionId: "",
                                                 state: "PENDIENTE",
                                                 cmc: userData.getCMC,
                                                 language: self.language,
                                                 dateTime: dateTime,
                                                 concept: input.concept,
                                                 amount: input.amount,
                                                 emitterLanguage: "spa",
                                                 emitterAlias: "",
                                                 emitterName: "",
                                                 emitterUserId: input.checkPayment.phone.trim(),
                                                 receiverUserId: input.receiverUserId.trim(),
                                                 emitterVirtualElement: input.checkPayment.xpan?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
                                                 emitterDocumentType: input.document.document.type,
                                                 emitterDocumentCode: input.document.document.code,
                                                 emitterIban: input.checkPayment.ibanCode.description,
                                                 emitterIbanCurrency: "EUR",
                                                 tokenPush: input.magicPhrasePush)
        return try dataSource.moneyTransferOTP(params: params)
    }
    
    public func moneyTransferOTP(_ input: BizumMoneyTransferOTPInputParams) throws -> BSANResponse<BizumMoneyTransferOTPDTO> {
        let dataSource = BizumDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: self.bsanDataProvider)
        let userData = try self.bsanDataProvider.getUserData()
        let dateTime = DateFormats.toString(date: input.dateTime, output: DateFormats.TimeFormat.YYYYMMDD_HHmmssSSS)
        let params = BizumMoneyTransferOTPParams(operation: "E",
                                                 securityToken: input.otpValidationDTO.magicPhrase ?? "",
                                                 otpTicket: input.otpValidationDTO.ticket ?? "",
                                                 otpCode: input.otpCode,
                                                 operationId: input.validateMoneyTransferDTO.operationId,
                                                 transactionId: "",
                                                 state: "VALIDADA",
                                                 cmc: userData.getCMC,
                                                 language: self.language,
                                                 dateTime: dateTime,
                                                 concept: input.concept,
                                                 amount: input.amount,
                                                 emitterLanguage: "spa",
                                                 emitterAlias: "",
                                                 emitterName: "",
                                                 emitterUserId: input.checkPayment.phone.trim(),
                                                 receiverUserId: input.receiverUserId.trim(),
                                                 emitterVirtualElement: input.checkPayment.xpan?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
                                                 emitterDocumentType: input.document.document.type,
                                                 emitterDocumentCode: input.document.document.code,
                                                 emitterIban: input.account?.iban?.description ?? input.checkPayment.ibanCode.description,
                                                 emitterIbanCurrency: "EUR",
                                                 tokenPush: input.magicPhrasePush)
        return try dataSource.moneyTransferOTP(params: params)
    }
    
    public func moneyTransferOTPMulti(_ input: BizumMoneyTransferOTPMultiInputParams) throws -> BSANResponse<BizumTransferInfoDTO> {
        let dataSource = BizumDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: self.bsanDataProvider)
        let userData = try self.bsanDataProvider.getUserData()
        let dateTime = DateFormats.toString(date: input.dateTime, output: DateFormats.TimeFormat.YYYYMMDD_HHmmssSSS)
        let params = BizumMoneyTransferMultiParams(
            securityToken: input.otpValidationDTO.magicPhrase ?? "",
            otpTicket: input.otpValidationDTO.ticket ?? "",
            otpCode: input.otpCode,
            operationId: input.validateMoneyTransferMultiDTO.multiOperationId,
            cmc: userData.getCMC,
            language: self.language,
            dateTime: dateTime,
            concept: input.concept,
            amount: input.amount,
            emitterLanguage: "spa",
            emitterAlias: "",
            emitterName: "",
            emitterUserId: input.checkPayment.phone.trim(),
            emitterVirtualElement: input.checkPayment.xpan?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            emitterDocumentType: input.document.document.type,
            emitterDocumentCode: input.document.document.code,
            emitterIban: input.account?.iban?.description ?? input.checkPayment.ibanCode.description,
            emitterIbanCurrency: "EUR",
            actions: input.validateMoneyTransferMultiDTO.validationResponseList.map {
                return BizumReceiverOperationParams(operationId: $0.operationId,
                                                    receiverUserId: $0.identifier.trim(),
                                                    action: $0.action)
            },
            tokenPush: input.tokenPush
        )
        return try dataSource.moneyTransferOTPMulti(params: params)
    }
    
    public func inviteNoClientOTP(_ input: BizumInviteNoClientOTPInputParams) throws -> BSANResponse<BizumInviteNoClientDTO> {
        let dataSource = BizumDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: self.bsanDataProvider)
        let userData = try self.bsanDataProvider.getUserData()
        let params = BizumInviteNoClientOTPParams(cmc: userData.getCMC,
                                                  language: self.language,
                                                  operationId: input.validateMoneyTransferDTO.operationId,
                                                  amount: input.amount,
                                                  currency: "EUR",
                                                  token: input.otpValidationDTO.magicPhrase ?? "",
                                                  otpTicket: input.otpValidationDTO.ticket ?? "",
                                                  otpCode: input.otpCode)
        return try dataSource.inviteNoClientOTP(params: params)
    }
    
    public func inviteNoClient(_ input: BizumInviteNoClientInputParams) throws -> BSANResponse<BizumInviteNoClientDTO> {
        let dataSource = BizumDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: self.bsanDataProvider)
        let userData = try self.bsanDataProvider.getUserData()
        let params = BizumInviteNoClientParams(cmc: userData.getCMC, language: self.language, operationId: input.validateMoneyRequestDTO.operationId)
        return try dataSource.inviteNoClient(params: params)
    }
    
    // MARK: - Operations
    
    public func getOperations(_ input: BizumOperationsInputParams) throws -> BSANResponse<BizumOperationListDTO> {
        let dateFrom = DateFormats.toString(date: input.dateFrom, output: DateFormats.TimeFormat.YYYYMMDD_HHmmssSSSZ)
        let dateTo = DateFormats.toString(date: input.dateTo, output: DateFormats.TimeFormat.YYYYMMDD_HHmmssSSSZ)
        let userData = try self.bsanDataProvider.getUserData()
        let params = BizumOperationsParams(cmc: userData.getCMC,
                                           language: self.language,
                                           emitterUserId: input.checkPayment.phone,
                                           fromTimestamp: dateFrom,
                                           toTimestamp: dateTo,
                                           elements: 20,
                                           pageNumber: input.page,
                                           orderBy: input.orderBy ?? "",
                                           orderType: input.orderType ?? "",
                                           requestFields: ["CONTENIDO_ADICIONAL", "IND_MULTIPLE", "IND_ONG"],
                                           conditions: [])
        let key = params.uniqueKey
        if let accountTransactionList = try bsanDataProvider.get(\.bizumInfo).historicOperationsDictionary[key] {
            return BSANOkResponse(accountTransactionList)
        } else {
            let dataSource = BizumDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: self.bsanDataProvider)
            let response = try dataSource.getOperations(params)
            if response.isSuccess(), let data = try response.getResponseData() {
                self.bsanDataProvider.storeBizumOperationList(operationList: data, key: key)
            }
            return response
        }
    }
    
    public func getListMultipleOperations(_ input: BizumOperationListMultipleInputParams) throws -> BSANResponse<BizumOperationMultiListDTO> {
        let userData = try self.bsanDataProvider.getUserData()
        let bizumCheckPaymentDTO = input.checkPayment
        let dateFrom = DateFormats.toString(date: input.formDate, output: DateFormats.TimeFormat.YYYYMMDD_HHmmssSSSZ)
        let dateTo = DateFormats.toString(date: input.toDate, output: DateFormats.TimeFormat.YYYYMMDD_HHmmssSSSZ)
        let params = BizumOperationListMultiple(cmc: userData.getCMC,
                                                language: self.language,
                                                emitterUserId: bizumCheckPaymentDTO.phone,
                                                fromTimestamp: dateFrom,
                                                toTimestamp: dateTo,
                                                elements: input.elements,
                                                pageNumber: input.page)
        let key = params.uniqueKey
        if let accountTransactionList = try bsanDataProvider.get(\.bizumInfo).historicMultipleOperationsDictionary[key] {
            return BSANOkResponse(accountTransactionList)
        } else {
            let dataSource = BizumDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: self.bsanDataProvider)
            let response = try dataSource.getOperationsMultiple(params)
            if response.isSuccess(), let data = try response.getResponseData() {
                self.bsanDataProvider.storeBizumMultipleOperationList(operationList: data, key: key)
            }
            return response
        }
    }
    
    public func getListMultipleDetailOperation(_ input: BizumOperationMultipleListDetailInputParams) throws -> BSANResponse<BizumOperationMultipleListDetailDTO> {
        let dataSource = BizumDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: self.bsanDataProvider)
        let userData = try self.bsanDataProvider.getUserData()
        let bizumCheckPaymentDTO = input.checkPayment
        let params = BizumOperationMultipleDetail(cmc: userData.getCMC,
                                                  language: self.language,
                                                  emitterUserId: bizumCheckPaymentDTO.phone,
                                                  operationId: input.operation.opeartionId ?? "")
        return try dataSource.getOperationsMultipleDetail(params)
    }
    
    // MARK: - Multimedia
    
    public func getMultimediaUsers(_ input: BizymMultimediaUsersInputParams) throws -> BSANResponse<BizumGetMultimediaContactsDTO> {
        let dataSource = BizumMultimediaDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: self.bsanDataProvider)
        let userData = try self.bsanDataProvider.getUserData()
        return try dataSource.getMultimediaContacts(params: BizumGetMultimediaContactsParams(cmc: userData.getCMC, language: self.language, emitterUserId: input.checkPayment.phone, contacts: input.contactList))
    }
    
    public func getMultimediaContent(_ input: BizumMultimediaContentInputParams) throws -> BSANResponse<BizumGetMultimediaContentDTO> {
        let dataSource = BizumMultimediaDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: self.bsanDataProvider)
        let userData = try self.bsanDataProvider.getUserData()
        return try dataSource.getMultimediaContent(params: BizumGetMultimediaContentParams(cmc: userData.getCMC, language: self.language, emitterUserId: input.checkPayment.phone, operationId: input.operationId))
    }
    
    public func sendAcceptRequestMoneyText(_ input: BizumAcceptRequestSendMultimediaInputParams) throws -> BSANResponse<BizumTransferInfoDTO> {
        let dataSource = BizumMultimediaDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: self.bsanDataProvider)
        let userData = try self.bsanDataProvider.getUserData()
        let params = BizumSendImageTextParams(cmc: userData.getCMC,
                                              language: self.language,
                                              emitterUserId: input.checkPayment.phone,
                                              petitionType: "C2CED",
                                              operationId: input.operationId,
                                              receiverUserId: input.receiverUserId,
                                              image: input.image,
                                              imageFormat: input.imageFormat?.rawValue,
                                              text: input.text)
        return try dataSource.sendImageText(params: params)
    }
    
    public func sendImageText(_ input: BizumSendMultimediaInputParams) throws -> BSANResponse<BizumTransferInfoDTO> {
        let dataSource = BizumMultimediaDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: self.bsanDataProvider)
        let userData = try self.bsanDataProvider.getUserData()
        let params = BizumSendImageTextParams(
            cmc: userData.getCMC,
            language: self.language,
            emitterUserId: input.checkPayment.phone.trim(),
            petitionType: input.operationType.rawValue,
            operationId: input.operationId,
            receiverUserId: input.receiverUserId,
            image: input.image,
            imageFormat: input.imageFormat?.rawValue,
            text: input.text
        )
        return try dataSource.sendImageText(params: params)
    }
    
    public func sendImageTextMulti(_ input : BizumSendImageTextMultiInputParams) throws -> BSANResponse<BizumTransferInfoDTO> {
        let dataSource = BizumMultimediaDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: self.bsanDataProvider)
        let userData = try self.bsanDataProvider.getUserData()
        let params = BizumSendImageTextMultiParams(cmc: userData.getCMC,
                                                   language: self.language,
                                                   emitterUserId: input.emmiterUserId,
                                                   petitionType: input.operationType.rawValue,
                                                   multiOperationId: input.multiOperationId,
                                                   operationReceiverList: input.operationReceiverList.map({
                                                    return BizumMultimediaReceiverParam(receiverUserId: $0.receiverUserId,
                                                                                        operationId: $0.operationId)
                                                   }),
                                                   image: input.image,
                                                   imageFormat: input.imageFormat?.rawValue,
                                                   text: input.text)
        return try dataSource.sendImageTextMulti(params: params)
    }
    
    // MARK: - Money Request
    public func validateMoneyRequest(_ input : BizumValidateMoneyRequestInputParams) throws -> BSANResponse<BizumValidateMoneyRequestDTO> {
        let dataSource = BizumDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: self.bsanDataProvider)
        let userData = try self.bsanDataProvider.getUserData()
        let bizumCheckPaymentDTO = input.checkPayment
        let dateTime = DateFormats.toString(date: input.dateTime, output: DateFormats.TimeFormat.YYYYMMDD_HHmmssSSS)
        let params = BizumValidateMoneyRequestParams(cmc: userData.getCMC,
                                                     language: language,
                                                     dateTime: dateTime,
                                                     concept: input.concept,
                                                     amount: input.amount,
                                                     emitterLanguage: "spa",
                                                     emitterAlias: "",
                                                     emitterName: "",
                                                     emitterUserId: bizumCheckPaymentDTO.phone.trim(),
                                                     receiverUserId: input.receiverUserId,
                                                     emitterVirtualElement: bizumCheckPaymentDTO.xpan?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
                                                     emitterDocumentType: input.document.document.type,
                                                     emitterDocumentCode: input.document.document.code,
                                                     emitterIban: bizumCheckPaymentDTO.ibanCode.description,
                                                     emitterIbanCurrency: "EUR")
        return try dataSource.validateMoneyRequest(params)
    }
    
    public func moneyRequest(_ input : BizumMoneyRequestInputParams) throws -> BSANResponse<BizumMoneyRequestDTO> {
        let dataSource = BizumDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: self.bsanDataProvider)
        let userData = try self.bsanDataProvider.getUserData()
        let bizumCheckPaymentDTO = input.checkPayment
        let dateTime = DateFormats.toString(date: input.dateTime, output: DateFormats.TimeFormat.YYYYMMDD_HHmmssSSS)
        let params = BizumMoneyRequestParams(operationId: input.operationId,
                                             transactionId: "",
                                             state: "VALIDADA",
                                             cmc: userData.getCMC,
                                             language: language,
                                             dateTime: dateTime,
                                             concept: input.concept,
                                             amount: input.amount,
                                             emitterLanguage: "spa",
                                             emitterAlias: "",
                                             emitterName: "",
                                             emitterUserId: bizumCheckPaymentDTO.phone.trim(),
                                             receiverUserId: input.receiverUserId,
                                             emitterVirtualElement: bizumCheckPaymentDTO.xpan?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
                                             emitterDocumentType: input.document.document.type,
                                             emitterDocumentCode: input.document.document.code,
                                             emitterIban: bizumCheckPaymentDTO.ibanCode.description,
                                             emitterIbanCurrency: "EUR")
        return try dataSource.moneyRequest(params)
    }
    
    public func validateMoneyRequestMulti(_ input : BizumValidateMoneyRequestMultiInputParams) throws -> BSANResponse<BizumValidateMoneyRequestMultiDTO> {
        let dataSource = BizumDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: self.bsanDataProvider)
        let userData = try self.bsanDataProvider.getUserData()
        let bizumCheckPaymentDTO = input.checkPayment
        let dateTime = DateFormats.toString(date: input.dateTime, output: DateFormats.TimeFormat.YYYYMMDD_HHmmssSSS)
        let params = BizumValidateMoneyRequestMultiParams(cmc: userData.getCMC,
                                                          language: language,
                                                          dateTime: dateTime,
                                                          concept: input.concept,
                                                          amount: input.amount,
                                                          emitterLanguage: "spa",
                                                          emitterAlias: "",
                                                          emitterName: "",
                                                          emitterVirtualElement: bizumCheckPaymentDTO.xpan?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
                                                          emitterDocumentType: input.document.document.type,
                                                          emitterDocumentCode: input.document.document.code,
                                                          emitterIban: bizumCheckPaymentDTO.ibanCode.description,
                                                          emitterIbanCurrency: "EUR",
                                                          emitterUserId: bizumCheckPaymentDTO.phone.trim(),
                                                          receiverUserIds: input.receiverUserIds)
        return try dataSource.validateMoneyRequestMulti(params)
    }
    
    public func moneyRequestMulti(_ input : BizumMoneyRequestMultiInputParams) throws -> BSANResponse<BizumMoneyRequestMultiDTO> {
        let dataSource = BizumDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: self.bsanDataProvider)
        let userData = try self.bsanDataProvider.getUserData()
        let bizumCheckPaymentDTO = input.checkPayment
        let dateTime = DateFormats.toString(date: input.dateTime, output: DateFormats.TimeFormat.YYYYMMDD_HHmmssSSS)
        let actions: [BizumMoneyRequestMultiActionParam] = input.actions.map {
            BizumMoneyRequestMultiActionParam(operationId: $0.operationId,
                                              receiverUserId: $0.receiverUserId,
                                              action: $0.action)
        }
        let params = BizumMoneyRequestMultiParams(cmc: userData.getCMC,
                                                  language: language,
                                                  dateTime: dateTime,
                                                  concept: input.concept,
                                                  amount: input.amount,
                                                  emitterLanguage: "spa",
                                                  emitterAlias: "",
                                                  emitterName: "",
                                                  emitterVirtualElement: bizumCheckPaymentDTO.xpan?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
                                                  emitterDocumentType: input.document.document.type,
                                                  emitterDocumentCode: input.document.document.code,
                                                  emitterIban: bizumCheckPaymentDTO.ibanCode.description,
                                                  emitterIbanCurrency: "EUR",
                                                  emitterUserId: bizumCheckPaymentDTO.phone.trim(),
                                                  operationId: input.operationId,
                                                  actions: actions)
        return try dataSource.moneyRequestMulti(params)
    }
    
    public func cancelPendingTransfer(_ input : BizumCancelNotRegisterInputParam) throws -> BSANResponse<BizumResponseInfoDTO> {
        let dataSource = BizumDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: self.bsanDataProvider)
        let userData = try self.bsanDataProvider.getUserData()
        let checkPayment = input.checkPayment
        let operation = input.operation
        let dateTime = DateFormats.toString(date: input.dateTime, output: DateFormats.TimeFormat.YYYYMMDD_HHmmssSSS)
        let params = BizumCancelNotRegisterParam(
            operationId: operation.operationId ?? "",
            state: operation.state ?? "",
            cmc: userData.getCMC, dateTime: dateTime,
            concept: operation.concept ?? "",
            amount: AmountFormats.formattedAmountForWS(amount: Decimal(operation.amount ?? 0.0)),
            emitterAlias: operation.emitterAlias ?? "",
            emitterName: operation.emitterAlias ?? "",
            emitterUserId: operation.emitterId ?? "",
            receiverUserId: operation.receptorId ?? "",
            emitterVirtualElement: checkPayment.xpan?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            emitterDocumentType: input.document.document.type,
            emitterDocumentCode: input.document.document.code,
            emitterIban: input.checkPayment.ibanCode.description,
            emitterIbanCurrency: "EUR")
        
        return try dataSource.cancelPendingTransfer(params)
    }
    
    public func refundMoneyRequest(_ input: BizumRefundMoneyRequestInputParams) throws -> BSANResponse<BizumRefundMoneyResponseDTO> {
        let dataSource = BizumDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: self.bsanDataProvider)
        let userData = try self.bsanDataProvider.getUserData()
        let bizumCheckPaymentDTO = input.checkPayment
        let dateTime = DateFormats.toString(date: input.dateTime, output: DateFormats.TimeFormat.YYYYMMDD_HHmmssSSS)
        let xpan = bizumCheckPaymentDTO.xpan?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let params = BizumRefundMoneyRequestParams(
            securityToken: input.otpValidationDTO?.magicPhrase ?? "",
            otpTicket: input.otpValidationDTO?.ticket ?? "",
            otpCode: input.otpCode,
            operationId: input.operationId,
            transactionId: input.transactionId,
            state: "ACEPTADA",
            cmc: userData.getCMC,
            language: language,
            dateTime: dateTime,
            concept: input.concept,
            amount: AmountFormats.formattedAmountForWS(amount: input.amount),
            emitterLanguage: "spa",
            emitterAlias: "",
            emitterName: "",
            emitterUserId: bizumCheckPaymentDTO.phone.trim(),
            emitterVirtualElement: xpan,
            emitterDocumentType: input.document.document.type,
            emitterDocumentCode: input.document.document.code,
            emitterIban: bizumCheckPaymentDTO.ibanCode.description,
            emitterIbanCurrency: "EUR",
            receiverUserId: input.receiverUserId
        )
        return try dataSource.refundMoneyRequest(params)
    }
    
    public func getOrganizations(_ input: BizumGetOrganizationsInputParams) throws -> BSANResponse<BizumOrganizationsListDTO> {
        let userData = try self.bsanDataProvider.getUserData()
        let params = BizumGetOrganizationsParams(
            language: self.language,
            cmc: userData.getCMC,
            userType: "ONG",
            mode: "A",
            elements: 20,
            pageNumber: input.pageNumber
        )
        let key = params.uniqueKey
        if let organizationsList = try bsanDataProvider.get(\.bizumInfo).bizumOrganizationsDictionary[key] {
            return BSANOkResponse(organizationsList)
        } else {
            let dataSource = BizumDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: self.bsanDataProvider)
            let response = try dataSource.getOrganizations(params)
            if response.isSuccess(), let data = try response.getResponseData() {
                self.bsanDataProvider.storeBizumOrganizationList(operationList: data, key: key)
            }
            return response
        }
    }
    
    public func getRedsysUserDocument(input: BizumGetRedsysDocumentInputParams) throws -> BSANResponse<BizumRedsysDocumentDTO> {
        let userData = try self.bsanDataProvider.getUserData()
        let headers = try self.bsanDataProvider.getBsanHeaderData()
        if let document = try self.bsanDataProvider.get(\.bizumInfo).redsysDocument {
            return BSANOkResponse(document)
        } else {
            let dataSource = BizumDataSource(sanRestServices: self.sanRestServices, bsanDataProvider: self.bsanDataProvider)
            let response = try dataSource.getRedsysDocument(
                input: BizumGetRedsysDocumentParams(
                    cmc: userData.getCMC,
                    language: " " + headers.language,
                    phoneNumber: input.phoneNumber
                )
            )
            guard let data = try? response.getResponseData() else { return response }
            self.bsanDataProvider.storeBizumRedsysDocument(data)
            return response
        }
    }
}
