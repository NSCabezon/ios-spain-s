import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class PrepaidCardsTests: BaseLibraryTests {
    typealias T = CardDTO
    
    var getAccountFromGP = false

    override func setUp() {
        setLoginUser(newLoginUser: LOGIN_USER.sabin)
        resetDataRepository()
        super.setUp()
    }
    
    override func getElements<T>(_ sessionData: SessionData) -> [T]? {
        return (getAccountFromGP)
            ? sessionData.globalPositionDTO.accounts as? [T]
            : sessionData.globalPositionDTO.cards as? [T]
    }
    
    func testValidateUnloadPrepaidCard(){
        
        do{

            guard let card: CardDTO = getElementForTesting(orderInArray: 1, function: #function) else{
                return
            }
            
            getAccountFromGP = true
            
            guard let account: AccountDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let _ = try bsanCardsManager!.loadPrepaidCardData(cardDTO: card)
            
            if card.PAN == nil{
                logTestError(errorMessage: "CARD PAN NIL", function: #function)
                return
            }

            let getPrepaidCardDataResponse = try bsanCardsManager!.getPrepaidCardData(cardDTO: card)

            guard let getPrepaidCardData = try getResponseData(response: getPrepaidCardDataResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            let validateUnloadPrepaidCardResponse = try bsanCardsManager!.validateUnloadPrepaidCard(cardDTO: card, amountDTO: FieldsUtils.amountDTO, accountDTO: account, prepaidCardDataDTO: getPrepaidCardData)

            guard let validateUnloadPrepaidCard = try getResponseData(response: validateUnloadPrepaidCardResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }

            logTestSuccess(result: validateUnloadPrepaidCard, function: #function)

        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidateLoadPrepaidCard(){
        
        do{
            
            guard let card: CardDTO = getElementForTesting(orderInArray: 1, function: #function) else{
                return
            }
            
            getAccountFromGP = true
            
            guard let account: AccountDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let _ = try bsanCardsManager!.loadPrepaidCardData(cardDTO: card)
            
            if card.PAN == nil{
                logTestError(errorMessage: "CARD PAN NIL", function: #function)
                return
            }
            
            let getPrepaidCardDataResponse = try bsanCardsManager!.getPrepaidCardData(cardDTO: card)
            
            guard let getPrepaidCardData = try getResponseData(response: getPrepaidCardDataResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            var signatureDTO = getPrepaidCardData.signatureDTO
            TestUtils.fillSignature(input: &signatureDTO)
            
            let validateLoadPrepaidCardResponse = try bsanCardsManager!.validateLoadPrepaidCard(cardDTO: card, amountDTO: FieldsUtils.amountDTO, accountDTO: account, prepaidCardDataDTO: getPrepaidCardData)
            
            guard let validateLoadPrepaidCard = try getResponseData(response: validateLoadPrepaidCardResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: validateLoadPrepaidCard, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidateOTPPrepaidCard(){
        
        do{
            
            guard let card: CardDTO = getElementForTesting(orderInArray: 1, function: #function) else{
                return
            }
            
            getAccountFromGP = true
            
            guard let account: AccountDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let _ = try bsanCardsManager!.loadPrepaidCardData(cardDTO: card)
            
            if card.PAN == nil{
                logTestError(errorMessage: "CARD PAN NIL", function: #function)
                return
            }
            
            let getPrepaidCardDataResponse = try bsanCardsManager!.getPrepaidCardData(cardDTO: card)
            
            guard var getPrepaidCardData = try getResponseData(response: getPrepaidCardDataResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            TestUtils.fillSignature(input: &getPrepaidCardData.signatureDTO)
            
            let validateLoadPrepaidCardResponse = try bsanCardsManager!.validateLoadPrepaidCard(cardDTO: card, amountDTO: FieldsUtils.amountDTO, accountDTO: account, prepaidCardDataDTO: getPrepaidCardData)
            
            guard let validateLoadPrepaidCard = try getResponseData(response: validateLoadPrepaidCardResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            let validateOTPPrepaidCardResponse = try bsanCardsManager!.validateOTPPrepaidCard(cardDTO: card, signatureDTO: getPrepaidCardData.signatureDTO!, validateLoadPrepaidCardDTO: validateLoadPrepaidCard)
            
            guard let validateOTPPrepaidCard = try getResponseData(response: validateOTPPrepaidCardResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: validateOTPPrepaidCard, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
}

