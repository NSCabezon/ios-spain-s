import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class PayOffTests: BaseLibraryTests {
    typealias T = CardDTO
    
    override func setUp() {
        setLoginUser(newLoginUser: LOGIN_USER.eva)
        resetDataRepository()
        super.setUp()
    }
    
    override func getElements<T>(_ sessionData: SessionData) -> [T]? {
        return sessionData.globalPositionDTO.cards as? [T]
    }
    
    func testConfirmPayOff(){
        
        do{
            
            let consultPayOffSignaturePositionsResponse = try bsanSignatureManager!.consultCardsPayOffSignaturePositions()
            
            var consultPayOffSignaturePositions = try getResponseData(response: consultPayOffSignaturePositionsResponse)
            
            if consultPayOffSignaturePositions == nil {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            if consultPayOffSignaturePositions!.signatureDTO == nil{
                logTestError(errorMessage: "NO SIGNATURE", function: #function)
                return
            }
            
            TestUtils.fillSignature(input: &consultPayOffSignaturePositions!.signatureDTO)

            guard let card: CardDTO = getElementForTesting(orderInArray: 2, function: #function) else{
                return
            }
            
            let getCardDetailResponse = try bsanCardsManager!.getCardDetail(cardDTO: card)
            
            guard let getCardDetail = try getResponseData(response: getCardDetailResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            let confirmPayOffResponse = try bsanCardsManager!.confirmPayOff(cardDTO: card, cardDetailDTO: getCardDetail, amountDTO: FieldsUtils.amountDTO, signatureWithTokenDTO: consultPayOffSignaturePositions!)

            guard let confirmPayOff = try getResponseData(response: confirmPayOffResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: confirmPayOff, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
}
