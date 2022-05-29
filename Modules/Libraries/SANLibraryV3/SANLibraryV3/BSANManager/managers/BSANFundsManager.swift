import CoreDomain
import Foundation
import SANLegacyLibrary

public class BSANFundsManagerImplementation: BSANBaseManager, BSANFundsManager {
    
    var sanSoapServices: SanSoapServices
    
    public init(bsanDataProvider: BSANDataProvider, sanSoapServices: SanSoapServices) {
        self.sanSoapServices = sanSoapServices
        super.init(bsanDataProvider: bsanDataProvider)
    }
    
    public func getFundTransactions(forFund fund: FundDTO, dateFilter: DateFilter?, pagination: PaginationDTO?) throws -> BSANResponse<FundTransactionsListDTO> {
        
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getFundTransactionsAssemble()
        
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let dateFilterToUse: DateFilter
        if let dateFilter = dateFilter {
            dateFilterToUse = dateFilter
        } else {
            dateFilterToUse = generateDateFilter()
        }
        
        guard var contractString = fund.contract?.formattedValue else {
            throw BSANIllegalStateException("Malformed fund contract")
        }
        
        contractString += dateFilterToUse.string
        
        let fundTransactionList = try bsanDataProvider.get(\.fundInfo).fundTransactionsDictionary[contractString]
        
        if let fundTransactionList = fundTransactionList {
            if pagination != nil {
                if fundTransactionList.pagination.endList {
                    return BSANOkResponse(fundTransactionList)
                }
            } else {
                return BSANOkResponse(fundTransactionList)
            }
        }
        
        let request = GetFundTransactionsRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            GetFundTransactionsRequestParams(token: authCredentials.soapTokenCredential,
                                             userDataDTO: userDataDTO,
                                             terminalId: bsanHeaderData.terminalID,
                                             version: bsanHeaderData.version,
                                             language: bsanHeaderData.language,
                                             bankCode: fund.contract?.bankCode ?? "",
                                             branchCode: fund.contract?.branchCode ?? "",
                                             product: fund.contract?.product ?? "",
                                             contractNumber: fund.contract?.contractNumber ?? "",
                                             dateFilter: dateFilterToUse,
                                             currencyType: fund.valueAmount?.currency?.currencyType,
                                             pagination: pagination))
        
