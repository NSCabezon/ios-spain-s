import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class PortfolioTests: BaseLibraryTests {
    
    override func setUp() {
        setLoginUser(newLoginUser: LOGIN_USER.PORTFOLIOS_LOGIN)
        resetDataRepository()
        super.setUp()
    }
    
    func testGetPortfolios(){
        
        do{
            let _ = try bsanPortfoliosManager?.loadPortfoliosPb()
            
            guard let portfoliosManaged = try bsanPortfoliosManager?.getPortfoliosManaged() else{
                logTestError(errorMessage: "NO PORTFOLIOS FOUND", function: #function)
                return
            }
            
            guard let portfolioPBDTOResponse = try getResponseData(response: portfoliosManaged) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let portfolioPBDTO = portfolioPBDTOResponse.first else {
                logTestError(errorMessage: "NO PORTFOLIOS FOUND", function: #function)
                return
            }
            
            logTestSuccess(result: portfolioPBDTO, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetPortfolioProducts(){
        
        do{
            let _ = try bsanPortfoliosManager?.loadPortfoliosPb()
            
            guard let portfoliosManaged = try bsanPortfoliosManager?.getPortfoliosManaged() else{
                logTestError(errorMessage: "NO PORTFOLIOS FOUND", function: #function)
                return
            }
            
            guard let portfolioPBDTOResponse = try getResponseData(response: portfoliosManaged) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            if portfolioPBDTOResponse.count == 0{
                logTestError(errorMessage: "NO PORTFOLIOS FOUND", function: #function)
                return
            }
            
            let portfolioPBDTO = portfolioPBDTOResponse[5]
            
            let portfolioProductsResponse = try bsanPortfoliosManager!.getPortfolioProducts(portfolioPBDTO: portfolioPBDTO)
            
            guard let portfolioProductsList = try getResponseData(response: portfolioProductsResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: portfolioProductsList, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetHolderDetail(){
        
        do{
            let _ = try bsanPortfoliosManager?.loadPortfoliosPb()
            
            guard let portfoliosManaged = try bsanPortfoliosManager?.getPortfoliosManaged() else{
                logTestError(errorMessage: "NO PORTFOLIOS FOUND", function: #function)
                return
            }
            
            guard let portfolioPBDTOResponse = try getResponseData(response: portfoliosManaged) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            if portfolioPBDTOResponse.count == 0{
                logTestError(errorMessage: "NO PORTFOLIOS FOUND", function: #function)
                return
            }
            
            let portfolioPBDTO = portfolioPBDTOResponse[5]
            
            let getHolderDetailResponse = try bsanPortfoliosManager?.getHolderDetail(portfolioPBDTO: portfolioPBDTO)
            
            if getHolderDetailResponse == nil{
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let holderDetailResponse = try getResponseData(response: getHolderDetailResponse!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            if holderDetailResponse.count == 0 {
                logTestError(errorMessage: "NO HOLDER DETAILS FOUND", function: #function)
                return
            }
            
            logTestSuccess(result: holderDetailResponse, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetPortfolioProductTransactions(){
        
        do{
            let _ = try bsanPortfoliosManager?.loadPortfoliosPb()
            
            guard let portfoliosManaged = try bsanPortfoliosManager?.getPortfoliosManaged() else{
                logTestError(errorMessage: "NO PORTFOLIOS FOUND", function: #function)
                return
            }
            
            guard let portfolioPBDTOResponse = try getResponseData(response: portfoliosManaged) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            if portfolioPBDTOResponse.count == 0{
                logTestError(errorMessage: "NO PORTFOLIOS FOUND", function: #function)
                return
            }
            
            let portfolioPBDTO = portfolioPBDTOResponse[5]
            
            print("\n\n\(#function) :\n\(portfolioPBDTO)")
            
            let portfolioProductsResponse = try bsanPortfoliosManager!.getPortfolioProducts(portfolioPBDTO: portfolioPBDTO)
            
            guard let portfolioProductsList = try getResponseData(response: portfolioProductsResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            if portfolioProductsList.count == 0 {
                logTestError(errorMessage: "NO Portfolio Products FOUND", function: #function)
                return
            }
            
            let portfolioProduct = portfolioProductsList[0]
            
            print("\n\n\(#function) :\n\(portfolioProduct)")
            
            let getPortfolioProductTransactionsResponse = try bsanPortfoliosManager?.getPortfolioProductTransactions(portfolioProductPBDTO: portfolioProduct, pagination: nil, dateFilter: nil)
            
            if getPortfolioProductTransactionsResponse == nil{
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let portfolioProductTransactionsResponse = try getResponseData(response: getPortfolioProductTransactionsResponse!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            if portfolioProductTransactionsResponse.transactionDTOs == nil{
                logTestError(errorMessage: "NO Portfolio Product Transactions FOUND", function: #function)
                return
            }
            
            if portfolioProductTransactionsResponse.transactionDTOs!.count == 0{
                logTestError(errorMessage: "NO Portfolio Product Transactions FOUND", function: #function)
                return
            }
            
            logTestSuccess(result: portfolioProductTransactionsResponse.transactionDTOs!, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetPortfolioProductTransactionDetail(){
        
        do{
            let _ = try bsanPortfoliosManager?.loadPortfoliosPb()
            
            guard let portfoliosManaged = try bsanPortfoliosManager?.getPortfoliosManaged() else{
                logTestError(errorMessage: "NO PORTFOLIOS FOUND", function: #function)
                return
            }
            
            guard let portfolioPBDTOResponse = try getResponseData(response: portfoliosManaged) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            if portfolioPBDTOResponse.count == 0{
                logTestError(errorMessage: "NO PORTFOLIOS FOUND", function: #function)
                return
            }
            
            let portfolioPBDTO = portfolioPBDTOResponse[5]
            
            print("\n\n\(#function) :\n\(portfolioPBDTO)")
            
            let portfolioProductsResponse = try bsanPortfoliosManager!.getPortfolioProducts(portfolioPBDTO: portfolioPBDTO)
            
            guard let portfolioProductsList = try getResponseData(response: portfolioProductsResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            if portfolioProductsList.count == 0 {
                logTestError(errorMessage: "NO Portfolio Products FOUND", function: #function)
                return
            }
            
            let portfolioProduct = portfolioProductsList[0]
            
            print("\n\n\(#function) :\n\(portfolioProduct)")
            
            let getPortfolioProductTransactionsResponse = try bsanPortfoliosManager?.getPortfolioProductTransactions(portfolioProductPBDTO: portfolioProduct, pagination: nil, dateFilter: nil)
            
            if getPortfolioProductTransactionsResponse == nil{
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let portfolioProductTransactionsResponse = try getResponseData(response: getPortfolioProductTransactionsResponse!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            if portfolioProductTransactionsResponse.transactionDTOs == nil{
                logTestError(errorMessage: "NO Portfolio Product Transactions FOUND", function: #function)
                return
            }
            
            if portfolioProductTransactionsResponse.transactionDTOs!.count == 0{
                logTestError(errorMessage: "NO Portfolio Product Transactions FOUND", function: #function)
                return
            }
            
            print("\n\n\(#function) :\n\(portfolioProductTransactionsResponse.transactionDTOs!)")
            
            let getPortfolioProductTransactionDetailResponse = try bsanPortfoliosManager?.getPortfolioProductTransactionDetail(transactionDTO: portfolioProductTransactionsResponse.transactionDTOs!.first!)
            
            if getPortfolioProductTransactionDetailResponse == nil {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let portfolioProductTransactionDetailResponse = try getResponseData(response: getPortfolioProductTransactionDetailResponse!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: portfolioProductTransactionDetailResponse, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetVariableIncomePortfolio() {
        
        do {
            guard let portfoliosManaged = try bsanPortfoliosManager?.loadVariableIncomePortfolioPb() else{
                logTestError(errorMessage: "NO PORTFOLIOS FOUND", function: #function)
                return
            }
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
}
