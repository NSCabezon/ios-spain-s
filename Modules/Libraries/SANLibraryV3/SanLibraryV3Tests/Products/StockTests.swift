import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class StockTests: BaseLibraryTests {
    typealias T = StockDTO
    
    override func setUp() {
        setLoginUser(newLoginUser: LOGIN_USER.sabin)
        resetDataRepository()
        super.setUp()
    }
    
    override func getElements<T>(_ sessionData: SessionData) -> [T]? {
        return sessionData.globalPositionDTO.stockAccounts as? [T]
    }
    
    func testGetStocks(){
        
        do{
            guard let stockAccount: StockAccountDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let stocksResponse = try bsanStocksManager!.getStocks(stockAccountDTO: stockAccount, pagination: nil)
            
            guard let stockListDTO = try getResponseData(response: stocksResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: stockListDTO, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetStocksWithPagination(){
        
        do{
            guard let stockAccount: StockAccountDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let stocksResponse = try bsanStocksManager!.getStocks(stockAccountDTO: stockAccount, pagination: nil)
            
            guard let stockListDTO = try getResponseData(response: stocksResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            print("\n\n\(#function) :\n\(stockListDTO)")
            
            if let pagination = stockListDTO.pagination{
                if pagination.endList == true{
                    logTestError(errorMessage: "getStocks ONLY HAS ONE PAGE", function: #function)
                    return
                }
            }
            
            let stocksResponseSecond = try bsanStocksManager!.getStocks(stockAccountDTO: stockAccount, pagination: stockListDTO.pagination)
            
            guard let stockListDTOSecond = try getResponseData(response: stocksResponseSecond) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: stockListDTOSecond, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetStockQuotes(){
        
        do{
            let quotesResponse = try bsanStocksManager!.getStocksQuotes(searchString: TestUtils.STOCK_QUOTES_SEARCH.rawValue, pagination: nil)
            
            guard let quotesListDTO = try getResponseData(response: quotesResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: quotesListDTO, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetStockQuotesWithPagination(){
        
        do{
            let quotesResponse = try bsanStocksManager!.getStocksQuotes(searchString: TestUtils.STOCK_QUOTES_SEARCH.rawValue, pagination: nil)
            
            guard let quotesListDTO = try getResponseData(response: quotesResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            print("\n\n\(#function) :\n\(quotesListDTO)")
            
            if let pagination = quotesListDTO.pagination{
                if pagination.endList == true{
                    logTestError(errorMessage: "getStocksQuotes ONLY HAS ONE PAGE", function: #function)
                    return
                }
            }
            
            let quotesResponseSecond = try bsanStocksManager!.getStocksQuotes(searchString: TestUtils.STOCK_QUOTES_SEARCH.rawValue, pagination: quotesListDTO.pagination)
            
            guard let quotesListDTOSecond = try getResponseData(response: quotesResponseSecond) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: quotesListDTOSecond, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetStockQuoteDetail(){
        
        do{
            let quotesResponse = try bsanStocksManager!.getStocksQuotes(searchString: TestUtils.STOCK_QUOTES_SEARCH.rawValue, pagination: nil)
            
            guard let stockListDTO = try getResponseData(response: quotesResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let stockQuote = stockListDTO.stockQuoteDTOS?.first else {
                logTestError(errorMessage: "getStocks RETURNED NO STOCKQUOTEDTO", function: #function)
                return
            }
            
            let quoteDetailResponse = try bsanStocksManager!.getQuoteDetail(stockQuoteDTO: stockQuote)
            
            guard let stockQuoteDetailDTO = try getResponseData(response: quoteDetailResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: stockQuoteDetailDTO, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetOrdenes(){
        
        do{
            guard let stockAccount: StockAccountDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let ordenesResponse = try bsanStocksManager!.getOrdenes(stockAccountDTO: stockAccount, pagination: nil, dateFilter: DateFilter.getDateFilterFor(numberOfYears: -4))
            
            guard let orderListDTO = try getResponseData(response: ordenesResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: orderListDTO, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetOrderDetail(){
        
        do{
            guard let stockAccount: StockAccountDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let ordenesResponse = try bsanStocksManager!.getOrdenes(stockAccountDTO: stockAccount, pagination: nil, dateFilter: DateFilter.getDateFilterFor(numberOfYears: -4))
            
            guard let orderListDTO = try getResponseData(response: ordenesResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let orderDTO = orderListDTO.orders?.first else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            let getOrderDetailResponse = try bsanStocksManager!.getOrderDetail(order: orderDTO, stockAccountDTO: stockAccount)
            
            guard let getOrderDetail = try getResponseData(response: getOrderDetailResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: getOrderDetail, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetStocksQuoteIBEXSAN(){
        
        do{
            
            let getStocksQuoteIBEXSANResponse = try bsanStocksManager!.getStocksQuoteIBEXSAN()
            
            guard let getStocksQuoteIBEXSAN = try getResponseData(response: getStocksQuoteIBEXSANResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: getStocksQuoteIBEXSAN, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testSetCancellationOrder(){
        
        do{
            
            guard let stockAccount: StockAccountDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let getOrdenesResponse = try bsanStocksManager!.getOrdenes(stockAccountDTO: stockAccount, pagination: nil, dateFilter: DateFilter.getDateFilterFor(numberOfYears: -2))
            
            guard let getOrdenes = try getResponseData(response: getOrdenesResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let orden = getOrdenes.orders?.first else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            let getOrderDetailResponse = try bsanStocksManager!.getOrderDetail(order: orden, stockAccountDTO: stockAccount)
            
            guard var getOrderDetail = try getResponseData(response: getOrderDetailResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let situation = orden.situation else {
                logTestError(errorMessage: "ORDER HAS NO SITUATION", function: #function)
                return
            }
            
            guard var orderDetail = getOrderDetail else {
                logTestError(errorMessage: "ORDER NIL", function: #function)
                return
            }
            
            if situation == FieldsUtils.STOCK_ORDER_STATUS_PENDING{
                
                TestUtils.fillSignature(input: &orderDetail.signatureDTO)
                
                let setCancellationOrderResponse = try bsanStocksManager!.setCancellationOrder(orderDTO: orden, signatureDTO: orderDetail.signatureDTO!, stockAccountDTO: stockAccount)
                
                guard let setCancellationOrder = try getResponseData(response: setCancellationOrderResponse) else {
                    logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                    return
                }
                
                logTestSuccess(result: setCancellationOrder, function: #function)
                return
            }
            
            logTestError(errorMessage: "SITUATION != STOCK_ORDER_STATUS_PENDING", function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidateBuyStockLimited(){
        
        do{
            
            setUp(loginUser: LOGIN_USER.iñaki, pbToSet: nil)
            
            guard let stockAccount: StockAccountDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let getStocksResponse = try bsanStocksManager!.getStocks(stockAccountDTO: stockAccount, pagination: nil)
            
            guard let getStocks = try getResponseData(response: getStocksResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let stockList = getStocks.stockListDTO else {
                logTestError(errorMessage: "RETURNED NO stockList", function: #function)
                return
            }
            
            if stockList.count < 2{
                logTestError(errorMessage: "RETURNED NO stockList FOR TESTING", function: #function)
                return
            }
            
            let validateBuyStockLimitedResponse = try bsanStocksManager!.validateBuyStockLimited(stockAccountDTO: stockAccount, stockQuoteDTO: stockList[1].stockQuoteDTO, stockLimitedOperationInput: TestUtils.getStockLimitedOperationInputData())
            
            validateBuyStockLimitedResponse.isSuccess()
                ? logTestSuccess(result: validateBuyStockLimitedResponse, function: #function)
                : logTestError(errorMessage: try validateBuyStockLimitedResponse.getErrorMessage(), function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidateBuyStockTypeOrder(){
        
        do{
            
            guard let stockAccount: StockAccountDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let getStocksResponse = try bsanStocksManager!.getStocks(stockAccountDTO: stockAccount, pagination: nil)
            
            guard let getStocks = try getResponseData(response: getStocksResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let stockList = getStocks.stockListDTO else {
                logTestError(errorMessage: "RETURNED NO stockList", function: #function)
                return
            }
            
            if stockList.count < 2{
                logTestError(errorMessage: "RETURNED NO stockList FOR TESTING", function: #function)
                return
            }
            
            let validateBuyStockTypeOrderResponse = try bsanStocksManager!.validateBuyStockTypeOrder(stockAccountDTO: stockAccount, stockQuoteDTO: stockList[1].stockQuoteDTO, stockTypeOrderOperationInput: TestUtils.getStockTypeOrderOperationInputData(type: FieldsUtils.STOCK_TYPE_ORDER_AT_MARKET))
            
            validateBuyStockTypeOrderResponse.isSuccess()
                ? logTestSuccess(result: validateBuyStockTypeOrderResponse, function: #function)
                : logTestError(errorMessage: try validateBuyStockTypeOrderResponse.getErrorMessage(), function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testConfirmBuyStockLimited(){
        
        do{
            
            guard let stockAccount: StockAccountDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let getStocksResponse = try bsanStocksManager!.getStocks(stockAccountDTO: stockAccount, pagination: nil)
            
            guard let getStocks = try getResponseData(response: getStocksResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let stockList = getStocks.stockListDTO else {
                logTestError(errorMessage: "RETURNED NO stockList", function: #function)
                return
            }
            
            if stockList.count < 2{
                logTestError(errorMessage: "RETURNED NO stockList FOR TESTING", function: #function)
                return
            }
            
            let validateBuyStockLimitedResponse = try bsanStocksManager!.validateBuyStockLimited(stockAccountDTO: stockAccount, stockQuoteDTO: stockList[1].stockQuoteDTO, stockLimitedOperationInput: TestUtils.getStockLimitedOperationInputData())
            
            guard var validateBuyStockLimited = try getResponseData(response: validateBuyStockLimitedResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            TestUtils.fillSignature(input: &validateBuyStockLimited.signature)
            
            let confirmBuyStockLimitedResponse = try bsanStocksManager!.confirmBuyStockLimited(stockAccountDTO: stockAccount, stockQuoteDTO: stockList[1].stockQuoteDTO, stockLimitedOperationInput: TestUtils.getStockLimitedOperationInputData(), signatureDTO: validateBuyStockLimited.signature!)
            
            guard let confirmBuyStockLimited = try getResponseData(response: confirmBuyStockLimitedResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: confirmBuyStockLimited, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testConfirmSellStockLimited(){
        
        do{
            
            guard let stockAccount: StockAccountDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let getStocksResponse = try bsanStocksManager!.getStocks(stockAccountDTO: stockAccount, pagination: nil)
            
            guard let getStocks = try getResponseData(response: getStocksResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let stockList = getStocks.stockListDTO else {
                logTestError(errorMessage: "RETURNED NO stockList", function: #function)
                return
            }
            
            if stockList.count < 2{
                logTestError(errorMessage: "RETURNED NO stockList FOR TESTING", function: #function)
                return
            }
            
            let validateSellStockLimitedResponse = try bsanStocksManager!.validateSellStockLimited(stockAccountDTO: stockAccount, stockQuoteDTO: stockList[1].stockQuoteDTO, stockLimitedOperationInput: TestUtils.getStockLimitedOperationInputData())
            
            guard var validateSellStockLimited = try getResponseData(response: validateSellStockLimitedResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            TestUtils.fillSignature(input: &validateSellStockLimited.signature)
            
            let confirmSellStockLimitedResponse = try bsanStocksManager!.confirmSellStockLimited(stockAccountDTO: stockAccount, stockQuoteDTO: stockList[1].stockQuoteDTO, stockLimitedOperationInput: TestUtils.getStockLimitedOperationInputData(), signatureDTO: validateSellStockLimited.signature!)
            
            guard let confirmSellStockLimited = try getResponseData(response: confirmSellStockLimitedResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: confirmSellStockLimited, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testConfirmBuyStockTypeOrder(){
        
        do{
            
            guard let stockAccount: StockAccountDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let getStocksResponse = try bsanStocksManager!.getStocks(stockAccountDTO: stockAccount, pagination: nil)
            
            guard let getStocks = try getResponseData(response: getStocksResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let stockList = getStocks.stockListDTO else {
                logTestError(errorMessage: "RETURNED NO stockList", function: #function)
                return
            }
            
            if stockList.count < 2{
                logTestError(errorMessage: "RETURNED NO stockList FOR TESTING", function: #function)
                return
            }
            
            let validateBuyStockTypeOrderResponse = try bsanStocksManager!.validateBuyStockTypeOrder(stockAccountDTO: stockAccount, stockQuoteDTO: stockList[1].stockQuoteDTO, stockTypeOrderOperationInput: TestUtils.getStockTypeOrderOperationInputData(type: FieldsUtils.STOCK_TYPE_ORDER_AT_MARKET))
            
            guard var validateBuyStockTypeOrder = try getResponseData(response: validateBuyStockTypeOrderResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            TestUtils.fillSignature(input: &validateBuyStockTypeOrder.signature)
            
            let confirmBuyStockTypeOrderResponse = try bsanStocksManager!.confirmBuyStockTypeOrder(stockAccountDTO: stockAccount, stockQuoteDTO: stockList[1].stockQuoteDTO, stockTypeOrderOperationInput: TestUtils.getStockTypeOrderOperationInputData(type: FieldsUtils.STOCK_TYPE_ORDER_AT_MARKET), signatureDTO: validateBuyStockTypeOrder.signature!)
            
            guard let confirmBuyStockTypeOrder = try getResponseData(response: confirmBuyStockTypeOrderResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: confirmBuyStockTypeOrder, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testConfirmSellStockTypeOrder(){
        
        do{
            
            guard let stockAccount: StockAccountDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let getStocksResponse = try bsanStocksManager!.getStocks(stockAccountDTO: stockAccount, pagination: nil)
            
            guard let getStocks = try getResponseData(response: getStocksResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let stockList = getStocks.stockListDTO else {
                logTestError(errorMessage: "RETURNED NO stockList", function: #function)
                return
            }
            
            if stockList.count < 2{
                logTestError(errorMessage: "RETURNED NO stockList FOR TESTING", function: #function)
                return
            }
            
            let validateSellStockTypeOrderResponse = try bsanStocksManager!.validateSellStockTypeOrder(stockAccountDTO: stockAccount, stockQuoteDTO: stockList[1].stockQuoteDTO, stockTypeOrderOperationInput: TestUtils.getStockTypeOrderOperationInputData(type: FieldsUtils.STOCK_TYPE_ORDER_AT_MARKET))
            
            guard var validateSellStockTypeOrder = try getResponseData(response: validateSellStockTypeOrderResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            TestUtils.fillSignature(input: &validateSellStockTypeOrder.signature)
            
            let confirmSellStockTypeOrderResponse = try bsanStocksManager!.confirmSellStockTypeOrder(stockAccountDTO: stockAccount, stockQuoteDTO: stockList[1].stockQuoteDTO, stockTypeOrderOperationInput: TestUtils.getStockTypeOrderOperationInputData(type: FieldsUtils.STOCK_TYPE_ORDER_AT_MARKET), signatureDTO: validateSellStockTypeOrder.signature!)
            
            guard let confirmSellStockTypeOrder = try getResponseData(response: confirmSellStockTypeOrderResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: confirmSellStockTypeOrder, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
}