        let response: GetFundTransactionsResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK");
            bsanDataProvider.store(fundTransactionsList: response.fundTransactionsDTO, forFundId: contractString)
            // Return last page only (In Android they return all everytime)
            return BSANOkResponse(meta, response.fundTransactionsDTO);
        }
        return BSANErrorResponse(meta);
    }
    
    public func getFundDetail(forFund fundDTO : FundDTO) throws -> BSANResponse<FundDetailDTO>{
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        guard let contractNumber = fundDTO.contract?.formattedValue else {
            throw BSANIllegalStateException("Malformed fund contract")
        }
        
        let fundDetailDTO = try bsanDataProvider.get(\.fundInfo).fundWithDetailDictionary[contractNumber]
        
        if fundDetailDTO != nil{
            return BSANOkResponse(fundDetailDTO)
        }
        
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let request = GetFundDetailRequest(
            BSANAssembleProvider.getFundsAssemble(),
            bsanEnvironment.urlBase,
            GetFundDetailRequestParams(token: authCredentials.soapTokenCredential,
                                       version: bsanHeaderData.version,
                                       terminalId: bsanHeaderData.terminalID,
                                       userDataDTO: userDataDTO,
                                       bankCode: fundDTO.contract?.bankCode ?? "",
                                       branchCode: fundDTO.contract?.branchCode ?? "",
                                       product: fundDTO.contract?.product ?? "",
                                       contractNumber: fundDTO.contract?.contractNumber ?? "",
                                       language: bsanHeaderData.language))
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK");
            bsanDataProvider.store(fundDetail: response.fundDetailDTO, forFund: fundDTO)
            return BSANOkResponse(meta, try bsanDataProvider.get(\.fundInfo).fundWithDetailDictionary[contractNumber]);
        }
        return BSANErrorResponse(meta);
    }
    
    
    public func getFundTransactionDetail(forFund fundDTO : FundDTO, fundTransactionDTO : FundTransactionDTO) throws -> BSANResponse<FundTransactionDetailDTO>{
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        guard let contractNumber = fundTransactionDTO.getFundTransactionKey() else {
            throw BSANIllegalStateException("Malformed fund contract")
        }
        
        let fundTransactionDetailDTO = try bsanDataProvider.get(\.fundInfo).fundTransactionWithDetailDictionary[contractNumber]
        
        if fundTransactionDetailDTO != nil{
            return BSANOkResponse(fundTransactionDetailDTO)
        }
        
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let request = GetFundTransactionDetailRequest(
            BSANAssembleProvider.getFundsAssemble(),
            bsanEnvironment.urlBase,
            GetFundTransactionDetailRequestParams(
                token: authCredentials.soapTokenCredential,
                version: bsanHeaderData.version,
                terminalId: bsanHeaderData.terminalID,
                userDataDTO: userDataDTO,
                bankCode: fundDTO.contract?.bankCode ?? "",
                branchCode: fundDTO.contract?.branchCode ?? "",
                product: fundDTO.contract?.product ?? "",
                contractNumber: fundDTO.contract?.contractNumber ?? "",
                language: bsanHeaderData.language,
                bankOperationCode: fundTransactionDTO.bankOperationCode ?? "",
                applyDate: fundTransactionDTO.applyDate,
                valueDate: fundTransactionDTO.valueDate,
                transactionNumber: fundTransactionDTO.transactionNumber ?? "",
                productSubtypeCode: fundTransactionDTO.productSubtypeCode ?? "",
                value: fundTransactionDTO.amount?.value,
                currencyValue: fundTransactionDTO.amount?.currency?.currencyName ?? "",
                settlementValue: fundTransactionDTO.settlementAmount?.value,
                currencySettlement: fundTransactionDTO.settlementAmount?.currency?.currencyName ?? ""))
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK");
            bsanDataProvider.storeFundTransactionDetail(fundTransactionDetail: response.fundTransactionDetailDTO, forFundTransaction: fundTransactionDTO)
            return BSANOkResponse(meta, try bsanDataProvider.get(\.fundInfo).fundTransactionWithDetailDictionary[contractNumber]);
        }
        return BSANErrorResponse(meta);
    }
    
    public func validateFundSubscriptionAmount(fundDTO: FundDTO, amountDTO: AmountDTO) throws -> BSANResponse<FundSubscriptionDTO> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let request = ValidateFundSubscriptionRequest(
            BSANAssembleProvider.getFundSubscriptionAssemble(),
            bsanEnvironment.urlBase,
            ValidateFundSubscriptionRequestParams(token: authCredentials.soapTokenCredential,
                                                  userDataDTO: userDataDTO,
                                                  bankCode: fundDTO.contract?.bankCode ?? "",
                                                  branchCode: fundDTO.contract?.branchCode ?? "",
                                                  product: fundDTO.contract?.product ?? "",
                                                  contractNumber: fundDTO.contract?.contractNumber ?? "",
                                                  language: bsanHeaderData.languageISO,
                                                  dialect: bsanHeaderData.dialectISO,
                                                  typeSuscription: FundOperationsType.typeAmount,
                                                  amountForWS: "+\(AmountFormats.getValueForWS(value: amountDTO.value))",
                currency: amountDTO.currency?.currencyName ?? "",
                sharesNumber: ""))
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK");
            return BSANOkResponse(meta, response.fundSuscriptionDTO);
        }
        return BSANErrorResponse(meta);
    }
    
    public func validateFundSubscriptionShares(fundDTO: FundDTO, sharesNumber: Decimal) throws -> BSANResponse<FundSubscriptionDTO> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let request = ValidateFundSubscriptionRequest(
            BSANAssembleProvider.getFundSubscriptionAssemble(),
            bsanEnvironment.urlBase,
            ValidateFundSubscriptionRequestParams(token: authCredentials.soapTokenCredential,
                                                  userDataDTO: userDataDTO,
                                                  bankCode: fundDTO.contract?.bankCode ?? "",
                                                  branchCode: fundDTO.contract?.branchCode ?? "",
                                                  product: fundDTO.contract?.product ?? "",
                                                  contractNumber: fundDTO.contract?.contractNumber ?? "",
                                                  language: bsanHeaderData.languageISO,
                                                  dialect: bsanHeaderData.dialectISO,
                                                  typeSuscription: FundOperationsType.typeShares,
                                                  amountForWS: "",
                                                  currency: "",
                                                  sharesNumber: AmountFormats.getSharesFormattedForWS(sharesNumber: sharesNumber)))
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK");
            return BSANOkResponse(meta, response.fundSuscriptionDTO);
        }
        return BSANErrorResponse(meta);
    }
    
    public func confirmFundSubscriptionAmount(fundDTO: FundDTO, amountDTO: AmountDTO, fundSubscriptionDTO: FundSubscriptionDTO, signatureDTO: SignatureDTO) throws -> BSANResponse<FundSubscriptionConfirmDTO> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()

        let request = ConfirmFundSubscriptionRequest(
            BSANAssembleProvider.getFundSubscriptionAssemble(),
            bsanEnvironment.urlBase,
            ConfirmFundSubscriptionRequestParams(token: authCredentials.soapTokenCredential,
                                                 userDataDTO: userDataDTO,
                                                 bankCode: fundDTO.contract?.bankCode ?? "",
                                                 branchCode: fundDTO.contract?.branchCode ?? "",
                                                 product: fundDTO.contract?.product ?? "",
                                                 contractNumber: fundDTO.contract?.contractNumber ?? "",
                                                 language: bsanHeaderData.languageISO,
                                                 dialect: bsanHeaderData.dialectISO,
                                                 typeSuscription: FundOperationsType.typeAmount,
                                                 amountForWS: "+\(AmountFormats.getValueForWS(value: amountDTO.value))",
                currency: amountDTO.currency?.currencyName ?? "",
                sharesNumber: "",
                tokenPasos: fundSubscriptionDTO.tokenPasos ?? "",
                signatureDTO: signatureDTO,
                settlementValueDate: fundSubscriptionDTO.fundSubscriptionResponseData?.settlementValueDate,
                directDebtBankCode: fundSubscriptionDTO.fundSubscriptionResponseData?.directDebtAccountContract?.bankCode ?? "",
                directDebtBranchCode: fundSubscriptionDTO.fundSubscriptionResponseData?.directDebtAccountContract?.branchCode ?? "",
                directDebtProduct: fundSubscriptionDTO.fundSubscriptionResponseData?.directDebtAccountContract?.product ?? "",
                directDebtContractNumber: fundSubscriptionDTO.fundSubscriptionResponseData?.directDebtAccountContract?.contractNumber ?? "",
                languageCode: fundSubscriptionDTO.fundSubscriptionResponseData?.languageCode ?? "",
                accountCurrencyCode: fundSubscriptionDTO.fundSubscriptionResponseData?.accountCurrencyCode ?? "",
                settlementValueAmount: "+\(AmountFormats.getValueForWS5Decs(value: fundSubscriptionDTO.fundSubscriptionResponseData?.settlementValueAmount?.value))",
                settlementCurrencyAmount: fundSubscriptionDTO.fundSubscriptionResponseData?.settlementValueAmount?.currency?.currencyName ?? ""))
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK");
            return BSANOkResponse(meta, response.fundSubscriptionConfirmDTO);
        }
        return BSANErrorResponse(meta);
    }
    
    public func confirmFundSubscriptionShares(fundDTO: FundDTO, sharesNumber: Decimal, fundSubscriptionDTO: FundSubscriptionDTO, signatureDTO: SignatureDTO) throws -> BSANResponse<FundSubscriptionConfirmDTO> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let request = ConfirmFundSubscriptionRequest(
            BSANAssembleProvider.getFundSubscriptionAssemble(),
            bsanEnvironment.urlBase,
            ConfirmFundSubscriptionRequestParams(token: authCredentials.soapTokenCredential,
                                                 userDataDTO: userDataDTO,
                                                 bankCode: fundDTO.contract?.bankCode ?? "",
                                                 branchCode: fundDTO.contract?.branchCode ?? "",
                                                 product: fundDTO.contract?.product ?? "",
                                                 contractNumber: fundDTO.contract?.contractNumber ?? "",
                                                 language: bsanHeaderData.languageISO,
                                                 dialect: bsanHeaderData.dialectISO,
                                                 typeSuscription: FundOperationsType.typeShares,
                                                 amountForWS: "",
                                                 currency: "",
                                                 sharesNumber: AmountFormats.getSharesFormattedForWS(sharesNumber: sharesNumber),
                                                 tokenPasos: fundSubscriptionDTO.tokenPasos ?? "",
                                                 signatureDTO: signatureDTO,
                                                 settlementValueDate: fundSubscriptionDTO.fundSubscriptionResponseData?.settlementValueDate,
                                                 directDebtBankCode: fundSubscriptionDTO.fundSubscriptionResponseData?.directDebtAccountContract?.bankCode ?? "",
                                                 directDebtBranchCode: fundSubscriptionDTO.fundSubscriptionResponseData?.directDebtAccountContract?.branchCode ?? "",
                                                 directDebtProduct: fundSubscriptionDTO.fundSubscriptionResponseData?.directDebtAccountContract?.product ?? "",
                                                 directDebtContractNumber: fundSubscriptionDTO.fundSubscriptionResponseData?.directDebtAccountContract?.contractNumber ?? "",
                                                 languageCode: fundSubscriptionDTO.fundSubscriptionResponseData?.languageCode ?? "",
                                                 accountCurrencyCode: fundSubscriptionDTO.fundSubscriptionResponseData?.accountCurrencyCode ?? "",
                                                 settlementValueAmount: "+\(AmountFormats.getValueForWS5Decs(value: fundSubscriptionDTO.fundSubscriptionResponseData?.settlementValueAmount?.value))",
                settlementCurrencyAmount: fundSubscriptionDTO.fundSubscriptionResponseData?.settlementValueAmount?.currency?.currencyName ?? ""))
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK");
            return BSANOkResponse(meta, response.fundSubscriptionConfirmDTO);
        }
        return BSANErrorResponse(meta);
    }
    
    public func validateFundTransferTotal(originFundDTO: FundDTO, destinationFundDTO: FundDTO) throws -> BSANResponse<FundTransferDTO> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let request = ValidateFundTransferRequest(
            BSANAssembleProvider.getFundTransferAssemble(),
            bsanEnvironment.urlBase,
            ValidateFundTransferRequestParams(token: authCredentials.soapTokenCredential,
                                              userDataDTO: userDataDTO,
                                              destinationBankCode: destinationFundDTO.contract?.bankCode ?? "",
                                              destinationBranchCode: destinationFundDTO.contract?.branchCode ?? "",
                                              destinationProduct: destinationFundDTO.contract?.product ?? "",
                                              destinationContractNumber: destinationFundDTO.contract?.contractNumber ?? "",
                                              originBankCode: originFundDTO.contract?.bankCode ?? "",
                                              originBranchCode: originFundDTO.contract?.branchCode ?? "",
                                              originProduct: originFundDTO.contract?.product ?? "",
                                              originContractNumber: originFundDTO.contract?.contractNumber ?? "",
                                              originCompany: originFundDTO.productSubtypeDTO?.company ?? "",
                                              originProductType: originFundDTO.productSubtypeDTO?.productType ?? "",
                                              originProductSubType: originFundDTO.productSubtypeDTO?.productSubtype ?? "",
                                              language: bsanHeaderData.languageISO,
                                              dialect: bsanHeaderData.dialectISO,
                                              operationsType: FundOperationsType.typeNone,
                                              fundTransferType: FundTransferType.typeTotal,
                                              amountForWS: "",
                                              currency: "",
                                              sharesNumber: "",
                                              originAmountValueWS: AmountFormats.getValueForWS(value: originFundDTO.valueAmount?.value),
                                              originAmountCurrency: originFundDTO.valueAmount?.currency?.currencyName ?? ""))
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK");
            return BSANOkResponse(meta, response.fundTransferDTO);
        }
        return BSANErrorResponse(meta);
    }
    
    public func validateFundTransferPartialByAmount(originFundDTO: FundDTO, destinationFundDTO: FundDTO, amountDTO: AmountDTO) throws -> BSANResponse<FundTransferDTO> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let request = ValidateFundTransferRequest(
            BSANAssembleProvider.getFundTransferAssemble(),
            bsanEnvironment.urlBase,
            ValidateFundTransferRequestParams(token: authCredentials.soapTokenCredential,
                                              userDataDTO: userDataDTO,
                                              destinationBankCode: destinationFundDTO.contract?.bankCode ?? "",
                                              destinationBranchCode: destinationFundDTO.contract?.branchCode ?? "",
                                              destinationProduct: destinationFundDTO.contract?.product ?? "",
                                              destinationContractNumber: destinationFundDTO.contract?.contractNumber ?? "",
                                              originBankCode: originFundDTO.contract?.bankCode ?? "",
                                              originBranchCode: originFundDTO.contract?.branchCode ?? "",
                                              originProduct: originFundDTO.contract?.product ?? "",
                                              originContractNumber: originFundDTO.contract?.contractNumber ?? "",
                                              originCompany: originFundDTO.productSubtypeDTO?.company ?? "",
                                              originProductType: originFundDTO.productSubtypeDTO?.productType ?? "",
                                              originProductSubType: originFundDTO.productSubtypeDTO?.productSubtype ?? "",
                                              language: bsanHeaderData.languageISO,
                                              dialect: bsanHeaderData.dialectISO,
                                              operationsType: FundOperationsType.typeAmount,
                                              fundTransferType: FundTransferType.typePartial,
                                              amountForWS: "+\(AmountFormats.getValueForWS(value: amountDTO.value))",
                currency: amountDTO.currency?.currencyName ?? "",
                sharesNumber: "",
                originAmountValueWS: AmountFormats.getValueForWS(value: originFundDTO.valueAmount?.value),
                originAmountCurrency: originFundDTO.valueAmount?.currency?.currencyName ?? ""))
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK");
            return BSANOkResponse(meta, response.fundTransferDTO);
        }
        return BSANErrorResponse(meta);
    }
    
    public func validateFundTransferPartialByShares(originFundDTO: FundDTO, destinationFundDTO: FundDTO, sharesNumber: Decimal) throws -> BSANResponse<FundTransferDTO> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let request = ValidateFundTransferRequest(
            BSANAssembleProvider.getFundTransferAssemble(),
            bsanEnvironment.urlBase,
            ValidateFundTransferRequestParams(token: authCredentials.soapTokenCredential,
                                              userDataDTO: userDataDTO,
                                              destinationBankCode: destinationFundDTO.contract?.bankCode ?? "",
                                              destinationBranchCode: destinationFundDTO.contract?.branchCode ?? "",
                                              destinationProduct: destinationFundDTO.contract?.product ?? "",
                                              destinationContractNumber: destinationFundDTO.contract?.contractNumber ?? "",
                                              originBankCode: originFundDTO.contract?.bankCode ?? "",
                                              originBranchCode: originFundDTO.contract?.branchCode ?? "",
                                              originProduct: originFundDTO.contract?.product ?? "",
                                              originContractNumber: originFundDTO.contract?.contractNumber ?? "",
                                              originCompany: originFundDTO.productSubtypeDTO?.company ?? "",
                                              originProductType: originFundDTO.productSubtypeDTO?.productType ?? "",
                                              originProductSubType: originFundDTO.productSubtypeDTO?.productSubtype ?? "",
                                              language: bsanHeaderData.languageISO,
                                              dialect: bsanHeaderData.dialectISO,
                                              operationsType: FundOperationsType.typeShares,
                                              fundTransferType: FundTransferType.typePartial,
                                              amountForWS: "",
                                              currency: "",
                                              sharesNumber: AmountFormats.getSharesFormattedForWS(sharesNumber: sharesNumber),
                                              originAmountValueWS: AmountFormats.getValueForWS(value: originFundDTO.valueAmount?.value),
                                              originAmountCurrency: originFundDTO.valueAmount?.currency?.currencyName ?? ""))
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK");
            return BSANOkResponse(meta, response.fundTransferDTO);
        }
        return BSANErrorResponse(meta);
    }
    
    public func confirmFundTransferTotal(originFundDTO: FundDTO, destinationFundDTO: FundDTO, fundTransferDTO: FundTransferDTO, signatureDTO: SignatureDTO) throws -> BSANResponse<Void> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let request = ConfirmFundTransferRequest(
            BSANAssembleProvider.getFundTransferAssemble(),
            bsanEnvironment.urlBase,
            ConfirmFundTransferRequestParams(token: authCredentials.soapTokenCredential,
                                             tokenPasos: fundTransferDTO.tokenPasos ?? "",
                                             personType: fundTransferDTO.fundTransferResponseData?.accessPersonNumber?.personType ?? "",
                                             personCode: fundTransferDTO.fundTransferResponseData?.accessPersonNumber?.personCode ?? "",
                                             destinationFundCode: fundTransferDTO.fundTransferResponseData?.destinationFundCode ?? "",
                                             destinationFundName: fundTransferDTO.fundTransferResponseData?.destinationFundName ?? "",
                                             valueDate: fundTransferDTO.fundTransferResponseData?.valueDate,
                                             transferTypeByManagingCompany: fundTransferDTO.fundTransferResponseData?.transferTypeByManagingCompany ?? "",
                                             quantityToSplit: fundTransferDTO.fundTransferResponseData?.quantityToSplit ?? "",
                                             originIsinCode: fundTransferDTO.fundTransferResponseData?.originIsinCode ?? "",
                                             originManagingCompanyCIF: fundTransferDTO.fundTransferResponseData?.originManagingCompanyCIF ?? "",
                                             partialTransferQuantity: fundTransferDTO.fundTransferResponseData?.partialTransferQuantity ?? "",
                                             counter: fundTransferDTO.fundTransferResponseData?.counter ?? "",
                                             transferShares: fundTransferDTO.fundTransferResponseData?.transferShares ?? "",
                                             debitSharesBalance: fundTransferDTO.fundTransferResponseData?.debitSharesBalance ?? "",
                                             currencyWorkaround: "EUR",
                                             signatureDTO: signatureDTO,
                                             userDataDTO: userDataDTO,
                                             destinationBankCode: destinationFundDTO.contract?.bankCode ?? "",
                                             destinationBranchCode: destinationFundDTO.contract?.branchCode ?? "",
                                             destinationProduct: destinationFundDTO.contract?.product ?? "",
                                             destinationContractNumber: destinationFundDTO.contract?.contractNumber ?? "",
                                             originBankCode: originFundDTO.contract?.bankCode ?? "",
                                             originBranchCode: originFundDTO.contract?.branchCode ?? "",
                                             originProduct: originFundDTO.contract?.product ?? "",
                                             originContractNumber: originFundDTO.contract?.contractNumber ?? "",
                                             language: bsanHeaderData.languageISO,
                                             dialect: bsanHeaderData.dialectISO,
                                             operationsType: FundOperationsType.typeNone,
                                             fundTransferType: FundTransferType.typeTotal,
                                             amountForWS: "",
                                             sharesNumber: fundTransferDTO.fundTransferResponseData?.fundShares ?? "",
                                             availableAmountValueWS: AmountFormats.getValueForWS(value: fundTransferDTO.fundTransferResponseData?.fundCurrencyAvailableAmount?.value),
                                             availableAmountCurrency: fundTransferDTO.fundTransferResponseData?.fundCurrencyAvailableAmount?.currency?.currencyName ?? ""))
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK");
            return BSANOkResponse(meta)
        }
        return BSANErrorResponse(meta);
    }
    
    public func confirmFundTransferPartialByAmount(originFundDTO: FundDTO, destinationFundDTO: FundDTO, fundTransferDTO: FundTransferDTO, amountDTO: AmountDTO, signatureDTO: SignatureDTO) throws -> BSANResponse<Void> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let request = ConfirmFundTransferRequest(
            BSANAssembleProvider.getFundTransferAssemble(),
            bsanEnvironment.urlBase,
            ConfirmFundTransferRequestParams(token: authCredentials.soapTokenCredential,
                                             tokenPasos: fundTransferDTO.tokenPasos ?? "",
                                             personType: fundTransferDTO.fundTransferResponseData?.accessPersonNumber?.personType ?? "",
                                             personCode: fundTransferDTO.fundTransferResponseData?.accessPersonNumber?.personCode ?? "",
                                             destinationFundCode: fundTransferDTO.fundTransferResponseData?.destinationFundCode ?? "",
                                             destinationFundName: fundTransferDTO.fundTransferResponseData?.destinationFundName ?? "",
                                             valueDate: fundTransferDTO.fundTransferResponseData?.valueDate,
                                             transferTypeByManagingCompany: fundTransferDTO.fundTransferResponseData?.transferTypeByManagingCompany ?? "",
                                             quantityToSplit: fundTransferDTO.fundTransferResponseData?.quantityToSplit ?? "",
                                             originIsinCode: fundTransferDTO.fundTransferResponseData?.originIsinCode ?? "",
                                             originManagingCompanyCIF: fundTransferDTO.fundTransferResponseData?.originManagingCompanyCIF ?? "",
                                             partialTransferQuantity: fundTransferDTO.fundTransferResponseData?.partialTransferQuantity ?? "",
                                             counter: fundTransferDTO.fundTransferResponseData?.counter ?? "",
                                             transferShares: fundTransferDTO.fundTransferResponseData?.transferShares ?? "",
                                             debitSharesBalance: fundTransferDTO.fundTransferResponseData?.debitSharesBalance ?? "",
                                             currencyWorkaround: "EUR",
                                             signatureDTO: signatureDTO,
                                             userDataDTO: userDataDTO,
                                             destinationBankCode: destinationFundDTO.contract?.bankCode ?? "",
                                             destinationBranchCode: destinationFundDTO.contract?.branchCode ?? "",
                                             destinationProduct: destinationFundDTO.contract?.product ?? "",
                                             destinationContractNumber: destinationFundDTO.contract?.contractNumber ?? "",
                                             originBankCode: originFundDTO.contract?.bankCode ?? "",
                                             originBranchCode: originFundDTO.contract?.branchCode ?? "",
                                             originProduct: originFundDTO.contract?.product ?? "",
                                             originContractNumber: originFundDTO.contract?.contractNumber ?? "",
                                             language: bsanHeaderData.languageISO,
                                             dialect: bsanHeaderData.dialectISO,
                                             operationsType: FundOperationsType.typeAmount,
                                             fundTransferType: FundTransferType.typePartial,
                                             amountForWS: "+\(AmountFormats.getValueForWS(value: amountDTO.value))",
                sharesNumber: "",
                availableAmountValueWS: AmountFormats.getValueForWS(value: fundTransferDTO.fundTransferResponseData?.fundCurrencyAvailableAmount?.value),
                availableAmountCurrency: fundTransferDTO.fundTransferResponseData?.fundCurrencyAvailableAmount?.currency?.currencyName ?? ""))
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK");
            return BSANOkResponse(meta)
        }
        return BSANErrorResponse(meta);
    }
    
    public func confirmFundTransferPartialByShares(originFundDTO: FundDTO, destinationFundDTO: FundDTO, fundTransferDTO: FundTransferDTO, signatureDTO: SignatureDTO) throws -> BSANResponse<Void> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let request = ConfirmFundTransferRequest(
            BSANAssembleProvider.getFundTransferAssemble(),
            bsanEnvironment.urlBase,
            ConfirmFundTransferRequestParams(token: authCredentials.soapTokenCredential,
                                             tokenPasos: fundTransferDTO.tokenPasos ?? "",
                                             personType: fundTransferDTO.fundTransferResponseData?.accessPersonNumber?.personType ?? "",
                                             personCode: fundTransferDTO.fundTransferResponseData?.accessPersonNumber?.personCode ?? "",
                                             destinationFundCode: fundTransferDTO.fundTransferResponseData?.destinationFundCode ?? "",
                                             destinationFundName: fundTransferDTO.fundTransferResponseData?.destinationFundName ?? "",
                                             valueDate: fundTransferDTO.fundTransferResponseData?.valueDate,
                                             transferTypeByManagingCompany: fundTransferDTO.fundTransferResponseData?.transferTypeByManagingCompany ?? "",
                                             quantityToSplit: fundTransferDTO.fundTransferResponseData?.quantityToSplit ?? "",
                                             originIsinCode: fundTransferDTO.fundTransferResponseData?.originIsinCode ?? "",
                                             originManagingCompanyCIF: fundTransferDTO.fundTransferResponseData?.originManagingCompanyCIF ?? "",
                                             partialTransferQuantity: fundTransferDTO.fundTransferResponseData?.partialTransferQuantity ?? "",
                                             counter: fundTransferDTO.fundTransferResponseData?.counter ?? "",
                                             transferShares: fundTransferDTO.fundTransferResponseData?.transferShares ?? "",
                                             debitSharesBalance: fundTransferDTO.fundTransferResponseData?.debitSharesBalance ?? "",
                                             currencyWorkaround: "EUR",
                                             signatureDTO: signatureDTO,
                                             userDataDTO: userDataDTO,
                                             destinationBankCode: destinationFundDTO.contract?.bankCode ?? "",
                                             destinationBranchCode: destinationFundDTO.contract?.branchCode ?? "",
                                             destinationProduct: destinationFundDTO.contract?.product ?? "",
                                             destinationContractNumber: destinationFundDTO.contract?.contractNumber ?? "",
                                             originBankCode: originFundDTO.contract?.bankCode ?? "",
                                             originBranchCode: originFundDTO.contract?.branchCode ?? "",
                                             originProduct: originFundDTO.contract?.product ?? "",
                                             originContractNumber: originFundDTO.contract?.contractNumber ?? "",
                                             language: bsanHeaderData.languageISO,
                                             dialect: bsanHeaderData.dialectISO,
                                             operationsType: FundOperationsType.typeShares,
                                             fundTransferType: FundTransferType.typePartial,
                                             amountForWS: "",
                                             sharesNumber: fundTransferDTO.fundTransferResponseData?.fundShares ?? "",
                                             availableAmountValueWS: AmountFormats.getValueForWS(value: fundTransferDTO.fundTransferResponseData?.fundCurrencyAvailableAmount?.value),
                                             availableAmountCurrency: fundTransferDTO.fundTransferResponseData?.fundCurrencyAvailableAmount?.currency?.currencyName ?? ""))
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK");
            return BSANOkResponse(meta)
        }
        return BSANErrorResponse(meta);
    }
    
    public func changeFundAlias(_ fund: FundDTO, newAlias: String) throws -> BSANResponse<Void> {
        return BSANErrorResponse(nil)
    }
}
