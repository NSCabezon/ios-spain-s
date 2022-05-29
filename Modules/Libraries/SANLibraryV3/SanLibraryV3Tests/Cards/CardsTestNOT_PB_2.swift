import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class CardsTestsNOT_PB_2: BaseLibraryTests {
    typealias T = CardDTO
    
    override func setUp() {
        setLoginUser(newLoginUser: LOGIN_USER.DEPOSITS_LOGIN)
        resetDataRepository()
        super.setUp()
    }
    
    override func getElements<T>(_ sessionData: SessionData) -> [T]? {
        return sessionData.globalPositionDTO.cards as? [T]
    }
    
    func testGetCardTransactionsRequest(){
        
        do{
            
            setUp(loginUser: LOGIN_USER.iñaki, pbToSet: nil)

            guard let card: CardDTO = getElementForTesting(orderInArray: 2, function: #function) else{
                return
            }
            
            let getCardTransactionsResponse = try bsanCardsManager!.getCardTransactions(cardDTO: card, pagination: nil, dateFilter: nil)
            
            guard let cardTransactionsResponse = try getResponseData(response: getCardTransactionsResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: cardTransactionsResponse, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetCardTransactionsRequestWithPagination(){
        
        do{

            guard let card: CardDTO = getElementForTesting(orderInArray: 1, function: #function) else{
                return
            }
            
            let getCardTransactionsResponse = try bsanCardsManager!.getCardTransactions(cardDTO: card, pagination: nil, dateFilter: nil)
            
            guard let cardTransactionsResponse = try getResponseData(response: getCardTransactionsResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            print("\n\n\(#function) :\n\(cardTransactionsResponse)")
            
            let getCardTransactionsResponseSecond = try bsanCardsManager!.getCardTransactions(cardDTO: card, pagination: cardTransactionsResponse.pagination, dateFilter: nil)
            
            guard let cardTransactionsResponseSecond = try getResponseData(response: getCardTransactionsResponseSecond) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: cardTransactionsResponseSecond, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetCardTransactionDetailRequest(){
        
        do{
            
            setUp(loginUser: LOGIN_USER.iñaki, pbToSet: nil)
            
            guard let card: CardDTO = getElementForTesting(orderInArray: 2, function: #function) else{
                return
            }
            
            let getCardTransactionsResponse = try bsanCardsManager!.getCardTransactions(cardDTO: card, pagination: nil, dateFilter: nil)
            
            guard let cardTransactionsResponse = try getResponseData(response: getCardTransactionsResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            if cardTransactionsResponse.transactionDTOs.count == 0{
                logTestError(errorMessage: "getCardTransactions RETURNED NO transactionDTOs", function: #function)
                return
            }
            
            let getCardTransactionDetailResponse = try bsanCardsManager!.getCardTransactionDetail(cardDTO: card, cardTransactionDTO: cardTransactionsResponse.transactionDTOs.first!)
            
            guard let getCardTransactionDetail = try getResponseData(response: getCardTransactionDetailResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: getCardTransactionDetail, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
//    func testActivateCardConfirmRequest(){
//        
//        do{
//            
//            guard let card: CardDTO = getElementForTesting(orderInArray: 27, function: #function) else{
//                return
//            }
//            
//            let _ = try bsanCardsManager!.loadInactiveCards(inactiveCardType: InactiveCardType.inactive)
//            
//            let loadInactiveCardsResponse = try bsanCardsManager!.getInactiveCardsMap()
//            
//            guard let inactiveCards = try getResponseData(response: loadInactiveCardsResponse) else {
//                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
//                return
//            }
//            
//            guard let inactiveCard = inactiveCards.first?.value else {
//                logTestError(errorMessage: "RETURNED NO INACTIVE CARDS", function: #function)
//                return
//            }
//            
//            guard let expirationDate = inactiveCard.expirationDate else{
//                logTestError(errorMessage: "RETURNED NO VALID EXPIRATION DATE", function: #function)
//                return
//            }
//            
//            let activateCardResponse = try bsanCardsManager!.activateCard(cardDTO: card, expirationDate: expirationDate)
//            
//            guard let activateCard = try getResponseData(response: activateCardResponse) else {
//                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
//                return
//            }
//            
//            print("\n\n\(#function) :\n\(activateCard)")
//            
//            var signatureDTO = activateCard.signature
//            TestUtils.fillSignature(input: &signatureDTO)
//            
//            let activateCardConfirmResponse = try bsanCardsManager!.confirmActivateCard(cardDTO: card, expirationDate: expirationDate, signatureDTO: signatureDTO!)
//            
//            //TODO: HACER COMPROBACION LLAMANDO AL SERVICIO TARJETAS INACTIVAS PARA VER SI SE HA DESACTIVADO
//            
//            print("\n\n\(#function) :\n\(activateCardConfirmResponse.isSuccess())")
//            XCTAssert(activateCardConfirmResponse.isSuccess())
//            
//        } catch let error{
//            logTestException(error: error, function: #function)
//        }
//    }
    
    func testCardPendingTransactionsDetail(){
        
        do{
            
            guard let card: CardDTO = getElementForTesting(orderInArray: 2, function: #function) else{
                return
            }

            let response = try bsanCardsManager!.getCardPendingTransactions(cardDTO: card, pagination: nil)

            guard let responseData = try getResponseData(response: response) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }

            logTestSuccess(result: responseData.cardPendingTransactionDTOS, function: #function)
            
            
        } catch let error {
            logTestException(error: error, function: #function)
        }
    }
    
    func testChangePaymentMethod() {
        guard let card: CardDTO = getElementForTesting(orderInArray: 11, function: #function) else{
            return
        }
        
        do {
            
            let response = try bsanCardsManager!.getPaymentChange(cardDTO: card)
            
            guard let responseData = try getResponseData(response: response) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: responseData, function: #function)
        } catch let error {
            logTestException(error: error, function: #function)
        }
    }
    
    func testChangePaymentMethodConfirmation() {
        guard let card: CardDTO = getElementForTesting(orderInArray: 11, function: #function) else{
            return
        }
        
        do {
            
            let response = try bsanCardsManager!.getPaymentChange(cardDTO: card)
            
            guard let responseData = try getResponseData(response: response) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA ON PAYMENT CHANGE", function: #function)
                return
            }
            
            guard let referenceStandard = responseData.referenceStandard, let hiddenReferenceStandard = responseData.hiddenReferenceStandard, let currentPaymentMethod = responseData.currentPaymentMethod, let currentPaymentMethodMode = responseData.currentPaymentMethodMode, let currentSettlementType = responseData.currentSettlementType, let hiddenPaymentMethodMode = responseData.hiddenPaymentMethodMode, let methodList = responseData.paymentMethodList else {
                logTestError(errorMessage: "SOME DATA IS NIL", function: #function)
                return
            }
            
            let selectedAmount = AmountDTO(value: 25, currency: .create(.eur))
            
            let selectedPaymentMethod = methodList[1]
            
            let input = ChangePaymentMethodConfirmationInput(referenceStandard: referenceStandard, hiddenReferenceStandard: hiddenReferenceStandard, selectedAmount: selectedAmount, currentPaymentMethod: currentPaymentMethod, currentPaymentMethodMode: currentPaymentMethodMode, currentSettlementType: currentSettlementType, marketCode: responseData.marketCode, hiddenMarketCode: responseData.hiddenMarketCode, hiddenPaymentMethodMode: hiddenPaymentMethodMode, selectedPaymentMethod: selectedPaymentMethod)
            
            
            let confirmation = try bsanCardsManager!.confirmPaymentChange(cardDTO: card, input: input)
            
            guard confirmation.isSuccess() else {
                logTestError(errorMessage: "CONFIRMATION FAILED", function: #function)
                return
            }
            
            logTestSuccess(result: confirmation.isSuccess(), function: #function)
        } catch let error {
            logTestException(error: error, function: #function)
        }
    }
}
