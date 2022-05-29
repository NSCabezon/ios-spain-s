import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class FundTests: BaseLibraryTests {
    typealias T = FundDTO

    override func setUp() {
        setLoginUser(newLoginUser: LOGIN_USER.FUNDS_LOGIN)
        resetDataRepository()
        super.setUp()
    }
    
    override func getElements<T>(_ sessionData: SessionData) -> [T]? {
        return sessionData.globalPositionDTO.funds as? [T]
    }
    
    func testGetFundTransactions(){
        
        do{
            guard let fund: FundDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let fundTransactionsResponse = try bsanFundManager!.getFundTransactions(forFund: fund, dateFilter: DateFilter.getDateFilterFor(numberOfYears: -5), pagination: nil)
            
            guard let fundTransactionsDTO = try getResponseData(response: fundTransactionsResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: fundTransactionsDTO, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetFundTransactionsWithPagination(){
        
        do{
            guard let fund: FundDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let fundTransactionsResponse = try bsanFundManager!.getFundTransactions(forFund: fund, dateFilter: DateFilter.getDateFilterFor(numberOfYears: -5), pagination: nil)
            
            guard let fundTransactionsDTO = try getResponseData(response: fundTransactionsResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            print("\n\n\(#function) :\n\(fundTransactionsDTO)")

            if !fundTransactionsDTO.pagination.endList{
                print("\(#function) SecondPage")
                let fundTransactionsResponseSecond = try bsanFundManager!.getFundTransactions(forFund: fund, dateFilter: DateFilter.getDateFilterFor(numberOfYears: -5), pagination: fundTransactionsDTO.pagination)
                
                guard let fundTransactionsDTOSecond = try getResponseData(response: fundTransactionsResponseSecond) else {
                    logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                    return
                }
                
                logTestSuccess(result: fundTransactionsDTOSecond, function: #function)
            }
            else{
                logTestError(errorMessage: "getFundTransactions ONLY HAS ONE PAGE", function: #function)
            }
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetFundDetail(){
        
        do {
            guard let fund: FundDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let fundDetailResponse = try bsanFundManager!.getFundDetail(forFund: fund)
            
            guard let fundDetailDTO = try getResponseData(response: fundDetailResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: fundDetailDTO, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetFundTransactionDetail(){
        
        do {
            guard let fund: FundDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let fundTransactionsResponse = try bsanFundManager!.getFundTransactions(forFund: fund, dateFilter: DateFilter.getDateFilterFor(numberOfYears: -5), pagination: nil)
            
            guard let fundTransactionsDTO = try fundTransactionsResponse.getResponseData() else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let fundTransactionDTO = fundTransactionsDTO.transactionDTOs.first else {
                logTestError(errorMessage: "getFundTransactions RETURNED NO FUNDTRANSACTIONDTO", function: #function)
                return
            }
            
            let fundTransactionDetailResponse = try bsanFundManager!.getFundTransactionDetail(forFund: fund, fundTransactionDTO: fundTransactionDTO)
            let fundTransactionDetailDTO = try getResponseData(response: fundTransactionDetailResponse)
            
            logTestSuccess(result: fundTransactionDetailDTO, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidateFundSubscriptionAmount(){
        
        do {
            
            setUp(loginUser: LOGIN_USER.sabin, pbToSet: nil)
            
            guard let fund: FundDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let validateFundSubscriptionAmountResponse = try bsanFundManager!.validateFundSubscriptionAmount(fundDTO: fund, amountDTO: AmountDTO(value: Decimal(52.50), currency: CurrencyDTO(currencyName: CurrencyType.eur.name, currencyType: CurrencyType.eur)))
            
            guard let fundSubscriptionDTO = try getResponseData(response: validateFundSubscriptionAmountResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: fundSubscriptionDTO, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testConfirmFundSubscriptionAmount(){
        
        do {
            guard let fund: FundDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let validateFundSubscriptionAmountResponse = try bsanFundManager!.validateFundSubscriptionAmount(fundDTO: fund, amountDTO: AmountDTO(value: Decimal(52.50), currency: CurrencyDTO(currencyName: CurrencyType.eur.name, currencyType: CurrencyType.eur)))
            
            guard var fundSubscriptionDTO = try getResponseData(response: validateFundSubscriptionAmountResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            TestUtils.fillSignature(input: &fundSubscriptionDTO.signature)

            let confirmFundSubscriptionAmountResponse = try bsanFundManager!.confirmFundSubscriptionAmount(fundDTO: fund, amountDTO: AmountDTO(value: Decimal(52.50), currency: CurrencyDTO(currencyName: CurrencyType.eur.name, currencyType: CurrencyType.eur)), fundSubscriptionDTO: fundSubscriptionDTO, signatureDTO: fundSubscriptionDTO.signature!)

            guard let confirmFundSubscriptionAmount = try getResponseData(response: confirmFundSubscriptionAmountResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: confirmFundSubscriptionAmount, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidateFundTransferPartialShares(){
        
        do {
//            setUp(loginUser: LOGIN_USER.LOANS_LOGIN, pbToSet: nil)
            
            guard let fund: FundDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            guard let destinationFund: FundDTO = getElementForTesting(orderInArray: 1, function: #function) else{
                return
            }
            
            let validateFundTransferPartialBySharesResponse = try bsanFundManager!.validateFundTransferPartialByShares(originFundDTO: fund, destinationFundDTO: destinationFund, sharesNumber: 24)
            
            guard let validateFundTransferPartialByShares = try getResponseData(response: validateFundTransferPartialBySharesResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: validateFundTransferPartialByShares, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidateFundTransferTotal(){
        
        do {
//            setUp(loginUser: LOGIN_USER.DEPOSITS_LOGIN, pbToSet: nil)

            guard let fund: FundDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            guard let destinationFund: FundDTO = getElementForTesting(orderInArray: 1, function: #function) else{
                return
            }
            
            let validateFundTransferTotalResponse = try bsanFundManager!.validateFundTransferTotal(originFundDTO: fund, destinationFundDTO: destinationFund)
            
            guard let validateFundTransferTotal = try getResponseData(response: validateFundTransferTotalResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: validateFundTransferTotal, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testConfirmFundTransferTotal(){
        
        do {
            guard let fund: FundDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            guard let destinationFund: FundDTO = getElementForTesting(orderInArray: 1, function: #function) else{
                return
            }
            
            let validateFundTransferTotalResponse = try bsanFundManager!.validateFundTransferTotal(originFundDTO: fund, destinationFundDTO: destinationFund)
            
            guard var validateFundTransferTotal = try getResponseData(response: validateFundTransferTotalResponse) else{
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            TestUtils.fillSignature(input: &validateFundTransferTotal.signature)

            let confirmFundTransferTotalResponse = try bsanFundManager!.confirmFundTransferTotal(originFundDTO: fund, destinationFundDTO: destinationFund, fundTransferDTO: validateFundTransferTotal, signatureDTO: validateFundTransferTotal.signature!)
            
            guard let confirmFundTransferTotal = try getResponseData(response: confirmFundTransferTotalResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: confirmFundTransferTotal, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
}
