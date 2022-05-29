
import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib
class MifidTests: BaseLibraryTests {
    typealias T = StockAccountDTO
    
    let stockTradesSharesCount = "+525.00"
    let stockOptionBuy = "C"
    let stockOptionSell = "V"
    
    override func setUp() {
        setLoginUser(newLoginUser: LOGIN_USER.sabin)
        resetDataRepository()
        super.setUp()
    }
    
    override func getElements<T>(_ sessionData: SessionData) -> [T]? {
        return sessionData.globalPositionDTO.stockAccounts as? [T]
    }
    
    func testMifidClausesByBuy() {
        do {
            guard let stockAccountDTO: StockAccountDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let response = try bsanStocksManager!.getStocks(stockAccountDTO: stockAccountDTO, pagination: nil)
            
            guard let responseData = try getResponseData(response: response) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let stocksDTO = responseData.stockListDTO else {
                logTestError(errorMessage: "RESPONSE DATA DOESN'T HAVE STOCKLISTDTO", function: #function)
                return
            }
            
            let responseMifid = try bsanMifidManager!.getMifidClauses(stockAccountDTO: stockAccountDTO, stockQuoteDTO: stocksDTO[1].stockQuoteDTO, tradedSharesCount: stockTradesSharesCount, transferMode: stockOptionBuy)
            
            guard let mifidDTO = try getResponseData(response: responseMifid) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: mifidDTO, function: #function)

        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testMifidClausesBySell() {
        do {
            guard let stockAccountDTO: StockAccountDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let response = try bsanStocksManager!.getStocks(stockAccountDTO: stockAccountDTO, pagination: nil)
            
            guard let responseData = try getResponseData(response: response) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let stocksDTO = responseData.stockListDTO else {
                logTestError(errorMessage: "RESPONSE DATA DOESN'T HAVE STOCKLISTDTO", function: #function)
                return
            }
            
            let responseMifid = try bsanMifidManager!.getMifidClauses(stockAccountDTO: stockAccountDTO, stockQuoteDTO: stocksDTO[1].stockQuoteDTO, tradedSharesCount: stockTradesSharesCount, transferMode: stockOptionSell)
            
            guard let mifidDTO = try getResponseData(response: responseMifid) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: mifidDTO, function: #function)

        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testCounterValueDetail() {
        do {
            guard let stockAccountDTO: StockAccountDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let response = try bsanStocksManager!.getStocks(stockAccountDTO: stockAccountDTO, pagination: nil)
            
            guard let responseData = try getResponseData(response: response) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA FROM STOCKS", function: #function)
                return
            }
            
            guard let stocksDTO = responseData.stockListDTO else {
                logTestError(errorMessage: "RESPONSE DATA DOESN'T HAVE STOCKLISTDTO", function: #function)
                return
            }
            
            let responseMifid = try bsanMifidManager!.getCounterValueDetail(stockAccountDTO: stockAccountDTO, stockQuoteDTO: stocksDTO[1].stockQuoteDTO)
            
            guard let mifidDTO = try getResponseData(response: responseMifid) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: mifidDTO, function: #function)

        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testMifidIndicator() {
        do {
            guard let stockAccountDTO: StockAccountDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            guard let contractDTO = stockAccountDTO.contract else {
                return
            }
            
            let responseMifid = try bsanMifidManager!.getMifidIndicator(contractDTO: contractDTO)
            
            guard let mifidIndicatorDTO = try getResponseData(response: responseMifid) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: mifidIndicatorDTO, function: #function)

        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
}
