//

import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class CardsSettlementTests: BaseLibraryTests {
    typealias T = CardDTO
    
    override func setUp() {
        setLoginUser(newLoginUser: LOGIN_USER.SETTLEMENT_CARDS)
        resetDataRepository()
        super.setUp()
    }
    
    override func getElements<T>(_ sessionData: SessionData) -> [T]? {
        return sessionData.globalPositionDTO.cards as? [T]
    }
    
    func testGetCardSettlementDetail() {
        do {
            guard let card: CardDTO = getElementForTesting(orderInArray: 13, function: #function) else {
                return
            }
            let _ = try bsanSignatureManager?.loadCMCSignature()
            let response = try bsanCardsManager!.getCardSettlementDetail(card: card, date: Date())
            guard let validData = try response.getResponseData() else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: validData, function: #function)
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetCardSettlementListMovements() {
        do {
            guard let card: CardDTO = getElementForTesting(orderInArray: 13, function: #function) else {
                return
            }
            let _ = try bsanSignatureManager?.loadCMCSignature()
            let response = try bsanCardsManager!.getCardSettlementDetail(card: card, date: Date())
            guard let detailData = try response.getResponseData(),
                let extractNumber = detailData.extractNumber else {
                    logTestError(errorMessage: "RETURNED NO RESPONSE DETAIL DATA", function: #function)
                    return
            }
            let responseMovements = try bsanCardsManager!.getCardSettlementListMovements(card: card, extractNumber: extractNumber)
            guard let validData = try responseMovements.getResponseData() else {
                    logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                    return
            }
            logTestSuccess(result: validData, function: #function)
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetCardSettlementListMovementsByContract() {
        do {
            guard let card: CardDTO = getElementForTesting(orderInArray: 13, function: #function) else {
                return
            }
            let _ = try bsanSignatureManager?.loadCMCSignature()
            let response = try bsanCardsManager!.getCardSettlementDetail(card: card, date: Date())
            guard let detailData = try response.getResponseData(),
                let extractNumber = detailData.extractNumber else {
                    logTestError(errorMessage: "RETURNED NO RESPONSE DETAIL DATA", function: #function)
                    return
            }
            let responseMovements = try bsanCardsManager!.getCardSettlementListMovementsByContract(card: card, extractNumber: extractNumber)
            guard let validData = try responseMovements.getResponseData() else {
                    logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                    return
            }
            logTestSuccess(result: validData, function: #function)
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
}
