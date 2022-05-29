import CoreDomain
import Foundation
import SANLegacyLibrary
import CoreFoundationLib

public class BSANCardsManagerImplementation: BSANBaseManager, BSANCardsManager {

    private let maxTries = 25
    private let superSpeedCardTriesMaxTries = 10
    private var superSpeedCardTries = 0
    private let sanSoapServices: SanSoapServices
    private let sanRestServices: SanRestServices

    public init(bsanDataProvider: BSANDataProvider, sanSoapServices: SanSoapServices, sanRestServices: SanRestServices) {
        self.sanSoapServices = sanSoapServices
        self.sanRestServices = sanRestServices
        super.init(bsanDataProvider: bsanDataProvider)
    }
    
    public func getCardTransactionLocation(card: CardDTO, transaction: CardTransactionDTO, transactionDetail: CardTransactionDetailDTO) throws -> BSANResponse<CardMovementLocationDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let dataSource = CardMovementLocationDataSource(sanRestServices: sanRestServices, bsanEnvironment: bsanEnvironment)
        guard let pan = card.formattedPAN,
            let operationDate = transaction.operationDate,
            let value = transaction.amount?.value,
            let transactionTime =  transactionDetail.transactionTime,
            let transactionTimeDate =  DateFormats.toDate(string: transactionTime, output: DateFormats.TimeFormat.HHmmssZ) else {
            return BSANErrorResponse(nil)
        }
        let formatter = NumberFormatter()
        guard let amount = formatter.withSeparator(decimals: 2).string(from: abs(value) as NSNumber) else {
            return BSANErrorResponse(nil)
        }
        let concept = transaction.description ?? ""
        let dateWithouthTime = DateFormats.toString(date: operationDate, output: DateFormats.TimeFormat.YYYYMMDD)
        let dateWithOnlyTime = DateFormats.toString(date: transactionTimeDate, output: DateFormats.TimeFormat.HHmmss)
        let date = dateWithouthTime + " " + dateWithOnlyTime
        return try dataSource.loadCardMovementLocation(params: CardMovementLocationParams(pan: pan, amount: amount, date: date, concept: concept))
    }
    
    public func getCardTransactionLocationsList(card: CardDTO) throws -> BSANResponse<CardMovementLocationListDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let dataSource = CardMovementLocationDataSource(sanRestServices: sanRestServices, bsanEnvironment: bsanEnvironment)
        guard let pan = card.formattedPAN else {
            return BSANErrorResponse(nil)
        }
        return try dataSource.loadCardMovementListLocations(params: CardMovementListLocationsParams(pan: pan, transactions: "24"))
    }
    
    public func getCardTransactionLocationsListByDate(card: CardDTO, startDate: Date, endDate: Date) throws -> BSANResponse<CardMovementLocationListDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let dataSource = CardMovementLocationDataSource(sanRestServices: sanRestServices, bsanEnvironment: bsanEnvironment)
        guard let pan = card.formattedPAN else {
            return BSANErrorResponse(Meta.createKO())
        }
        let startDateString = DateFormats.toString(date: startDate, output: DateFormats.TimeFormat.YYYYMMDD_HHmmss)
        let endDateString = DateFormats.toString(date: endDate, output: DateFormats.TimeFormat.YYYYMMDD_HHmmss)
        let params = CardMovementLocationsByDateParams(pan: pan, startDate: startDateString, endDate: endDateString)
        let request = try dataSource.loadCardMovementLocationsByDate(params: params)
        return request
    }

    public func getAllCards() throws -> BSANResponse<[CardDTO]> {
        let cardDTOs = try bsanDataProvider.get(\.globalPositionDTO).cards
        return BSANOkResponse(cardDTOs)
    }

    public func getCardsDataMap() throws -> BSANResponse<[String: CardDataDTO]> {
        let cardsDataMap = try bsanDataProvider.get(\.cardInfo).cardsData
        return BSANOkResponse(cardsDataMap)
    }

    public func getPrepaidsCardsDataMap() throws -> BSANResponse<[String: PrepaidCardDataDTO]> {
        let prepaidCardsMap = try bsanDataProvider.get(\.cardInfo).prepaidCards
        return BSANOkResponse(prepaidCardsMap)
    }

    public func getCardsDetailMap() throws -> BSANResponse<[String: CardDetailDTO]> {
        let cardsDetailMap = try bsanDataProvider.get(\.cardInfo).cardsWithDetail
        return BSANOkResponse(cardsDetailMap)
    }

    public func getCardsWithDetailMap() throws -> BSANResponse<[String: CardDetailDTO]> {
        let cardsWithDetailMap = try bsanDataProvider.get(\.cardInfo).cardsWithDetail
        return BSANOkResponse(cardsWithDetailMap)
    }

    public func getCardsBalancesMap() throws -> BSANResponse<[String: CardBalanceDTO]> {
        let cardBalances = try bsanDataProvider.get(\.cardInfo).cardBalances
        return BSANOkResponse(cardBalances)
    }

    public func getTemporallyInactiveCardsMap() throws -> BSANResponse<[String: InactiveCardDTO]> {
        let cardsWithDetailMap = try bsanDataProvider.get(\.cardInfo).temporallyOffCards
        return BSANOkResponse(cardsWithDetailMap)
    }

    public func getInactiveCardsMap() throws -> BSANResponse<[String: InactiveCardDTO]> {
        let cardsWithDetailMap = try bsanDataProvider.get(\.cardInfo).inactiveCards
        return BSANOkResponse(cardsWithDetailMap)
    }
    
    private func setCardsData(_ cardDataDTOList: [CardDataDTO]) {
        bsanDataProvider.storeCardData(cardDataDTOList: cardDataDTOList)
    }

    public func getCardData(_ pan: String) throws -> BSANResponse<CardDataDTO> {
        let cardDataDTO = try bsanDataProvider.get(\.cardInfo).getCardData(pan)
        return BSANOkResponse(cardDataDTO)
    }

    //TODO: ESTO SE ELIMINARA CUANDO SE USE UNICAMENTE EL SERVICIO SUPERSPEEDCARDS
    public func loadAllCardsData() throws -> BSANResponse<Void> {
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()

        var cardDTOsSet = Set<CardDataDTO>()

        let request = GetCardDataRequest(
                BSANAssembleProvider.getCardDataAssemble(),
                try bsanDataProvider.getEnvironment().urlBase,
                GetCardDataRequestParams
                        .createParams(authCredentials.soapTokenCredential)
                        .setUserDataDTO(userDataDTO)
                        .setLinkedCompany(bsanHeaderData.linkedCompany)
                        .setLanguage(bsanHeaderData.language)
                        .setIndicadorRepo(CardDataIndicator.firstPage.type))

        var response = try sanSoapServices.executeCall(request);
        let meta = try Meta.createMeta(request, response)
        if (meta.isOK()) {
            var tries: Int = 1

            if let cardDataList = response.cardDataDTOs {
                cardDataList.forEach {
                    cardDTOsSet.insert($0)
                }
            }

            if cardDTOsSet.isEmpty {
                tries = maxTries + 1
            }

            var totalLastRequest = cardDTOsSet.count

            for tries in 0 ..< maxTries where
                response.reposDatosTarjeta != nil
                && response.reposDatosTarjeta?.finLista == false {

                BSANLogger.d(logTag, "tries: \(tries)")

                let newRequest = GetCardDataRequest(
                        BSANAssembleProvider.getCardDataAssemble(),
                        try bsanDataProvider.getEnvironment().urlBase,
                        GetCardDataRequestParams
                                .createParams(authCredentials.soapTokenCredential)
                                .setUserDataDTO(userDataDTO)
                                .setLinkedCompany(bsanHeaderData.linkedCompany)
                                .setLanguage(bsanHeaderData.language)
                                .setIndicadorRepo(CardDataIndicator.otherPages.type)
                                .setReposDatosTarjeta(response.reposDatosTarjeta))

                response = try sanSoapServices.executeCall(newRequest);

                let meta = try Meta.createMeta(newRequest, response)
                if (meta.isOK()) {
                    if let cardDataList = response.cardDataDTOs {
                        cardDataList.forEach {
                            cardDTOsSet.insert($0)
                        }
                    }

                    if !cardDTOsSet.isEmpty || cardDTOsSet.count != totalLastRequest {
                        totalLastRequest = cardDTOsSet.count
                    }
                }
            }
            setCardsData(Array(cardDTOsSet))
            return BSANOkEmptyResponse()
        }
        return BSANErrorResponse(meta);
    }

    public func getTemporallyOffCard(pan: String) throws -> BSANResponse<InactiveCardDTO> {
        let temporallyOffCard = try bsanDataProvider.get(\.cardInfo).getTemporallyOffCard(pan)
        return BSANOkResponse(temporallyOffCard)
    }

    public func getInactiveCard(pan: String) throws -> BSANResponse<InactiveCardDTO> {
        let inactiveCard = try bsanDataProvider.get(\.cardInfo).getInactiveCard(pan)
        return BSANOkResponse(inactiveCard)
    }

    public func loadCardDetail(cardDTO: CardDTO) throws -> BSANResponse<Void> {
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let isPb = try bsanDataProvider.isPB()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        guard let pan = cardDTO.PAN else {
            return BSANErrorResponse(nil)
        }
        let request = LoadCardDetailRequest(
                BSANAssembleProvider.getCardsAssemble(isPb),
                try bsanDataProvider.getEnvironment().urlBase,
                LoadCardDetailRequestParams.createParams(authCredentials.soapTokenCredential)
                        .setUserDataDTO(userDataDTO)
                        .setVersion(bsanHeaderData.version)
                        .setTerminalId(bsanHeaderData.terminalID)
                        .setCardPAN(pan)
                        .setLanguage(bsanHeaderData.language))

        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK")
            if let cardDetail = response.cardDetailDTO, let PAN = cardDTO.formattedPAN {
                bsanDataProvider.storeCardDetail(PAN: PAN, cardDetailDTO: cardDetail)

                let superSpeedCard = CardBalanceDTO.create(from: cardDetail)
                var cardBalancesDictionary = [String: CardBalanceDTO]()
                cardBalancesDictionary[PAN] = superSpeedCard
                bsanDataProvider.storeCardBalances(dictionaryPANBalances: cardBalancesDictionary)
            }
            return BSANOkResponse(meta)
        }
        return BSANErrorResponse(meta)
    }

    public func getCardDetail(cardDTO: CardDTO) throws -> BSANResponse<CardDetailDTO> {
        guard let PAN = cardDTO.formattedPAN else {
            return BSANErrorResponse(Meta.createKO())
        }
        
        if let cardDetailStrong = try bsanDataProvider.get(\.cardInfo).getCardDetail(PAN) {
            return BSANOkResponse(cardDetailStrong)
        }
        
        let response = try loadCardDetail(cardDTO: cardDTO)
        if response.isSuccess() {
            let cardDetailDTO = try bsanDataProvider.get(\.cardInfo).getCardDetail(PAN)
            return BSANOkResponse(cardDetailDTO)
        }
        guard let error = try response.getErrorMessage() else {
            return BSANErrorResponse(Meta.createKO())
        }
        return BSANErrorResponse(Meta.createKO(error))
    }

    public func getCardBalance(cardDTO: CardDTO) throws -> BSANResponse<CardBalanceDTO> {

        if let PAN = cardDTO.formattedPAN {
            let cardBalanceDTO = try bsanDataProvider.get(\.cardInfo).getCardBalance(PAN)
            if let cardBalanceStrong = cardBalanceDTO {
                return BSANOkResponse(cardBalanceStrong)
            }
        }
        return BSANErrorResponse(Meta.createKO())
    }

    public func confirmPayOff(cardDTO: CardDTO, cardDetailDTO: CardDetailDTO, amountDTO: AmountDTO, signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<Void> {

        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()

        let request = ConfirmPayOffCardRequest(
                BSANAssembleProvider.getCardsPayOffAssemble(),
                try bsanDataProvider.getEnvironment().urlBase,
                ConfirmPayOffCardRequestParams(token: authCredentials.soapTokenCredential,
                        userDataDTO: userDataDTO,
                        languageISO: bsanHeaderData.languageISO,
                        dialectISO: bsanHeaderData.dialectISO,
                        linkedCompany: bsanHeaderData.linkedCompany,
                        cardDTO: cardDTO,
                        linkedAccountContract: cardDetailDTO.linkedAccountOldContract,
                        amountDTO: amountDTO,
                        signatureWithTokenDTO: signatureWithTokenDTO))

        let response = try sanSoapServices.executeCall(request);

        let meta = try Meta.createMeta(request, response);
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta)
        }
        return BSANErrorResponse(meta)
    }

    public func loadPrepaidCardData(cardDTO: CardDTO) throws -> BSANResponse<Void> {
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()

        let request = RecoverPrepaidCardDataRequest(
                BSANAssembleProvider.getCardsPrepaidAssemble(),
                try bsanDataProvider.getEnvironment().urlBase,
                RecoverPrepaidCardDataRequestParams.createParams(authCredentials.soapTokenCredential)
                        .setUserDataDTO(userDataDTO)
                        .setLanguageISO(bsanHeaderData.languageISO)
                        .setDialectISO(bsanHeaderData.dialectISO)
                        .setLinkedCompany(bsanHeaderData.linkedCompany)
                        .setCardDTO(cardDTO)
        )

        let response = try sanSoapServices.executeCall(request);

        let meta = try Meta.createMeta(request, response);
        if (meta.isOK()) {
            if let prepaidCardDTO = response.prepaidCardDTO, let pan = cardDTO.PAN {
                 bsanDataProvider.storePrepaidCard(pan, prepaidCardDTO)
                let superSpeedCard = CardBalanceDTO.create(from: prepaidCardDTO)
                let cardBalancesDictionary: [String: CardBalanceDTO] = [pan: superSpeedCard]
                bsanDataProvider.storeCardBalances(dictionaryPANBalances: cardBalancesDictionary)
            }
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta)
        }
        return BSANErrorResponse(meta)
    }

    public func getPrepaidCardData(cardDTO: CardDTO) throws -> BSANResponse<PrepaidCardDataDTO> {
        guard let PAN = cardDTO.formattedPAN else {
            return BSANErrorResponse(Meta.createKO())
        }
        
        let prepaidCardData = try bsanDataProvider.get(\.cardInfo).getPrepaidCardData(PAN)
        if let prepaidCardDataStrong = prepaidCardData {
            return BSANOkResponse(prepaidCardDataStrong)
        }
        
        let response = try loadPrepaidCardData(cardDTO: cardDTO)
        
        let prepaidCardDataAfterLoad = try bsanDataProvider.get(\.cardInfo).getPrepaidCardData(PAN)
        if let prepaidCardDataStrong = prepaidCardDataAfterLoad {
            return BSANOkResponse(prepaidCardDataStrong)
        }
        
        return BSANErrorResponse(Meta.createKO(try response.getErrorMessage() ?? ""))
    }

    public func validateLoadPrepaidCard(cardDTO: CardDTO, amountDTO: AmountDTO, accountDTO: AccountDTO, prepaidCardDataDTO: PrepaidCardDataDTO) throws -> BSANResponse<ValidateLoadPrepaidCardDTO> {

        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()

        let request = ValidateLoadPrepaidCardRequest(
                BSANAssembleProvider.getCardsPrepaidAssemble(), // same assemble for all
                try bsanDataProvider.getEnvironment().urlBase,
                ValidateLoadPrepaidCardRequestParams(token: authCredentials.soapTokenCredential,
                        userDataDTO: userDataDTO,
                        languageISO: bsanHeaderData.languageISO,
                        dialectISO: bsanHeaderData.dialectISO,
                        linkedCompany: bsanHeaderData.linkedCompany,
                        cardDTO: cardDTO,
                        amountDTO: amountDTO,
                        accountDTO: accountDTO,
                        prepaidCardDataDTO: prepaidCardDataDTO))

        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");

            return BSANOkResponse(response.validateLoadPrepaidCardDTO)
        }
        return BSANErrorResponse(meta)
    }

    public func confirmOTPLoadPrepaidCard(cardDTO: CardDTO, amountDTO: AmountDTO, accountDTO: AccountDTO,
                                          prepaidCardDataDTO: PrepaidCardDataDTO,
                                          validateLoadPrepaidCardDTO: ValidateLoadPrepaidCardDTO,
                                          otpValidationDTO: OTPValidationDTO?,
                                          otpCode: String?) throws -> BSANResponse<Void> {

        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()

        let request = ConfirmOTPLoadPrepaidCardRequest(
                BSANAssembleProvider.getCardsPrepaidAssemble(),
                try bsanDataProvider.getEnvironment().urlBase,
                ConfirmOTPLoadPrepaidCardRequestParams(token: authCredentials.soapTokenCredential,
                        userDataDTO: userDataDTO,
                        languageISO: bsanHeaderData.languageISO,
                        dialectISO: bsanHeaderData.dialectISO,
                        linkedCompany: bsanHeaderData.linkedCompany,
                        cardDTO: cardDTO,
                        amountDTO: amountDTO,
                        accountDTO: accountDTO,
                        prepaidCardDataDTO: prepaidCardDataDTO,
                        validateLoadPrepaidCardDTO: validateLoadPrepaidCardDTO,
                        otpTicket: otpValidationDTO?.ticket ?? "",
                        otpToken: otpValidationDTO?.magicPhrase ?? "",
                        otpCode: otpCode ?? ""))

        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");

            return BSANOkResponse(meta)
        }
        return BSANErrorResponse(meta)
    }

    public func validateUnloadPrepaidCard(cardDTO: CardDTO, amountDTO: AmountDTO, accountDTO: AccountDTO, prepaidCardDataDTO: PrepaidCardDataDTO) throws -> BSANResponse<ValidateLoadPrepaidCardDTO> {

        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()

        let request = ValidateUnloadPrepaidCardRequest(
                BSANAssembleProvider.getCardsPrepaidAssemble(),
                try bsanDataProvider.getEnvironment().urlBase,
                ValidateUnloadPrepaidCardRequestParams(token: authCredentials.soapTokenCredential,
                        userDataDTO: userDataDTO,
                        languageISO: bsanHeaderData.languageISO,
                        dialectISO: bsanHeaderData.dialectISO,
                        linkedCompany: bsanHeaderData.linkedCompany,
                        cardDTO: cardDTO,
                        amountDTO: amountDTO,
                        accountDTO: accountDTO,
                        prepaidCardDataDTO: prepaidCardDataDTO))

        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");

            return BSANOkResponse(response.validateLoadPrepaidCardDTO)
        }
        return BSANErrorResponse(meta)
    }

    public func confirmOTPUnloadPrepaidCard(cardDTO: CardDTO,
                                            amountDTO: AmountDTO,
                                            accountDTO: AccountDTO,
                                            prepaidCardDataDTO: PrepaidCardDataDTO,
                                            validateLoadPrepaidCardDTO: ValidateLoadPrepaidCardDTO,
                                            otpValidationDTO: OTPValidationDTO?,
                                            otpCode: String?) throws -> BSANResponse<Void> {

        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()

        let request = ConfirmOTPUnloadPrepaidCardRequest(
                BSANAssembleProvider.getCardsPrepaidAssemble(),
                try bsanDataProvider.getEnvironment().urlBase,
                ConfirmOTPUnloadPrepaidCardRequestParams(token: authCredentials.soapTokenCredential,
                        userDataDTO: userDataDTO,
                        languageISO: bsanHeaderData.languageISO,
                        dialectISO: bsanHeaderData.dialectISO,
                        linkedCompany: bsanHeaderData.linkedCompany,
                        cardDTO: cardDTO,
                        amountDTO: amountDTO,
                        accountDTO: accountDTO,
                        prepaidCardDataDTO: prepaidCardDataDTO,
                        validateLoadPrepaidCardDTO: validateLoadPrepaidCardDTO,
                        otpTicket: otpValidationDTO?.ticket ?? "",
                        otpToken: otpValidationDTO?.magicPhrase ?? "",
                        otpCode: otpCode ?? ""))

        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");

            return BSANOkResponse(meta)
        }
        return BSANErrorResponse(meta)
    }

    public func validateOTPPrepaidCard(cardDTO: CardDTO, signatureDTO: SignatureDTO, validateLoadPrepaidCardDTO: ValidateLoadPrepaidCardDTO) throws -> BSANResponse<OTPValidationDTO> {

        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()

        let request = ValidateOTPPrepaidCardRequest(
                BSANAssembleProvider.getCardsPrepaidAssemble(),
                try bsanDataProvider.getEnvironment().urlBase,
                ValidateOTPPrepaidCardRequestParams(token: authCredentials.soapTokenCredential,
                        userDataDTO: userDataDTO,
                        languageISO: bsanHeaderData.languageISO,
                        dialectISO: bsanHeaderData.dialectISO,
                        linkedCompany: bsanHeaderData.linkedCompany,
                        cardDTO: cardDTO,
                        signatureDTO: signatureDTO,
                        validateLoadPrepaidCardDTO: validateLoadPrepaidCardDTO))

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

    public func getCardDetailToken(cardDTO: CardDTO, cardTokenType: CardTokenType) throws -> BSANResponse<CardDetailTokenDTO> {

        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()

        let request = GetCardDetailTokenRequest(
                try BSANAssembleProvider.getCardsAssemble(bsanDataProvider.isPB()), // same assemble for all
                try bsanDataProvider.getEnvironment().urlBase,
                GetCardDetailTokenRequestParams(token: authCredentials.soapTokenCredential,
                        version: bsanHeaderData.version,
                        terminalId: bsanHeaderData.terminalID,
                        userDataDTO: userDataDTO,
                        language: bsanHeaderData.language,
                        cardPAN: cardDTO.PAN ?? "",
                        cardTokenType: cardTokenType))

        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");

            return BSANOkResponse(response.cardDetailTokenDTO)
        }
        return BSANErrorResponse(meta)
    }

    public func getAllCardTransactions(cardDTO: CardDTO, pagination: PaginationDTO?, searchTerm: String?, dateFilter: DateFilter?, fromAmount: Decimal?, toAmount: Decimal?, movementType: String?, cardOperationType: String?) throws -> BSANResponse<CardTransactionsListDTO> {
        var response = try getCardTransactions(cardDTO: cardDTO, pagination: pagination, dateFilter: dateFilter)
        while response.isSuccess(), let cardTransactions = try response.getResponseData(), !cardTransactions.pagination.endList {
            response = try getCardTransactions(cardDTO: cardDTO, pagination: cardTransactions.pagination, dateFilter: dateFilter)
        }
        return try getCardTransactions(cardDTO: cardDTO, pagination: pagination, dateFilter: dateFilter)
    }

    public func getCardTransactions(cardDTO: CardDTO, pagination: PaginationDTO?, dateFilter: DateFilter?) throws -> BSANResponse<CardTransactionsListDTO> {
        try getCardTransactions(cardDTO: cardDTO, pagination: pagination, dateFilter: dateFilter, cached: true)
    }

    
    public func getCardTransactions(cardDTO: CardDTO, pagination: PaginationDTO?, dateFilter: DateFilter?, cached: Bool) throws -> BSANResponse<CardTransactionsListDTO> {

        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let dateFilterToUse: DateFilter
        if let dateFilter = dateFilter {
            dateFilterToUse = dateFilter
        } else {
            dateFilterToUse = DateFilter.getDateFilterFor(numberOfYears: -1)
        }

        guard var contractString = cardDTO.formattedPAN else {
            throw BSANIllegalStateException("Malformed card contract")
        }
        contractString += dateFilterToUse.string
        
        let cardTransactionList = try bsanDataProvider.get(\.cardInfo).cardTransactionsDictionary[contractString]

        if let cardTransactionList = cardTransactionList {
            if pagination != nil {
                if cardTransactionList.pagination.endList {
                    return BSANOkResponse(cardTransactionList)
                }
            } else {
                return BSANOkResponse(cardTransactionList)
            }
        }

        let request = GetCardTransactionsRequest(
                BSANAssembleProvider.getCardsAssemble(false), // same assemble for all
                try bsanDataProvider.getEnvironment().urlBase,
                GetCardTransactionsRequestParams(token: authCredentials.soapTokenCredential,
                        userDataDTO: userDataDTO,
                        bankCode: cardDTO.contract?.bankCode ?? "",
                        branchCode: cardDTO.contract?.branchCode ?? "",
                        product: cardDTO.contract?.product ?? "",
                        contractNumber: cardDTO.contract?.contractNumber ?? "",
                        cardPAN: cardDTO.PAN ?? "",
                        version: bsanHeaderData.version,
                        language: bsanHeaderData.language,
                        terminalId: bsanHeaderData.terminalID,
                        pagination: pagination,
                        dateFilter: dateFilterToUse))

        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");
            if cached {
                bsanDataProvider.store(cardTransactionsList: response.transactionList, forCardId: contractString)
            }
            return BSANOkResponse(response.transactionList)
        }
        let errorResponse: BSANResponse<CardTransactionsListDTO> = BSANErrorResponse(meta)
        // Workaround
        // Ñapa obligatoria, el servicio puede devolver como error algo que no lo es
        if BSANSoapResponse.RESULT_ERROR == response.errorCode, let errorDesc = response.errorDesc, errorDesc.lowercased().contains("no existen movimientos") {
            let pagination = PaginationDTO(repositionXML: "", accountAmountXML: "", endList: true)
            let transactionList = CardTransactionsListDTO(transactionDTOs: [], pagination: pagination)
            if cached {
                bsanDataProvider.store(cardTransactionsList: response.transactionList, forCardId: contractString)
            }
            return BSANOkResponse(transactionList)
        }
        return errorResponse
    }

    public func getCardTransactionDetail(cardDTO: CardDTO, cardTransactionDTO: CardTransactionDTO) throws -> BSANResponse<CardTransactionDetailDTO> {
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let operationDateString: String = {
            guard let operationDate = cardTransactionDTO.operationDate else { return "" }
            return DateFormats.toString(date: operationDate, output: DateFormats.TimeFormat.YYYYMMDD)
        }()
        let annotationDateString: String = {
            guard let annotationDate = cardTransactionDTO.annotationDate else { return "" }
            return DateFormats.toString(date: annotationDate, output: DateFormats.TimeFormat.YYYYMMDD)
        }()
        let transactionID = "\(operationDateString)\(cardTransactionDTO.transactionDay ?? "")\(cardTransactionDTO.amount?.description ?? "")"
        if let transaction = try bsanDataProvider.get(\.cardInfo.cardTransactionDetails)[transactionID] {
            return BSANOkResponse(transaction)
        }
        let request = GetCardTransactionDetailRequest(
            try BSANAssembleProvider.getCardsAssemble(bsanDataProvider.isPB()),
            try bsanDataProvider.getEnvironment().urlBase,
            GetCardTransactionDetailRequestParams(
                token: authCredentials.soapTokenCredential,
                version: bsanHeaderData.version,
                terminalId: bsanHeaderData.terminalID,
                userDataDTO: userDataDTO,
                language: bsanHeaderData.language,
                cardContractBankCode: cardDTO.contract?.bankCode ?? "",
                cardContractBranchCode: cardDTO.contract?.branchCode ?? "",
                cardContractProduct: cardDTO.contract?.product ?? "",
                cardContractNumber: cardDTO.contract?.contractNumber ?? "",
                transactionOperationDate: operationDateString,
                transactionBalanceCode: cardTransactionDTO.balanceCode ?? "",
                transactionAnnotationDate: annotationDateString,
                transactionTransactionDay: cardTransactionDTO.transactionDay ?? "",
                transactionCurrency: cardTransactionDTO.amount?.currency?.currencyName ?? ""
            )
        )
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        guard meta.isOK() else { return BSANErrorResponse(meta) }
        BSANLogger.i(logTag, "Meta OK")
        bsanDataProvider.store(cardTransactionDetail: response.cardTransactionDetailDTO, id: transactionID)
        return BSANOkResponse(response.cardTransactionDetailDTO)
    }
    
    public func loadInactiveCards(inactiveCardType: InactiveCardType) throws -> BSANResponse<Void> {
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()

        let request = LoadCardsInactiveRequest(
                BSANAssembleProvider.getCardsAssemble(false), // same assemble for all
                try bsanDataProvider.getEnvironment().urlBase,
                LoadCardsInactiveRequestParams.createParams(authCredentials.soapTokenCredential)
                        .setUserDataDTO(userDataDTO)
                        .setVersion(bsanHeaderData.version)
                        .setTerminalId(bsanHeaderData.terminalID)
                        .setLanguage(bsanHeaderData.language)
                        .setInactiveCardType(inactiveCardType))

        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");
            if let inactiveCards = response.inactiveCards {
                BSANLogger.i(logTag, "Store inactive cards");
                storeInactiveCards(inactiveCards, inactiveCardType);
            }
            return BSANOkResponse(meta)
        }
        return BSANErrorResponse(meta)
    }

    private func storeInactiveCards(_ inactiveCards: [InactiveCardDTO], _  inactiveCardType: InactiveCardType) {
        switch (inactiveCardType) {
        case InactiveCardType.inactive:
            bsanDataProvider.storeInactiveCards(inactiveCards: inactiveCards)
            break
        case InactiveCardType.temporallyOff:
            bsanDataProvider.storeTemporallyInactiveCards(temporallyInactiveCards: inactiveCards)
            break
        }
    }

    public func blockCard(cardDTO: CardDTO, blockText: String, cardBlockType: CardBlockType) throws -> BSANResponse<BlockCardDTO> {

        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()

        let request = BlockCardRequest(
                try BSANAssembleProvider.getCardsAssemble(bsanDataProvider.isPB()), // same assemble for all
                try bsanDataProvider.getEnvironment().urlBase,
                BlockCardRequestParams(token: authCredentials.soapTokenCredential,
                        userDataDTO: userDataDTO,
                        version: bsanHeaderData.version,
                        terminalId: bsanHeaderData.terminalID,
                        cardPAN: cardDTO.formattedPAN ?? "",
                        cardContractProduct: cardDTO.contract?.product ?? "",
                        cardContractNumber: cardDTO.contract?.contractNumber ?? "",
                        cardContractBranchCode: cardDTO.contract?.branchCode ?? "",
                        cardBankCode: cardDTO.contract?.bankCode ?? "",
                        language: bsanHeaderData.language,
                        blockText: blockText,
                        cardBlockType: cardBlockType))

        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");
            return BSANOkResponse(response.blockCardDTO)
        }
        return BSANErrorResponse(meta)
    }

    public func confirmBlockCard(cardDTO: CardDTO, signatureDTO: SignatureDTO, blockText: String, cardBlockType: CardBlockType) throws -> BSANResponse<BlockCardConfirmDTO> {

        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()

        let request = BlockCardConfirmationRequest(
                try BSANAssembleProvider.getCardsAssemble(bsanDataProvider.isPB()), // same assemble for all
                try bsanDataProvider.getEnvironment().urlBase,
                BlockCardConfirmationRequestParams(token: authCredentials.soapTokenCredential,
                        userDataDTO: userDataDTO,
                        version: bsanHeaderData.version,
                        terminalId: bsanHeaderData.terminalID,
                        cardPAN: cardDTO.formattedPAN ?? "",
                        cardContractProduct: cardDTO.contract?.product ?? "",
                        cardContractNumber: cardDTO.contract?.contractNumber ?? "",
                        cardContractBranchCode: cardDTO.contract?.branchCode ?? "",
                        cardBankCode: cardDTO.contract?.bankCode ?? "",
                        language: bsanHeaderData.language,
                        blockText: blockText,
                        cardBlockType: cardBlockType,
                        cardSignature: signatureDTO))

        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");
            return BSANOkResponse(meta, response.blockCardConfirmDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func onOffCard(cardDTO: CardDTO, option: CardBlockType) throws -> BSANResponse<Void> {
        return BSANErrorResponse(nil)
    }

    public func activateCard(cardDTO: CardDTO, expirationDate: Date) throws -> BSANResponse<ActivateCardDTO> {

        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()

        let request = ActivateCardRequest(
                try BSANAssembleProvider.getCardsAssemble(bsanDataProvider.isPB()), // same assemble for all
                try bsanDataProvider.getEnvironment().urlBase,
                ActivateCardRequestParams(token: authCredentials.soapTokenCredential,
                        version: bsanHeaderData.version,
                        terminalId: bsanHeaderData.terminalID,
                        userDataDTO: userDataDTO,
                        cardPAN: cardDTO.PAN ?? "",
                        cardContractProduct: cardDTO.contract?.product ?? "",
                        cardContractNumber: cardDTO.contract?.contractNumber ?? "",
                        cardContractBranchCode: cardDTO.contract?.branchCode ?? "",
                        cardBankCode: cardDTO.contract?.bankCode ?? "",
                        cardExpirationDate: expirationDate,
                        language: bsanHeaderData.language))

        let response = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");
            return BSANOkResponse(response.activateCardDTO)
        }
        return BSANErrorResponse(meta)
    }

    public func confirmActivateCard(cardDTO: CardDTO, expirationDate: Date, signatureDTO: SignatureDTO) throws -> BSANResponse<String> {

        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()

        let request = ActivateCardConfirmationRequest(
                try BSANAssembleProvider.getCardsAssemble(bsanDataProvider.isPB()), // same assemble for all
                try bsanDataProvider.getEnvironment().urlBase,
                ActivateCardConfirmationRequestParams(token: authCredentials.soapTokenCredential,
                        userDataDTO: userDataDTO,
                        version: bsanHeaderData.version,
                        terminalId: bsanHeaderData.terminalID,
                        cardPAN: cardDTO.PAN ?? "",
                        cardContractProduct: cardDTO.contract?.product ?? "",
                        cardContractNumber: cardDTO.contract?.contractNumber ?? "",
                        cardContractBranchCode: cardDTO.contract?.branchCode ?? "",
                        cardBankCode: cardDTO.contract?.bankCode ?? "",
                        cardExpirationDate: expirationDate,
                        cardSignature: signatureDTO,
                        language: bsanHeaderData.language))

        let response = try sanSoapServices.executeCall(request)
        // Workaround
        // Ñapa obligatoria, el servicio puede devolver como error algo que no lo es
        if BSANSoapResponse.RESULT_ERROR == response.errorCode, let errorDesc = response.errorDesc, errorDesc.lowercased().contains("transaccion ok") {
            response.errorCode = BSANSoapResponse.RESULT_OK
        }
        let meta = try Meta.createMeta(request, response)
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");
            // Segunda Ñapa obligatoria -> el mensaje de confirmación  que hay que mostrar viene en el campo <errorDesc>
            return BSANOkResponse(meta, response.errorDesc)
        }
        return BSANErrorResponse(meta)
    }

    public func prepareDirectMoney(cardDTO: CardDTO) throws -> BSANResponse<DirectMoneyDTO> {

        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()

        let request = DirectMoneyPrepareRequest(
                try BSANAssembleProvider.getCardsAssemble(bsanDataProvider.isPB()), // same assemble for all
                try bsanDataProvider.getEnvironment().urlBase,
                DirectMoneyPrepareRequestParams(token: authCredentials.soapTokenCredential,
                        version: bsanHeaderData.version,
                        terminalId: bsanHeaderData.terminalID,
                        userDataDTO: userDataDTO,
                        cardContractProduct: cardDTO.contract?.product ?? "",
                        cardContractNumber: cardDTO.contract?.contractNumber ?? "",
                        cardContractBranchCode: cardDTO.contract?.branchCode ?? "",
                        cardContractBankCode: cardDTO.contract?.bankCode ?? "",
                        language: bsanHeaderData.language))

        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");
            return BSANOkResponse(response.directMoneyDTO)
        }
        return BSANErrorResponse(meta)
    }

    public func validateDirectMoney(cardDTO: CardDTO, amountValidatedDTO: AmountDTO) throws -> BSANResponse<DirectMoneyValidatedDTO> {

        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()

        let request = DirectMoneyValidateRequest(
                try BSANAssembleProvider.getCardsAssemble(bsanDataProvider.isPB()), // same assemble for all
                try bsanDataProvider.getEnvironment().urlBase,
                DirectMoneyValidateRequestParams(token: authCredentials.soapTokenCredential,
                        version: bsanHeaderData.version,
                        terminalId: bsanHeaderData.terminalID,
                        userDataDTO: userDataDTO,
                        cardContractProduct: cardDTO.contract?.product ?? "",
                        cardContractNumber: cardDTO.contract?.contractNumber ?? "",
                        cardContractBranchCode: cardDTO.contract?.branchCode ?? "",
                        cardContractBankCode: cardDTO.contract?.bankCode ?? "",
                        language: bsanHeaderData.language,
                        directMoneyWholePart: amountValidatedDTO.wholePart,
                        directMoneyDecimalPart: amountValidatedDTO.getDecimalPart()))

        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");
            return BSANOkResponse(response.directMoneyValidatedDTO)
        }
        return BSANErrorResponse(meta)
    }

    public func confirmDirectMoney(cardDTO: CardDTO, amountValidatedDTO: AmountDTO, signatureDTO: SignatureDTO) throws -> BSANResponse<Void> {

        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()

        let request = DirectMoneyConfirmationRequest(
                try BSANAssembleProvider.getCardsAssemble(bsanDataProvider.isPB()), // same assemble for all
                try bsanDataProvider.getEnvironment().urlBase,
                DirectMoneyConfirmationRequestParams(token: authCredentials.soapTokenCredential,
                        version: bsanHeaderData.version,
                        terminalId: bsanHeaderData.terminalID,
                        userDataDTO: userDataDTO,
                        cardContractProduct: cardDTO.contract?.product ?? "",
                        cardContractNumber: cardDTO.contract?.contractNumber ?? "",
                        cardContractBranchCode: cardDTO.contract?.branchCode ?? "",
                        cardContractBankCode: cardDTO.contract?.bankCode ?? "",
                        language: bsanHeaderData.language,
                        directMoneyWholePart: amountValidatedDTO.wholePart,
                        directMoneyDecimalPart: amountValidatedDTO.getDecimalPart(),
                        signature: signatureDTO))

        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");
            return BSANOkResponse(meta)
        }
        return BSANErrorResponse(meta)
    }
    
    public func loadCardSuperSpeed(pagination: PaginationDTO?) throws -> BSANResponse<Void> {
        try loadCardSuperSpeed(pagination: pagination, isNegativeCreditBalanceEnabled: false)
    }
    
    public func loadCardSuperSpeed(pagination: PaginationDTO?, isNegativeCreditBalanceEnabled: Bool) throws -> BSANResponse<Void> {
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()

        let request = GetCardSuperSpeedRequest(
                BSANAssembleProvider.getCardDataAssemble(),
                try bsanDataProvider.getEnvironment().urlBase,
                GetCardSuperSpeedRequestParams(pagination: pagination,
                        languageISO: bsanHeaderData.languageISO,
                        dialectISO: bsanHeaderData.dialectISO,
                        linkedCompany: bsanHeaderData.linkedCompany,
                        token: authCredentials.soapTokenCredential,
                        userDataDTO: userDataDTO))
        
        let response: GetCardSuperSpeedResponse = try sanSoapServices.executeCall(request)
        self.superSpeedCardTries += 1
        let meta = try Meta.createMeta(request, response)

        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK")
            let cards: [CardSuperSpeedDTO] = {
                if isNegativeCreditBalanceEnabled {
                    return response.cardSuperSpeedListDTO.cards.map { card in
                        var card = card
                        card.currentBalance?.value?.negate()
                        return card
                    }
                } else {
                    return response.cardSuperSpeedListDTO.cards
                }
            }()
            response.cardSuperSpeedListDTO = CardSuperSpeedListDTO(cards: cards, pagination: response.cardSuperSpeedListDTO.pagination)
            //CONVERT AND STORE
            var currentCardsList: [CardDTO] = try self.getAllCards().getResponseData() ?? [CardDTO]()
            var cardDataList = [CardDataDTO]()
            var cardBalancesDictionary = [String: CardBalanceDTO]()
            var inactiveCardList = [InactiveCardDTO]()
            for card in response.cardSuperSpeedListDTO.cards {
                if let oldDTO = currentCardsList.filter { $0.formattedPAN == (card.PAN ?? "").replace(" ", "") }.first,
                   let type = card.cardType { // Update CardDTO with card type from Superspeed service
                    bsanDataProvider.updateCard(cardDTO: oldDTO, newType: type)
                }
                let cardData = CardDataDTO.createFromCardSuperSpeedDTO(from: card)
                cardDataList.append(cardData)
                if let pan = card.PAN {
                    let cardBalance = CardBalanceDTO.createFromCardSuperSpeedDTO(from: card)
                    cardBalancesDictionary[pan] = cardBalance
                }
                let inactiveCard = InactiveCardDTO.createFromCardSuperSpeedDTO(from: card)
                inactiveCardList.append(inactiveCard)
            }
            setCardsData(cardDataList)
            bsanDataProvider.storeCardBalances(dictionaryPANBalances: cardBalancesDictionary)
            storeInactiveCards(inactiveCardList.filter({ $0.inactiveCardType == .inactive }), .inactive)
            storeInactiveCards(inactiveCardList.filter({ $0.inactiveCardType == .temporallyOff }), .temporallyOff)
            
            //ASKS FOR NEW PAGE
            if let responsePagination = response.cardSuperSpeedListDTO.pagination, responsePagination.endList == false, self.superSpeedCardTries < superSpeedCardTriesMaxTries {
                if let _ = try self.loadCardSuperSpeed(pagination: responsePagination, isNegativeCreditBalanceEnabled: isNegativeCreditBalanceEnabled).getResponseData() {
                    return BSANOkResponse(meta)
                }
            } else {
                try GlobalPositionCardInfoMerger(bsanDataProvider: bsanDataProvider)
                self.superSpeedCardTries = 0
            }
            return BSANOkResponse(meta)
            
        }
        if pagination != nil {
            return BSANOkResponse(Meta.createOk())
        }
        self.superSpeedCardTries = 0
        return BSANErrorResponse(meta)
    }

    public func changeCardAlias(cardDTO: CardDTO, newAlias: String) throws -> BSANResponse<Void> {
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()

        let request = ChangeCardAliasRequest(
                BSANAssembleProvider.getChangeCardAliasAssemble(), // same assemble for all
                try bsanDataProvider.getEnvironment().urlBase,
                ChangeCardAliasRequestParams(token: authCredentials.soapTokenCredential,
                        userDataDTO: userDataDTO,
                        languageISO: bsanHeaderData.languageISO,
                        dialectISO: bsanHeaderData.dialectISO,
                        linkedCompany: bsanHeaderData.linkedCompany,
                        PAN: cardDTO.PAN ?? "",
                        newAlias: newAlias))

        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK")
            bsanDataProvider.updateCard(cardDTO: cardDTO, newAlias: newAlias)
            return BSANOkResponse(meta)
        }
        return BSANErrorResponse(meta)
    }

    public func validateCVV(cardDTO: CardDTO) throws -> BSANResponse<SCARepresentable> {
        let formattedPAN = cardDTO.formattedPAN ?? ""
        let cardDetailDTO = try self.getCardDetail(cardDTO: cardDTO).getResponseData()
        let globalPosition = try self.bsanDataProvider.get(\.globalPositionDTO)
        guard let beneficiary = cardDetailDTO?.beneficiary,
              let clientName = globalPosition.clientName,
              beneficiary.trim() == clientName.trim() else {
            return BSANErrorResponse(Meta.createKO("notBeneficiaryCard"))
        }
        let cardDetailTokenDTO = try self.getCardDetailToken(cardDTO: cardDTO, cardTokenType: CardTokenType.panWithoutSpaces).getResponseData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderDataForCVV()
        let request = ValidateCVVRequest(
                BSANAssembleProvider.getCVVAssemble(), // same assemble for all
                try bsanDataProvider.getEnvironment().urlBase,
                ValidateCVVRequestParams(token: authCredentials.soapTokenCredential,
                        cardDetailToken: cardDetailTokenDTO?.token ?? "",
                        userDataDTO: userDataDTO,
                        languageISO: bsanHeaderData.languageISO,
                        dialectISO: bsanHeaderData.dialectISO,
                        linkedCompany: bsanHeaderData.linkedCompany,
                        PAN: cardDTO.formattedPAN ?? "",
                        bankCode: cardDTO.contract?.bankCode ?? "",
                        branchCode: cardDTO.contract?.branchCode ?? "",
                        product: cardDTO.contract?.product ?? "",
                        contractNumber: cardDTO.contract?.contractNumber ?? ""))

        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(SignatureAndOTP(signature: response.signatureWithTokenDTO))
        }
        return BSANErrorResponse(meta)
    }

    public func validateCVVOTP(cardDTO: CardDTO, signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<OTPValidationDTO> {

        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderDataForCVV()

        let request = ValidateCVVOTPRequest(
                BSANAssembleProvider.getCVVAssemble(), // same assemble for all
                try bsanDataProvider.getEnvironment().urlBase,
                ValidateCVVOTPRequestParams(token: authCredentials.soapTokenCredential,
                        cardDetailToken: signatureWithTokenDTO.magicPhrase ?? "",
                        userDataDTO: userDataDTO,
                        languageISO: bsanHeaderData.languageISO,
                        dialectISO: bsanHeaderData.dialectISO,
                        linkedCompany: bsanHeaderData.linkedCompany,
                        PAN: cardDTO.formattedPAN ?? "",
                        bankCode: cardDTO.contract?.bankCode ?? "",
                        branchCode: cardDTO.contract?.branchCode ?? "",
                        product: cardDTO.contract?.product ?? "",
                        contractNumber: cardDTO.contract?.contractNumber ?? "",
                        cardSignature: signatureWithTokenDTO.signatureDTO))

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

    public func confirmCVV(cardDTO: CardDTO, otpValidationDTO: OTPValidationDTO?, otpCode: String?) throws -> BSANResponse<NumberCipherDTO> {
        let cardDetailDTO = try self.getCardDetail(cardDTO: cardDTO).getResponseData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderDataForCVV()
        let request = ConfirmCVVRequest(
                BSANAssembleProvider.getCVVAssemble(), // same assemble for all
                try bsanDataProvider.getEnvironment().urlBase,
                ConfirmCVVRequestParams(token: authCredentials.soapTokenCredential,
                        userDataDTO: userDataDTO,
                        languageISO: bsanHeaderData.languageISO,
                        dialectISO: bsanHeaderData.dialectISO,
                        linkedCompany: bsanHeaderData.linkedCompany,
                        PAN: cardDTO.formattedPAN ?? "",
                        bankCode: cardDTO.contract?.bankCode ?? "",
                        branchCode: cardDTO.contract?.branchCode ?? "",
                        product: cardDTO.contract?.product ?? "",
                        contractNumber: cardDTO.contract?.contractNumber ?? "",
                        otpTicket: otpValidationDTO?.ticket ?? "",
                        otpToken: otpValidationDTO?.magicPhrase ?? "",
                        otpCode: otpCode ?? "",
                        cardExpirationDate: cardDetailDTO?.expirationDate))
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK")
            let numCipher = response.numberCipherDTO.numCipher ?? ""
            let contract = cardDTO.contract?.contratoPK ?? ""
            let pan = cardDTO.formattedPAN ?? ""
            var key = contract + pan
            if bsanDataProvider.isDemo() {
                key = "004900805010020153" + "4425990000929308"
            }
            return BSANOkResponse(NumberCipherFormat.decipherNumber(message: numCipher, key: key.replacingOccurrences(of: " ", with: "")))
        }
        return BSANErrorResponse(meta)
    }

    public func validatePIN(cardDTO: CardDTO, cardDetailTokenDTO: CardDetailTokenDTO) throws -> BSANResponse<SignatureWithTokenDTO> {

        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()

        let request = ValidatePinRequest(
                BSANAssembleProvider.getPINAssemble(), // same assemble for all
                try bsanDataProvider.getEnvironment().urlBase,
                ValidatePinRequestParams(token: authCredentials.soapTokenCredential,
                        cardToken: cardDetailTokenDTO.token ?? "",
                        userDataDTO: userDataDTO,
                        languageISO: bsanHeaderData.languageISO,
                        dialectISO: bsanHeaderData.dialectISO,
                        linkedCompany: bsanHeaderData.linkedCompany,
                        PAN: cardDTO.formattedPAN ?? "",
                        bankCode: cardDTO.contract?.bankCode ?? "",
                        branchCode: cardDTO.contract?.branchCode ?? "",
                        product: cardDTO.contract?.product ?? "",
                        contractNumber: cardDTO.contract?.contractNumber ?? ""))

        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");
            return BSANOkResponse(response.signatureWithTokenDTO)
        }
        return BSANErrorResponse(meta)
    }

    public func validatePINOTP(cardDTO: CardDTO, signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<OTPValidationDTO> {

        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()

        let request = ValidatePINOTPRequest(
                BSANAssembleProvider.getPINAssemble(), // same assemble for all
                try bsanDataProvider.getEnvironment().urlBase,
                ValidatePINOTPRequestParams(token: authCredentials.soapTokenCredential,
                        cardToken: signatureWithTokenDTO.magicPhrase ?? "",
                        userDataDTO: userDataDTO,
                        languageISO: bsanHeaderData.languageISO,
                        dialectISO: bsanHeaderData.dialectISO,
                        linkedCompany: bsanHeaderData.linkedCompany,
                        PAN: cardDTO.formattedPAN ?? "",
                        bankCode: cardDTO.contract?.bankCode ?? "",
                        branchCode: cardDTO.contract?.branchCode ?? "",
                        product: cardDTO.contract?.product ?? "",
                        contractNumber: cardDTO.contract?.contractNumber ?? "",
                        cardSignature: signatureWithTokenDTO.signatureDTO))

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

    public func confirmPIN(cardDTO: CardDTO, otpValidationDTO: OTPValidationDTO?, otpCode: String?) throws -> BSANResponse<NumberCipherDTO> {

        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()

        let request = ConfirmPINRequest(
                BSANAssembleProvider.getPINAssemble(), // same assemble for all
                try bsanDataProvider.getEnvironment().urlBase,
                ConfirmPINRequestParams(token: authCredentials.soapTokenCredential,
                        userDataDTO: userDataDTO,
                        languageISO: bsanHeaderData.languageISO,
                        dialectISO: bsanHeaderData.dialectISO,
                        linkedCompany: bsanHeaderData.linkedCompany,
                        PAN: cardDTO.formattedPAN ?? "",
                        bankCode: cardDTO.contract?.bankCode ?? "",
                        branchCode: cardDTO.contract?.branchCode ?? "",
                        product: cardDTO.contract?.product ?? "",
                        contractNumber: cardDTO.contract?.contractNumber ?? "",
                        otpTicket: otpValidationDTO?.ticket ?? "",
                        otpToken: otpValidationDTO?.magicPhrase ?? "",
                        otpCode: otpCode ?? ""))

        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");
            let numCipher = response.numPINCipher.numCipher ?? ""
            let contract = cardDTO.contract?.contratoPK ?? ""
            let pan = cardDTO.formattedPAN ?? ""
            var key = contract + pan
            if bsanDataProvider.isDemo() {
                //0049008050100201534425990000929308
                key = "004900755012414533" + "4425990000033721"
            }

            return BSANOkResponse(NumberCipherFormat.decipherNumber(message: numCipher, key: key.replacingOccurrences(of: " ", with: "")))
        }
        return BSANErrorResponse(meta)
    }

    public func getPayLaterData(cardDTO: CardDTO) throws -> BSANResponse<PayLaterDTO> {
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getPayLaterAssemble()

        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()

        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()

        let request = GetPayLaterDataRequest(
                bsanAssemble,
                bsanEnvironment.urlBase,
                GetPayLaterDataRequestParams(token: authCredentials.soapTokenCredential,
                        userDataDTO: userDataDTO,
                        languageISO: bsanHeaderData.languageISO,
                        dialectISO: bsanHeaderData.dialectISO,
                        linkedCompany: bsanHeaderData.linkedCompany,
                        bankCode: cardDTO.contract?.bankCode ?? "",
                        branchCode: cardDTO.contract?.branchCode ?? "",
                        product: cardDTO.contract?.product ?? "",
                        contractNumber: cardDTO.contract?.contractNumber ?? ""))

        let response: GetPayLaterDataResponse = try sanSoapServices.executeCall(request)

        let meta = try Meta.createMeta(request, response)

        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            bsanDataProvider.store(payLaterDTO: response.payLaterDTO)
            return BSANOkResponse(meta, response.payLaterDTO)
        }
        return BSANErrorResponse(meta)
    }

    public func confirmPayLaterData(cardDTO: CardDTO, payLaterDTO: PayLaterDTO, amountDTO: AmountDTO) throws -> BSANResponse<Void> {
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getPayLaterAssemble()

        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()

        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()

        let request = ConfirmPayLaterRequest(
                bsanAssemble,
                bsanEnvironment.urlBase,
                ConfirmPayLaterRequestParams(token: authCredentials.soapTokenCredential,
                        userDataDTO: userDataDTO,
                        languageISO: bsanHeaderData.languageISO,
                        dialectISO: bsanHeaderData.dialectISO,
                        linkedCompany: bsanHeaderData.linkedCompany,
                        bankCode: cardDTO.contract?.bankCode ?? "",
                        branchCode: cardDTO.contract?.branchCode ?? "",
                        product: cardDTO.contract?.product ?? "",
                        contractNumber: cardDTO.contract?.contractNumber ?? "",
                        operationDate: payLaterDTO.debts.isEmpty ?
                                Date() :
                        payLaterDTO.debts[0].operationDate ?? Date(),
                        amountValue: AmountFormats.getValueForWS(value: amountDTO.value),
                        currency: amountDTO.currency?.currencyName ?? ""))

        let response: BSANSoapResponse = try sanSoapServices.executeCall(request)

        let meta = try Meta.createMeta(request, response)

        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta)
        }
        return BSANErrorResponse(meta)
    }
    
    public func getTransactionDetailEasyPay(cardDTO: CardDTO, cardDetailDTO: CardDetailDTO, cardTransactionDTO: CardTransactionDTO, cardTransactionDetailDTO: CardTransactionDetailDTO, easyPayContractTransactionDTO: EasyPayContractTransactionDTO) throws -> BSANResponse<EasyPayDTO> {
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getEasyPayAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let operationDateString: String = {
            guard let operationDate = cardTransactionDTO.operationDate else { return "" }
            return DateFormats.toString(date: operationDate, output: DateFormats.TimeFormat.YYYYMMDD)
        }()
        var id = (cardDTO.formattedPAN ?? "").replace(" ", "")
        id += operationDateString
        id += (cardTransactionDTO.transactionDay ?? "")
        id += (cardTransactionDTO.amount?.description ?? "")
        id += easyPayContractTransactionDTO.compoundField ?? ""
        id += easyPayContractTransactionDTO.balanceCode ?? ""
        if let detail = try bsanDataProvider.get(\.cardInfo.easyPayDTOs)[id] {
            return BSANOkResponse(detail)
        }
        let request = GetTransactionDetailEasyPayRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            GetTransactionDetailEasyPayRequestParams(
                token: authCredentials.soapTokenCredential,
                userDataDTO: userDataDTO,
                languageISO: bsanHeaderData.languageISO,
                dialectISO: bsanHeaderData.dialectISO,
                requestStatus: easyPayContractTransactionDTO.requestStatus ?? "",
                bankCode: cardDTO.contract?.bankCode ?? "",
                branchCode: cardDTO.contract?.branchCode ?? "",
                product: cardDTO.contract?.product ?? "",
                contractNumber: cardDTO.contract?.contractNumber ?? "",
                annotationDate: cardTransactionDTO.annotationDate ?? Date(),
                amountTransactionValue: "\(cardTransactionDTO.amount?.wholePart ?? "").\(cardTransactionDTO.amount?.getDecimalPart() ?? "")",
                currencyTransactionValue: cardTransactionDTO.amount?.currency?.currencyName ?? "",
                currency: cardDetailDTO.availableAmount?.currency?.currencyName ?? "",
                transactionDay: cardTransactionDTO.transactionDay ?? "",
                balanceCode: cardTransactionDTO.balanceCode ?? "",
                basicOperation: cardTransactionDetailDTO.bankOperation?.basicOperation ?? "",
                bankOperation: cardTransactionDetailDTO.bankOperation?.bankOperation ?? ""
            )
        )
        let response: GetTransactionDetailEasyPayResponse = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        guard meta.isOK() else { return BSANErrorResponse(meta) }
        BSANLogger.i(logTag, "Meta OK")
        bsanDataProvider.store(easyPayDto: response.easyPayDTO, id: id)
        return BSANOkResponse(meta, response.easyPayDTO)
    }
    
    public func getAllTransactionsEasyPayContract(cardDTO: CardDTO, dateFilter: DateFilter?) throws -> BSANResponse<EasyPayContractTransactionListDTO> {
        var lastPagination: PaginationDTO?
        repeat {
            let response = try getTransactionsEasyPayContract(cardDTO: cardDTO, pagination: nil, dateFilter: dateFilter)
            guard response.isSuccess() else {
                return response
            }
            lastPagination = try response.getResponseData()?.pagination
        } while lastPagination != nil && lastPagination?.endList == false
        return try getTransactionsEasyPayContract(cardDTO: cardDTO, pagination: nil, dateFilter: dateFilter)
    }

    public func getTransactionsEasyPayContract(cardDTO: CardDTO, pagination: PaginationDTO?, dateFilter: DateFilter?) throws -> BSANResponse<EasyPayContractTransactionListDTO> {
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getEasyPayAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()

        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()

        guard var cardContract = cardDTO.formattedPAN else {
            throw BSANException("No card contract formatted value in getTransactionsEasyPayContract")
        }
        if let dateFilter = dateFilter {
            cardContract += dateFilter.string
        }

        let easyPayContractMovements = try bsanDataProvider.get(\.cardInfo).easyPayContractTransactionsList[cardContract]

        if let easyPayContractMovements = easyPayContractMovements {
            // Stored data
            if pagination == nil {
                //show the first page
                return BSANOkResponse(easyPayContractMovements)
            }
            if let pagination = easyPayContractMovements.pagination, pagination.endList {
                return BSANOkResponse(easyPayContractMovements)
            }
        }

        let request = GetTransactionsContractEasyPayRequest(
                bsanAssemble,
                bsanEnvironment.urlBase,
                GetTransactionsContractEasyPayRequestParams(token: authCredentials.soapTokenCredential,
                        userDataDTO: userDataDTO,
                        languageISO: bsanHeaderData.languageISO,
                        dialectISO: bsanHeaderData.dialectISO,
                        bankCode: cardDTO.contract?.bankCode ?? "",
                        branchCode: cardDTO.contract?.branchCode ?? "",
                        product: cardDTO.contract?.product ?? "",
                        contractNumber: cardDTO.contract?.contractNumber ?? "",
                        dateFilter: dateFilter,
                        pagination: pagination))

        let response: GetTransactionsContractEasyPayResponse = try sanSoapServices.executeCall(request)

        let meta = try Meta.createMeta(request, response)

        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            bsanDataProvider.store(easyPayContractTransactionListDTO: response.easyPayContractTransactionListDTO, contractId: cardContract)
            return BSANOkResponse(meta, response.easyPayContractTransactionListDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func getFeesEasyPay(cardDTO: CardDTO) throws -> BSANResponse<FeeDataDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let id = cardDTO.formattedPAN
        if let cardId = id, let feeData = try bsanDataProvider.get(\.cardInfo.feesData)[cardId] {
            return BSANOkResponse(feeData)
        }
        let request = GetFeesEasyPayRequest(
            BSANAssembleProvider.getEasyPayAssemble(),
            bsanEnvironment.urlBase,
            GetFeesEasyPayRequestParams(
                token: authCredentials.soapTokenCredential,
                userDataDTO: userDataDTO,
                languageISO: bsanHeaderData.languageISO,
                dialectISO: bsanHeaderData.dialectISO,
                bankCode: cardDTO.contract?.bankCode ?? "",
                branchCode: cardDTO.contract?.branchCode ?? "",
                product: cardDTO.contract?.product ?? "",
                contractNumber: cardDTO.contract?.contractNumber ?? "",
                company: cardDTO.productSubtypeDTO?.company ?? "",
                productType: cardDTO.productSubtypeDTO?.productType ?? "",
                productSubtype: cardDTO.productSubtypeDTO?.productSubtype ?? ""
            )
        )
        let response: GetFeesEasyPayResponse = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        guard meta.isOK() else { return BSANErrorResponse(meta) }
        BSANLogger.i(logTag, "Meta OK")
        if let cardId = id {
            bsanDataProvider.store(feeData: response.feeDataDTO, id: cardId)
        }
        return BSANOkResponse(response.feeDataDTO)
    }
    
    public func getEasyPayFees(input: BuyFeesParameters, card: CardDTO) throws -> BSANResponse<FeesInfoDTO> {
        let dataSource = EasyPayFeesInfoDataSource(sanRestServices: sanRestServices, bsanDataProvider: bsanDataProvider)
        return try dataSource.getFeesInfo(input: input, card: card)
    }
    
    public func getEasyPayFinanceableList(input: FinanceableListParameters) throws -> BSANResponse<FinanceableMovementsListDTO> {
        let dataSource = EasyPayFinanceableListDataSource(sanRestServices: sanRestServices, bsanDataProvider: bsanDataProvider)
        let storedFinanceableList = try getStoredFinanceableList(input: input)
        guard storedFinanceableList == nil else {
            return BSANOkResponse(storedFinanceableList)
        }
        let response = try dataSource.getFinanceableList(input: input)
        if response.isSuccess(),
           let financeablelist = try response.getResponseData() {
            let movementStatus: MovementStatus = input.isEasyPay ? .fractionable : .others
            bsanDataProvider.storeFinanceableCardMovements(input.pan,
                                                           financeableList: financeablelist,
                                                           status: movementStatus)
        }
        return response
    }

    func getStoredFinanceableList(input: FinanceableListParameters) throws -> FinanceableMovementsListDTO? {
        let movementStatus: MovementStatus = input.isEasyPay ? .fractionable : .others
        let storeFinanceableList: FinanceableMovementsListDTO? = try bsanDataProvider.get(\.financeableCardMovementsInfo).getFinanceableCardMovementsCacheFor(input.pan, status: movementStatus)
        guard let storedlist = storeFinanceableList else { return nil }
        return storedlist
    }
    
    public func getAmortizationEasyPay(cardDTO: CardDTO, cardTransactionDTO: CardTransactionDTO, feeDataDTO: FeeDataDTO, numFeesSelected: String, balanceCode: Int, movementIndex: Int) throws -> BSANResponse<EasyPayAmortizationDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let input = EasyPayAmortizationRequestParams(
            cdempre: cardDTO.contract?.bankCode ?? "",
            cdempred: cardDTO.contract?.bankCode ?? "",
            centalta: cardDTO.contract?.branchCode ?? "",
            cdproduc: cardDTO.productSubtypeDTO?.productType ?? "",
            cuentad: cardDTO.contract?.contractNumber ?? "",
            controlOperativoContrato: cardDTO.contractDescription?.replacingOccurrences(of: " ", with: "") ?? "",
            controlOperativoCliente:  userDataDTO.controlOperativoCliente,
            clamon1: cardDTO.currency?.currencyType.rawValue ?? SharedCurrencyType.default.rawValue,
            cuotano: Int(numFeesSelected) ?? 0,
            nuextcta: balanceCode,
            numvtoex: movementIndex)
        let dataSource = EasyPayAmortizationTableSimulationDataSource(sanRestServices: sanRestServices, bsanDataProvider: bsanDataProvider)
        return try dataSource.getAmortizationEasyPayRequest(input: input)
    }
    
    public func confirmationEasyPay(input: BuyFeesParameters, card: CardDTO) throws -> BSANResponse<Void> {
        let dataSource = EasyPayNewPurchaseDataSource(sanRestServices: sanRestServices, bsanDataProvider: bsanDataProvider)
        return try dataSource.confirmationEasyPay(input: input, card: card)
    }
    
    // MARK: -
    // MARK: Limits Change Cards
    
    public func validateModifyDebitCardLimitOTP(cardDTO: CardDTO, signatureWithToken: SignatureWithTokenDTO, debitLimitDailyAmount: AmountDTO, atmLimitDailyAmount: AmountDTO, creditLimitDailyAmount: AmountDTO) throws -> BSANResponse<OTPValidationDTO> {
        return try validateModifyCardLimitOTP(
            cardDTO: cardDTO,
            signatureWithToken: signatureWithToken,
            debitLimitDailyAmount: debitLimitDailyAmount,
            atmLimitDailyAmount: atmLimitDailyAmount,
            creditLimitDailyAmount: creditLimitDailyAmount
        )
    }
    
    public func validateModifyCreditCardLimitOTP(cardDTO: CardDTO, signatureWithToken: SignatureWithTokenDTO, atmLimitDailyAmount: AmountDTO, creditLimitDailyAmount: AmountDTO) throws -> BSANResponse<OTPValidationDTO> {
        return try validateModifyCardLimitOTP(
            cardDTO: cardDTO,
            signatureWithToken: signatureWithToken,
            atmLimitDailyAmount: atmLimitDailyAmount,
            creditLimitDailyAmount: creditLimitDailyAmount
        )
    }
    
    private func validateModifyCardLimitOTP(cardDTO: CardDTO, signatureWithToken: SignatureWithTokenDTO, debitLimitDailyAmount: AmountDTO = AmountDTO(value: 0, currency: .create(SharedCurrencyType.default)), atmLimitDailyAmount: AmountDTO, creditLimitDailyAmount: AmountDTO) throws -> BSANResponse<OTPValidationDTO> {
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getChangeLimitCardAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ValidateModifyLimitCardOtpRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            ValidateModifyLimitCardOtpRequestParams(token: authCredentials.soapTokenCredential,
                                                    userDataDTO: userDataDTO,
                                                    languageISO: bsanHeaderData.languageISO,
                                                    dialectISO: bsanHeaderData.dialectISO,
                                                    cardNumber: cardDTO.formattedPAN ?? "",
                                                    linkedCompany: bsanHeaderData.linkedCompany,
                                                    signatureWithToken: signatureWithToken,
                                                    debitLimitDailyAmount: debitLimitDailyAmount,
                                                    atmLimitDailyAmount: atmLimitDailyAmount,
                                                    creditLimitDailyAmount: creditLimitDailyAmount)
        )

        
        let response: ValidateModifyLimitCardOtpResponse = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)

        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, response.otpValidationDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    
    public func confirmModifyDebitCardLimitOTP(cardDTO: CardDTO, otpCode: String, otpValidationDTO: OTPValidationDTO, debitLimitDailyAmount: AmountDTO, atmLimitDailyAmount: AmountDTO, cardSuperSpeedDTO: CardSuperSpeedDTO) throws -> BSANResponse<Void> {
        return try confirmModifyCardLimitOTP(
            cardDTO: cardDTO,
            otpCode: otpCode,
            otpValidationDTO: otpValidationDTO,
            debitLimitDailyAmount: debitLimitDailyAmount,
            atmLimitDailyAmount: atmLimitDailyAmount,
            cardSuperSpeedDTO: cardSuperSpeedDTO
        )
    }
    
    public func confirmModifyCreditCardLimitOTP(cardDTO: CardDTO, otpCode: String, otpValidationDTO: OTPValidationDTO, atmLimitDailyAmount: AmountDTO, cardSuperSpeedDTO: CardSuperSpeedDTO) throws -> BSANResponse<Void> {
        return try confirmModifyCardLimitOTP(
            cardDTO: cardDTO,
            otpCode: otpCode,
            otpValidationDTO: otpValidationDTO,
            atmLimitDailyAmount: atmLimitDailyAmount,
            cardSuperSpeedDTO: cardSuperSpeedDTO
        )
    }
    
    private func confirmModifyCardLimitOTP(cardDTO: CardDTO, otpCode: String, otpValidationDTO: OTPValidationDTO, debitLimitDailyAmount: AmountDTO = AmountDTO(value: 0, currency: .create(SharedCurrencyType.default)), atmLimitDailyAmount: AmountDTO, cardSuperSpeedDTO: CardSuperSpeedDTO) throws -> BSANResponse<Void> {
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getChangeLimitCardAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let request = ConfirmModifyLimitCardOtpRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            ConfirmModifyLimitCardOtpRequestParams(token: authCredentials.soapTokenCredential,
                                                    userDataDTO: userDataDTO,
                                                    languageISO: bsanHeaderData.languageISO,
                                                    dialectISO: bsanHeaderData.dialectISO,
                                                    cardNumber: cardDTO.formattedPAN ?? "",
                                                    otpCode: otpCode,
                                                    linkedCompany: bsanHeaderData.linkedCompany,
                                                    debitLimitDailyAmount: debitLimitDailyAmount,
                                                    atmLimitDailyAmount: atmLimitDailyAmount,
                                                    otpValidationDTO: otpValidationDTO,
                                                    cardSuperSpeedDTO: cardSuperSpeedDTO,
                                                    temporaryLimitCreditStart: cardSuperSpeedDTO.temporaryLimitCreditStart ?? "0001-01-01",
                                                    temporaryLimitCreditEnd: cardSuperSpeedDTO.temporaryLimitCreditStart ?? "0001-01-01",
                                                    temporaryLimitCreditMonthStart: cardSuperSpeedDTO.temporaryLimitCreditMonthStart ?? "0001-01-01",
                                                    temporaryLimitCreditMonthEnd: cardSuperSpeedDTO.temporaryLimitCreditMonthEnd ?? "0001-01-01",
                                                    temporaryLimitCreditDayStart: cardSuperSpeedDTO.temporaryLimitCreditDayStart ?? "0001-01-01",
                                                    temporaryLimitCreditDayEnd: cardSuperSpeedDTO.temporaryLimitCreditDayEnd ?? "0001-01-01",
                                                    temporaryLimitDebitMonthStart: cardSuperSpeedDTO.temporaryLimitDebitMonthStart ?? "0001-01-01",
                                                    temporaryLimitDebitMonthEnd: cardSuperSpeedDTO.temporaryLimitDebitMonthEnd ?? "0001-01-01",
                                                    temporaryLimitDebitDayStart: cardSuperSpeedDTO.temporaryLimitDebitDayStart ?? "0001-01-01",
                                                    temporaryLimitDebitDayEnd: cardSuperSpeedDTO.temporaryLimitDebitDayEnd ?? "0001-01-01"
        ))
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta)
        }
        return BSANErrorResponse(meta)
    }
    
    public func getCardPendingTransactions(cardDTO: CardDTO, pagination: PaginationDTO?) throws -> BSANResponse<CardPendingTransactionsListDTO> {
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getCardPendingTransactionsAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()

        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()

        let request = GetCardPendingTransactionsRequest(
                bsanAssemble,
                bsanEnvironment.urlBase,
                GetCardPendingTransactionsRequestParams(token: authCredentials.soapTokenCredential,
                        userDataDTO: userDataDTO,
                        languageISO: bsanHeaderData.languageISO,
                        bankCode: cardDTO.contract?.bankCode ?? "",
                        branchCode: cardDTO.contract?.branchCode ?? "",
                        product: cardDTO.contract?.product ?? "",
                        contractNumber: cardDTO.contract?.contractNumber ?? "",
                        dialectISO: bsanHeaderData.dialectISO,
                        linkedCompany: bsanHeaderData.linkedCompany,
                        pagination: pagination))

        let response: GetCardPendingTransactionsResponse = try sanSoapServices.executeCall(request)

        let meta = try Meta.createMeta(request, response)

        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, response.cardPendingTransactionsListDTO)
        }
        return BSANErrorResponse(meta)
    }

    public func checkCardExtractPdf(cardDTO: CardDTO, dateFilter: DateFilter, isPCAS: Bool) throws -> BSANResponse<DocumentDTO> {
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getCardsExtractPdfAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()

        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()

        let request = CheckExtractPdfRequest(
                bsanAssemble,
                bsanEnvironment.urlBase,
                CheckExtractPdfRequestParams(token: authCredentials.soapTokenCredential,
                        userDataDTO: userDataDTO,
                        languageISO: bsanHeaderData.languageISO,
                        dialectISO: bsanHeaderData.dialectISO,
                        company: bsanHeaderData.linkedCompany,
                        bankCode: cardDTO.contract?.bankCode ?? "",
                        branchCode: cardDTO.contract?.branchCode ?? "",
                        product: cardDTO.contract?.product ?? "",
                        contractName: cardDTO.contract?.contractNumber ?? "",
                        dateFilter: dateFilter,
                        isPCAS: isPCAS))

        let response: CheckExtractPdfResponse = try sanSoapServices.executeCall(request)

        let meta = try Meta.createMeta(request, response)

        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, response.documentDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func getPaymentChange(cardDTO: CardDTO) throws -> BSANResponse<ChangePaymentDTO> {
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getChangePaymentMethodAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ChangePaymentMethodRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            ChangePaymentMethodRequestParams(
                token: authCredentials.soapTokenCredential,
                userDataDTO: userDataDTO,
                languageISO: bsanHeaderData.languageISO,
                dialectISO: bsanHeaderData.dialectISO,
                linkedCompany: bsanHeaderData.linkedCompany,
                bankCode: cardDTO.contract?.bankCode ?? "",
                branchCode: cardDTO.contract?.branchCode ?? "",
                product: cardDTO.contract?.product ?? "",
                contractNumber: cardDTO.contract?.contractNumber ?? ""
            )
        )
        
        let response: ChangePaymentMethodResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, response.changePaymentDto)
        }
        return BSANErrorResponse(meta)
    }
    
    public func confirmPaymentChange(cardDTO: CardDTO, input: ChangePaymentMethodConfirmationInput) throws -> BSANResponse<Void> {
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getChangePaymentMethodAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ChangePaymentMethodConfirmationRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            ChangePaymentMethodConfirmationRequestParams(
                token: authCredentials.soapTokenCredential,
                userDataDTO: userDataDTO,
                languageISO: bsanHeaderData.languageISO,
                dialectISO: bsanHeaderData.dialectISO,
                linkedCompany: bsanHeaderData.linkedCompany,
                newPaymentMethodDTO: input.selectedPaymentMethod,
                referenceStandard: input.referenceStandard,
                hiddenReferenceStandard: input.hiddenReferenceStandard,
                selectedAmount: input.selectedAmount,
                bankCode: cardDTO.contract?.bankCode ?? "",
                branchCode: cardDTO.contract?.branchCode ?? "",
                product: cardDTO.contract?.product ?? "",
                contractNumber: cardDTO.contract?.contractNumber ?? "",
                marketCode: input.marketCode ?? "",
                currentPaymentMethod: input.currentPaymentMethod,
                currentPaymentMethodMode: input.currentPaymentMethodMode,
                currentSettlementType: input.currentSettlementType,
                hiddenMarketCode: input.hiddenMarketCode ?? "",
                hiddenPaymentMethodMode: input.hiddenPaymentMethodMode
            )
        )
        
        let response: ChangePaymentMethodConfirmationResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta)
        }
        return BSANErrorResponse(meta)
    }
    
    // MARK: - Apple Pay
    
    public func loadApplePayStatus(for addedPasses: [String]) throws -> BSANResponse<Void> {
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getApplePayAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = CardsListApplePayStatusRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            CardsListApplePayStatusRequestParams(
                token: authCredentials.soapTokenCredential,
                userDataDTO: userDataDTO,
                language: bsanHeaderData.languageISO,
                dialect: bsanHeaderData.dialectISO,
                addedPasses: addedPasses
            )
        )
        let response: CardsListApplePayStatusResponse = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        
        guard meta.isOK() else {
            return BSANErrorResponse(meta)
        }
        BSANLogger.i(logTag, "Meta OK")
        if let panStatusList = response.panStatusList {
            bsanDataProvider.updateApplePayStatus(applePayStatus: panStatusList)
        }
        return BSANOkResponse(meta)
    }
    
    public func getApplePayStatus(for card: CardDTO, expirationDate: DateModel) throws -> BSANResponse<CardApplePayStatusDTO> {
        guard let pan = card.PAN?.replace(" ", "") else {
            return BSANOkResponse(CardApplePayStatusDTO(status: .notEnrollable))
        }
        if let applePayStatus = try bsanDataProvider.get(\.cardApplePayStatus)[pan] {
            return BSANOkResponse(applePayStatus)
        }
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getApplePayAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = CardApplePayStatusRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            CardApplePayStatusRequestParams(
                token: authCredentials.soapTokenCredential,
                userDataDTO: userDataDTO,
                language: bsanHeaderData.languageISO,
                dialect: bsanHeaderData.dialectISO,
                card: card,
                expirationDate: expirationDate
            )
        )
        let response: CardApplePayStatusResponse = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        
        guard meta.isOK(), let status = response.status else {
            return BSANErrorResponse<CardApplePayStatusDTO>(meta)
        }
        BSANLogger.i(logTag, "Meta OK")
        bsanDataProvider.updateApplePayStatus(applePayStatus: [pan: status])
        return BSANOkResponse(meta, status)
    }
    
    public func validateApplePay(card: CardDTO, signature: SignatureWithTokenDTO) throws -> BSANResponse<ApplePayValidationDTO> {
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getApplePayAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ApplePayValidationRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            ApplePayValidationRequestParams(
                token: authCredentials.soapTokenCredential,
                userDataDTO: userDataDTO,
                language: bsanHeaderData.languageISO,
                dialect: bsanHeaderData.dialectISO,
                signature: signature,
                card: card,
                linkedCompany: bsanHeaderData.linkedCompany
            )
        )
        
        let response: ApplePayValidationResponse = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        
        guard meta.isOK(), let appleValidationDTO = response.appleValidationDTO else {
            return BSANErrorResponse<ApplePayValidationDTO>(meta)
        }
        BSANLogger.i(logTag, "Meta OK")
        return BSANOkResponse(meta, appleValidationDTO)
    }
    
    public func confirmApplePay(card: CardDTO, cardDetail: CardDetailDTO, otpValidation: OTPValidationDTO, otpCode: String, encryptionScheme: String, publicCertificates: [Data], nonce: Data, nonceSignature: Data) throws -> BSANResponse<ApplePayConfirmationDTO> {
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getApplePayAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ApplePayConfirmationRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            ApplePayConfirmationRequestParams(
                token: authCredentials.soapTokenCredential,
                userDataDTO: userDataDTO,
                language: bsanHeaderData.languageISO,
                dialect: bsanHeaderData.dialectISO,
                card: card,
                cardDetail: cardDetail,
                otpValidation: otpValidation,
                otpCode: otpCode,
                encryptionScheme: encryptionScheme,
                publicCertificates: publicCertificates,
                nonce: nonce,
                nonceSignature: nonceSignature,
                linkedCompany: bsanHeaderData.linkedCompany
            )
         )
        
        let response: ApplePayConfirmationResponse = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        
        guard meta.isOK(), let confirmation = response.confirmation else {
            return BSANErrorResponse<ApplePayConfirmationDTO>(meta)
        }
        BSANLogger.i(logTag, "Meta OK")
        if let pan = card.PAN {
            bsanDataProvider.removeApplePayStatus(for: pan)
        }
        return BSANOkResponse(meta, confirmation)
    }
    
    public func getCardApplePayStatus() throws -> BSANResponse<[String: CardApplePayStatusDTO]> {
        let applePayStatus = try bsanDataProvider.get(\.cardApplePayStatus)
        return BSANOkResponse(applePayStatus)
    }
    
    // MARK: - Settlements Card
    
    public func getCardSettlementDetail(card: CardDTO, date: Date) throws -> BSANResponse<CardSettlementDetailDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let dataSource: CardSettlementDetailDataSourceProtocol = CardSettlementDetailDataSource(sanRestServices: sanRestServices, bsanEnvironment: bsanEnvironment)
        let dateWithFormat = DateFormats.toString(date: date, output: DateFormats.TimeFormat.MMyyyy)
        let userData = try self.bsanDataProvider.getUserData()
        guard let contractNumber = card.contract?.formattedValue else {
            return BSANErrorResponse(Meta.createKO())
        }
        let cardEntity = CardEntity(card)
        let storedDTO = try getCardSettlementDetailStoredDTO(card: cardEntity)
        guard storedDTO == nil else {
            return BSANOkResponse(storedDTO)
        }
        let response = try dataSource.getCardSettlementDetail(params: CardSettlementDetailRequestParams(contractNumber: contractNumber, cmc: userData.getCMC, date: dateWithFormat))
        if response.isSuccess(),
            let cardSettlementDto = try response.getResponseData() {
            bsanDataProvider.store(cardEntity.pan,
                                   cardSettlementDetailDTO: cardSettlementDto)
        }
        return response
    }
    
    func getCardSettlementDetailStoredDTO(card: CardEntity) throws -> CardSettlementDetailDTO? {
        let storedCardSettlementDetail: CardSettlementDetailDTO? = try bsanDataProvider.get(\.cardSettlementDetailInfo).setCardSettlementDetailsCacheFor(card.pan)
        if let _ = storedCardSettlementDetail {
            return storedCardSettlementDetail
        }
        return nil
    }
    
    public func getCardSettlementListMovements(card: CardDTO, extractNumber: Int) throws -> BSANResponse<[CardSettlementMovementDTO]> {
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let dataSource: CardSettlementMovementsDataSourceProtocol = CardSettlementMovementsDataSource(sanRestServices: sanRestServices, bsanEnvironment: bsanEnvironment)
        let userData = try self.bsanDataProvider.getUserData()
        guard let contractNumber = card.contract?.formattedValue,
            let pan = card.formattedPAN else {
                return BSANErrorResponse(Meta.createKO())
        }
        return try dataSource.getCardSettlementListMovements(params: CardSettlementMovementsRequestParams(contractNumber: contractNumber, cmc: userData.getCMC, extractNumber: extractNumber, pan: pan))
    }
    
    public func getCardSettlementListMovementsByContract(card: CardDTO, extractNumber: Int) throws -> BSANResponse<[CardSettlementMovementWithPANDTO]> {
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let dataSource: CardSettlementMovementsDataSourceProtocol = CardSettlementMovementsDataSource(sanRestServices: sanRestServices, bsanEnvironment: bsanEnvironment)
        let userData = try self.bsanDataProvider.getUserData()
        guard let contractNumber = card.contract?.formattedValue else {
                return BSANErrorResponse(Meta.createKO())
        }
        return try dataSource.getCardSettlementListMovementsByContract(params: CardSettlementMovementsRequestParams(contractNumber: contractNumber, cmc: userData.getCMC, extractNumber: extractNumber, pan: ""))
    }
    
    // MARK: - Subscriptions
    public func getCardSubscriptionsList(input: SubscriptionsListParameters) throws -> BSANResponse<CardSubscriptionsListDTO> {
        let dataSource = CardSubscriptionsDataSource(sanRestServices: sanRestServices, bsanDataProvider: bsanDataProvider)
        return try dataSource.getFinanceableList(input: input)
    }
    
    public func getCardSubscriptionsHistorical(input: SubscriptionsHistoricalInputParams) throws -> BSANResponse<CardSubscriptionsHistoricalListDTO> {
        let dataSource = CardSubscriptionsDataSource(sanRestServices: sanRestServices, bsanDataProvider: bsanDataProvider)
        return try dataSource.getSubscriptionsHistorical(input: input)
    }
    
    public func getCardSubscriptionsGraphData(input: SubscriptionsGraphDataInputParams) throws -> BSANResponse<CardSubscriptionsGraphDataDTO> {
        let dataSource = CardSubscriptionsDataSource(sanRestServices: sanRestServices, bsanDataProvider: bsanDataProvider)
        return try dataSource.getSubscriptionsGraphData(input: input)
    }
    
    // MARK: - Fractionable Pruchase Detail
    
    public func getFractionablePurchaseDetail(input: FractionablePurchaseDetailParameters) throws -> BSANResponse<FinanceableMovementDetailDTO> {
        let dataSource = FractionablePurchaseDetailDataSource(sanRestServices: sanRestServices, bsanDataProvider: bsanDataProvider)
        return try dataSource.getDetail(input: input)
    }
}

fileprivate extension NumberFormatter {
    func withSeparator(decimals: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ""
        formatter.decimalSeparator = "."
        formatter.maximumFractionDigits = decimals
        formatter.minimumFractionDigits = decimals
        formatter.maximumIntegerDigits = 12
        formatter.minimumIntegerDigits = 1
        formatter.numberStyle = .decimal
        return formatter
    }
}
