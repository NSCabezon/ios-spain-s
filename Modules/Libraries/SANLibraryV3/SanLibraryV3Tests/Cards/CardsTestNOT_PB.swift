import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class CardsTestsNOT_PB: BaseLibraryTests {
    typealias T = CardDTO
    
    override func setUp() {
        setLoginUser(newLoginUser: LOGIN_USER.eva)
        resetDataRepository()
        super.setUp()
    }
    
    override func getElements<T>(_ sessionData: SessionData) -> [T]? {
        return sessionData.globalPositionDTO.cards as? [T]
    }
    
    func testLoadCardDetailRequest(){
        
        do{
            guard let card: CardDTO = getElementForTesting(orderInArray: 2, function: #function) else{
                return
            }
            
            let _ = try bsanCardsManager!.loadCardDetail(cardDTO: card)
            
            let getCardDetailResponse = try bsanCardsManager!.getCardDetail(cardDTO: card)

            guard let cardDetail = try getResponseData(response: getCardDetailResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: cardDetail, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
//    func testLoadInactiveCardsRequest(){
//
//        do{
//
//            let loadInactiveCardsResponse = try bsanCardsManager!.loadInactiveCards(inactiveCardType: InactiveCardType.inactive)
//
//            guard let _ = try getResponseData(response: loadInactiveCardsResponse) else {
//                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
//                return
//            }
//
//            let getCardDetailResponse = try bsanCardsManager!.getInactiveCardsMap()
//
//            guard let cardDetail = try getResponseData(response: getCardDetailResponse) else {
//                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
//                return
//            }
//
//            logTestSuccess(result: cardDetail, function: #function)
//
//        } catch let error{
//            logTestException(error: error, function: #function)
//        }
//    }
    
    func testBlockCardRequest(){
        
        do{
            
            guard let card: CardDTO = getElementForTesting(orderInArray: 2, function: #function) else{
                return
            }
            
            let blockCardResponse = try bsanCardsManager!.blockCard(cardDTO: card, blockText: TestUtils.CARD_BLOCK_TEXT.rawValue, cardBlockType: CardBlockType.turnOff)
            
            guard let blockCard = try getResponseData(response: blockCardResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: blockCard, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testBlockCardConfirmRequest(){
        
        do{
            
            guard let card: CardDTO = getElementForTesting(orderInArray: 2, function: #function) else{
                return
            }
            
            let blockCardResponse = try bsanCardsManager!.blockCard(cardDTO: card, blockText: TestUtils.CARD_BLOCK_TEXT.rawValue, cardBlockType: CardBlockType.turnOn)
            
            guard let blockCard = try getResponseData(response: blockCardResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            print("\n\n\(#function) :\n\(blockCard)")

            var signatureDTO = blockCard.signature
            TestUtils.fillSignature(input: &signatureDTO)
            
            let blockCardConfirmResponse = try bsanCardsManager!.confirmBlockCard(cardDTO: card, signatureDTO: signatureDTO!, blockText: TestUtils.CARD_BLOCK_TEXT.rawValue, cardBlockType: CardBlockType.turnOn)
            
            //TODO: HACER COMPROBACION LLAMANDO AL SERVICIO TARJETAS INACTIVAS PARA VER SI SE HA DESACTIVADO
            
            print("\n\n\(#function) :\n\(blockCardConfirmResponse.isSuccess())")
            XCTAssert(blockCardConfirmResponse.isSuccess())
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testActivateCardRequest(){
        
        do{
            
            guard let card: CardDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let getCardDetailResponse = try bsanCardsManager!.getCardDetail(cardDTO: card)

            guard let getCardDetail = try getResponseData(response: getCardDetailResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let expirationDate = getCardDetail.expirationDate else{
                logTestError(errorMessage: "RETURNED NO VALID EXPIRATION DATE", function: #function)
                return
            }
            
            let activateCardResponse = try bsanCardsManager!.activateCard(cardDTO: card, expirationDate: expirationDate)
            
            guard let activateCard = try getResponseData(response: activateCardResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: activateCard, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testPrepareDirectMoneyRequest(){
        
        do{
            
            guard let card: CardDTO = getElementForTesting(orderInArray: 6, function: #function) else{
                return
            }
            
            let prepareDirectMoneyResponse = try bsanCardsManager!.prepareDirectMoney(cardDTO: card)
            
            guard let prepareDirectMoney = try getResponseData(response: prepareDirectMoneyResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: prepareDirectMoney, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidateDirectMoneyRequest(){
        
        do{
            
            guard let card: CardDTO = getElementForTesting(orderInArray: 6, function: #function) else{
                return
            }
            
            let prepareDirectMoneyResponse = try bsanCardsManager!.prepareDirectMoney(cardDTO: card)
            
            guard let _ = try getResponseData(response: prepareDirectMoneyResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            let validateDirectMoneyResponse = try bsanCardsManager!.validateDirectMoney(cardDTO: card, amountValidatedDTO: FieldsUtils.amountDirectMoney)
            
            guard let validateDirectMoney = try getResponseData(response: validateDirectMoneyResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }

            logTestSuccess(result: validateDirectMoney, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testConfirmDirectMoneyRequest(){
        
        do{
            
            guard let card: CardDTO = getElementForTesting(orderInArray: 6, function: #function) else{
                return
            }
            
            let prepareDirectMoneyResponse = try bsanCardsManager!.prepareDirectMoney(cardDTO: card)
            
            guard let _ = try getResponseData(response: prepareDirectMoneyResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            let validateDirectMoneyResponse = try bsanCardsManager!.validateDirectMoney(cardDTO: card, amountValidatedDTO: FieldsUtils.amountDirectMoney)
            
            guard let validateDirectMoney = try getResponseData(response: validateDirectMoneyResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            var signatureDTO = validateDirectMoney.signature
            TestUtils.fillSignature(input: &signatureDTO)
            
            let confirmDirectMoneyResponse = try bsanCardsManager!.confirmDirectMoney(cardDTO: card, amountValidatedDTO: FieldsUtils.amountDirectMoney, signatureDTO: signatureDTO!)
            
            guard let confirmDirectMoney = try getResponseData(response: confirmDirectMoneyResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: confirmDirectMoney, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testLoadCardSuperSpeed(){
        
        do{

            let loadCardSuperSpeedResponse = try bsanCardsManager!.loadCardSuperSpeed(pagination: nil, isNegativeCreditBalanceEnabled: true)
            guard let loadCardSuperSpeed = try getResponseData(response: loadCardSuperSpeedResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: loadCardSuperSpeed, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
   
    func testChangeCardAlias(){
        
        do{
            
            guard let card: CardDTO = getElementForTesting(orderInArray: 2, function: #function) else{
                return
            }
            
            let changeCardAliasResponse = try bsanCardsManager!.changeCardAlias(cardDTO: card, newAlias: FieldsUtils.CARD_NEW_ALIAS)

            XCTAssert(changeCardAliasResponse.isSuccess())
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetPayLaterData(){
        do{
            guard let card: CardDTO = getElementForTesting(orderInArray: 6, function: #function) else{
                return
            }
            
            let response = try bsanCardsManager!.getPayLaterData(cardDTO: card)
            
            guard let responseData = try getResponseData(response: response) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: responseData, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testConfirmPayLaterData(){
        do{
            guard let card: CardDTO = getElementForTesting(orderInArray: 1, function: #function) else{
                return
            }

            let payLaterDataResponse = try bsanCardsManager!.getPayLaterData(cardDTO: card)

            guard let payLaterDTO = try getResponseData(response: payLaterDataResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }

            let response = try bsanCardsManager!.confirmPayLaterData(cardDTO: card, payLaterDTO: payLaterDTO, amountDTO: FieldsUtils.amountDTO)
            
            guard let _ = try getResponseData(response: response) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }

            XCTAssert(response.isSuccess())
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testConsultPayOffSignaturePositions(){
        do{
            
            let consultPayOffSignaturePositionsResponse = try bsanSignatureManager!.consultCardsPayOffSignaturePositions()
            
            guard let consultPayOffSignaturePositions = try getResponseData(response: consultPayOffSignaturePositionsResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: consultPayOffSignaturePositions, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testCheckExtractPDF(){
        do{
            
            guard let card: CardDTO = getElementForTesting(orderInArray: 1, function: #function) else{
                return
            }
            
            guard let checkCardExtractPdfResponse = try bsanCardsManager?.checkCardExtractPdf(cardDTO: card, dateFilter: DateFilter.getDateFilterFor(numberOfYears: -4)) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let checkCardExtractPdf = try getResponseData(response: checkCardExtractPdfResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: checkCardExtractPdf, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidatePIN(){
        do{
            
            guard let card: CardDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let getCardDetailTokenResponse = try bsanCardsManager!.getCardDetailToken(cardDTO: card, cardTokenType: CardTokenType.panWithoutSpaces)
            
            guard let getCardDetailToken = try getResponseData(response: getCardDetailTokenResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let validatePINResponse = try bsanCardsManager?.validatePIN(cardDTO: card, cardDetailTokenDTO: getCardDetailToken) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let validatePIN = try getResponseData(response: validatePINResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: validatePIN, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
}
