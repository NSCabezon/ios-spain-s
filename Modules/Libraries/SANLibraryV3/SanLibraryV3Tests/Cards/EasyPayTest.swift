import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class EasyPayTest: BaseLibraryTests {
    typealias T = CardDTO
    
    override func setUp() {
        setLoginUser(newLoginUser: LOGIN_USER.NEW_FEES)
        resetDataRepository()
        super.setUp()
    }
    
    override func getElements<T>(_ sessionData: SessionData) -> [T]? {
        return sessionData.globalPositionDTO.cards as? [T]
    }
    
    func testTransactionsEasyPayContract() {
        
        do{
            
            //setUp(loginUser: LOGIN_USER.BUY_FEES_EASYPAY, pbToSet: nil)

            guard let card: CardDTO = getElementForTesting(orderInArray: 2, function: #function) else{
                return
            }
            
            let cardTransactionsResponse = try bsanCardsManager!.getCardTransactions(cardDTO: card, pagination: nil, dateFilter: nil)
            
            guard let cardTransactions = try getResponseData(response: cardTransactionsResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            let indexToTake = 2
            
            if cardTransactions.transactionDTOs.count-1 < indexToTake{
                logTestError(errorMessage: "wrong transactionDTOs index", function: #function)
                return
            }
            
            let cardTransaction = cardTransactions.transactionDTOs[indexToTake]
            
            let getTransactionsEasyPayContractResponse = try bsanCardsManager!.getTransactionsEasyPayContract(cardDTO: card, pagination: nil, dateFilter: generateDateFilter(cardTransactionDTO: cardTransaction))

            guard let getTransactionsEasyPayContract = try getResponseData(response: getTransactionsEasyPayContractResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: getTransactionsEasyPayContract, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testTransactionDetailEasyPay() {
        
        do{
            
            guard let card: CardDTO = getElementForTesting(orderInArray: 2, function: #function) else{
                return
            }
            
            let _ = try bsanCardsManager!.loadCardDetail(cardDTO: card)
            
            let cardDetailResponse = try bsanCardsManager!.getCardDetail(cardDTO: card)
            
            guard let cardDetail = try getResponseData(response: cardDetailResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            let cardTransactionsResponse = try bsanCardsManager!.getCardTransactions(cardDTO: card, pagination: nil, dateFilter: nil)
            
            guard let cardTransactions = try getResponseData(response: cardTransactionsResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            let indexToTake = 2
            
            if cardTransactions.transactionDTOs.count-1 < indexToTake{
                logTestError(errorMessage: "wrong transactionDTOs index", function: #function)
                return
            }
            
            let cardTransaction = cardTransactions.transactionDTOs[indexToTake]
            
            let cardTransactionDetailResponse = try bsanCardsManager!.getCardTransactionDetail(cardDTO: card, cardTransactionDTO: cardTransaction)
            
            guard let cardTransactionDetail = try getResponseData(response: cardTransactionDetailResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            let getTransactionsEasyPayContractResponse = try bsanCardsManager!.getTransactionsEasyPayContract(cardDTO: card, pagination: nil, dateFilter: generateDateFilter(cardTransactionDTO: cardTransaction))
            
            guard let getTransactionsEasyPayContract = try getResponseData(response: getTransactionsEasyPayContractResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let easyPayContractTransactionDTOS = getTransactionsEasyPayContract.easyPayContractTransactionDTOS else{
                logTestError(errorMessage: "wrong transactionDTOs index", function: #function)
                return
            }
            
            let pk = generateTransactionPK(cardTransactionDTO: cardTransaction)
            
            if let easyPayContractTransaction = easyPayContractTransactionDTOS.filter({generateEasyPayPK(easyPayContractTransactionDTO: $0) == pk}).first{
                let getTransactionDetailEasyPayResponse = try bsanCardsManager!.getTransactionDetailEasyPay(cardDTO: card, cardDetailDTO: cardDetail, cardTransactionDTO: cardTransaction, cardTransactionDetailDTO: cardTransactionDetail, easyPayContractTransactionDTO: easyPayContractTransaction)

                guard let getTransactionDetailEasyPay = try getResponseData(response: getTransactionDetailEasyPayResponse) else {
                    logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                    return
                }
                
                logTestSuccess(result: getTransactionDetailEasyPay, function: #function)
                return
            }
            
            logTestError(errorMessage: "NO easyPayContractTransactionDTOS WITH PK FOUND", function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetCurrentEasyPayFeeWithCardDTOAndEasyPayContract() {
        do {
            
            let cardPositionForEasyPayUser = 18
            guard let card: CardDTO = getElementForTesting(orderInArray: cardPositionForEasyPayUser , function: #function) else{
                return
            }
            
            let cardTransactionsResponse = try bsanCardsManager!.getCardTransactions(cardDTO: card, pagination: nil, dateFilter: nil)
            
            guard let cardTransactions = try getResponseData(response: cardTransactionsResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            let indexOfFraccinableMovementForCard = 13
            let indexToTake = indexOfFraccinableMovementForCard
            
            if cardTransactions.transactionDTOs.count-1 < indexToTake{
                logTestError(errorMessage: "wrong transactionDTOs index", function: #function)
                return
            }
            
            let cardTransaction = cardTransactions.transactionDTOs[indexToTake-1]
            
            let getTransactionsEasyPayContractResponse = try bsanCardsManager!.getTransactionsEasyPayContract(cardDTO: card, pagination: nil, dateFilter: generateDateFilter(cardTransactionDTO: cardTransaction))

            guard let getTransactionsEasyPayContract = try getResponseData(response: getTransactionsEasyPayContractResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            let transaction = getTransactionsEasyPayContract.easyPayContractTransactionDTOS?[0]
            
            guard let balanceCode = transaction?.balanceCode, let transactionDay = transaction?.transactionDay else {
                logTestError(errorMessage: "BALANCE CODE OR TRANSACTION DAY", function: #function)
                return
            }
            
            let parameters = BuyFeesParameters(numFees: 4, balanceCode: balanceCode, transactionDay: transactionDay)
            
            guard let getBuyFeesResponse = try bsanCardsManager!.getEasyPayFees(input: parameters,
                                                                                card: card).getResponseData() else {
                logTestError(errorMessage: "NO FEES INFO", function: #function)
                return
            }
            
            logTestSuccess(result: getBuyFeesResponse, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    private func generateTransactionPK(cardTransactionDTO: CardTransactionDTO) -> String {
        return "\(cardTransactionDTO.description?.trim() ?? "") \(cardTransactionDTO.operationDate?.description ?? "") \(cardTransactionDTO.amount?.value?.magnitude ?? Decimal(0)) \(cardTransactionDTO.amount?.currency?.currencyName ?? "") \(cardTransactionDTO.transactionDay ?? "")"
    }
    
    private func generateEasyPayPK(easyPayContractTransactionDTO: EasyPayContractTransactionDTO) -> String {
        return "\(easyPayContractTransactionDTO.rateName?.trim() ?? "")\(easyPayContractTransactionDTO.operationDate?.description ?? ""))\(easyPayContractTransactionDTO.amountDTO?.value ?? Decimal(0))\(easyPayContractTransactionDTO.amountDTO?.currency?.currencyName ?? "")\(easyPayContractTransactionDTO.transactionDay ?? "")"
    }
    
    private func generateDateFilter(cardTransactionDTO: CardTransactionDTO) -> DateFilter {
        let dateFilter = DateFilter()
        if let operationDate = cardTransactionDTO.operationDate {
            dateFilter.fromDateModel = DateModel(date: operationDate)
            dateFilter.toDateModel = DateModel(date: cardTransactionDTO.annotationDate!)
        }
        return dateFilter
    }
    
//    private func getEasyPayContractTransactionList(cardDTO: CardDTO, dateFilter: DateFilter) throws -> EasyPayContractTransactionListDTO{
//        var response = try bsanCardsManager!.getTransactionsEasyPayContract(cardDTO: cardDTO, pagination: nil, dateFilter: dateFilter)
//        
//        guard var responseData = try getResponseData(response: response) else {
//            throw BSANException("RETURNED NO RESPONSE DATA")
//        }
//        
//        if "0" == (try response.getErrorCode()){
//            while responseData.pagination != nil && responseData.pagination!.endList {
//                response = try bsanCardsManager!.getTransactionsEasyPayContract(cardDTO: cardDTO, pagination: responseData.pagination!, dateFilter: dateFilter)
//                
//                guard let responseDataWhile = try getResponseData(response: response) else {
//                    throw BSANException("RETURNED NO RESPONSE DATA")
//                }
//                
//                if "0" == (try response.getErrorCode()){
//                    let easyPayContractTransactionDTOS = responseDataWhile.easyPayContractTransactionDTOS!
//                    for easyPayContractTransactionDTO in easyPayContractTransactionDTOS {
//                        responseData.easyPayContractTransactionDTOS!.append(easyPayContractTransactionDTO)
//                    }
//                    
//                    if easyPayContractTransactionDTOS.count <= 1 {
//                        return responseData
//                    }
//                    
//                } else {
//                    return responseDataWhile
//                }
//                
//            }
//        }
//        
//        return responseData
//    }
    
    func testConfirmEasyPayNewPurchaseOperative() {
        do {
            let cardPositionForEasyPayUser = 6
            guard let card: CardDTO = getElementForTesting(orderInArray: cardPositionForEasyPayUser , function: #function) else{
                return
            }
            
            let cardTransactionsResponse = try bsanCardsManager!.getCardTransactions(cardDTO: card, pagination: nil, dateFilter: nil)
            guard let cardTransactions = try getResponseData(response: cardTransactionsResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            let indexToTake = 2
            let cardTransaction = cardTransactions.transactionDTOs[indexToTake]
            let getTransactionsEasyPayContractResponse = try bsanCardsManager!.getTransactionsEasyPayContract(cardDTO: card, pagination: nil, dateFilter: generateDateFilter(cardTransactionDTO: cardTransaction))
            guard let getTransactionsEasyPayContract = try getResponseData(response: getTransactionsEasyPayContractResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            let transaction = getTransactionsEasyPayContract.easyPayContractTransactionDTOS?[0]
            guard let balanceCode = transaction?.balanceCode, let transactionDay = transaction?.transactionDay else {
                logTestError(errorMessage: "BALANCE CODE OR TRANSACTION DAY", function: #function)
                return
            }
            
            let parameters = BuyFeesParameters(numFees: 2, balanceCode: balanceCode, transactionDay: transactionDay)
            let response = try bsanCardsManager!.confirmationEasyPay(input: parameters, card: card)
            guard response.isSuccess() else {
                let error = try response.getErrorCode()
                let errorMessage = try response.getErrorMessage()
                logTestError(errorMessage: "errorCode: \(error), errorMessage: \(String(describing: errorMessage))", function: #function)
                return
            }
            let data = try getResponseData(response: getTransactionsEasyPayContractResponse)
            logTestSuccess(result: data, function: #function)
        } catch let error {
            logTestException(error: error, function: #function)
        }
    }
}
