import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class LoanTests: BaseLibraryTests {
    typealias T = LoanDTO
    
    var getAccountFromGP = false
    
    override func setUp() {
        setLoginUser(newLoginUser: LOGIN_USER.LOANS_LOGIN)
        resetDataRepository()
        super.setUp()
    }
    
    override func getElements<T>(_ sessionData: SessionData) -> [T]? {
        return (getAccountFromGP)
            ? sessionData.globalPositionDTO.accounts as? [T]
            : sessionData.globalPositionDTO.loans as? [T]
    }
    
    func testGetLoanTransactions(){
        
        do {
            guard let loan: LoanDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let loanTransactionsResponse = try bsanLoanManager!.getLoanTransactions(forLoan: loan, dateFilter: DateFilter.getDateFilterFor(numberOfYears: -5), pagination: nil)
            
            guard let loanTransactionsDTO = try getResponseData(response: loanTransactionsResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: loanTransactionsDTO, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetLoanTransactionsWithPagination(){
        
        do {
            guard let loan: LoanDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let loanTransactionsResponse = try bsanLoanManager!.getLoanTransactions(forLoan: loan, dateFilter: DateFilter.getDateFilterFor(numberOfYears: -5), pagination: nil)
            
            guard let loanTransactionsDTO = try getResponseData(response: loanTransactionsResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            print("\n\n\(#function) :\n\(loanTransactionsDTO)\n")
            
            if !loanTransactionsDTO.pagination.endList{
                print("\n\(#function) SecondPage\n")
                let loanTransactionsResponseSecond = try bsanLoanManager!.getLoanTransactions(forLoan: loan, dateFilter: DateFilter.getDateFilterFor(numberOfYears: -5), pagination: loanTransactionsDTO.pagination)
                
                guard let loanTransactionsDTOSecond = try getResponseData(response: loanTransactionsResponseSecond) else {
                    logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                    return
                }
                
                logTestSuccess(result: loanTransactionsDTOSecond, function: #function)
            }
            else{
                logTestError(errorMessage: "ONLY HAS ONE PAGE", function: #function)
            }
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetLoanDetail(){
        
        do {
            guard let loan: LoanDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let loanDetailResponse = try bsanLoanManager!.getLoanDetail(forLoan: loan)
            
            guard let loanDetailDTO = try getResponseData(response: loanDetailResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: loanDetailDTO, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetLoanTransactionDetail() {
        
        do {
            
            guard let loan: LoanDTO = getElementForTesting(orderInArray: 1, function: #function) else{
                return
            }
            
            let loanTransactionsResponse = try bsanLoanManager!.getLoanTransactions(forLoan: loan, dateFilter: DateFilter.getDateFilterFor(numberOfYears: -5), pagination: nil)
            
            guard let loanTransactionsDTO = try getResponseData(response: loanTransactionsResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let loanTransactionDTO = loanTransactionsDTO.transactionDTOs.first else {
                logTestError(errorMessage: "RETURNED NO LOANTRANSACTIONDTO", function: #function)
                return
            }
            
            let loanTransactionDetailResponse = try bsanLoanManager!.getLoanTransactionDetail(forLoan: loan, loanTransaction: loanTransactionDTO)
            
            guard let loanTransactionDetailDTO = try getResponseData(response: loanTransactionDetailResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: loanTransactionDetailDTO, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testConsultLoanChangeAccountSignaturePositions() {
        do {
            
            let consultLoanChangeResponse = try bsanSignatureManager!.consultSendMoneySignaturePositions()
            
            guard let signatureWithTokenDTO = try getResponseData(response: consultLoanChangeResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: signatureWithTokenDTO, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testConfirmChangeAccount() {
        do {
            
            guard let loan: LoanDTO = getElementForTesting(orderInArray: 1, function: #function) else{
                return
            }
            
            self.getAccountFromGP = true
            
            guard let account: AccountDTO = getElementForTesting(orderInArray: 1, function: #function) else{
                return
            }
            
            let consultLoanChangeResponse = try bsanSignatureManager!.consultSendMoneySignaturePositions()
            
            guard var signatureWithTokenDTO = try getResponseData(response: consultLoanChangeResponse) else{
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            TestUtils.fillSignature(input: &signatureWithTokenDTO.signatureDTO)

            let confirmChangeAccountResponse = try bsanLoanManager!.confirmChangeAccount(loanDTO: loan, accountDTO: account, signatureDTO: signatureWithTokenDTO.signatureDTO!)
            
            XCTAssert(confirmChangeAccountResponse.isSuccess())
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetLoanPartialAmortization(){
        
        do{
            guard let loan: LoanDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let getLoanPartialAmortizationResponse = try bsanLoanManager!.getLoanPartialAmortization(loanDTO: loan)
            
            guard let getLoanPartialAmortization = try getResponseData(response: getLoanPartialAmortizationResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: getLoanPartialAmortization, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidatePartialAmortization(){
        
        do{
            guard let loan: LoanDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let getLoanPartialAmortizationResponse = try bsanLoanManager!.getLoanPartialAmortization(loanDTO: loan)
            
            guard let getLoanPartialAmortization = try getResponseData(response: getLoanPartialAmortizationResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            let validatePartialAmortizationResponse = try bsanLoanManager!.validatePartialAmortization(loanPartialAmortizationDTO: getLoanPartialAmortization, amount: FieldsUtils.amountDTO, amortizationType: PartialAmortizationType.decreaseTime)
            
            guard let validatePartialAmortization = try getResponseData(response: validatePartialAmortizationResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: validatePartialAmortization, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testConfirmLoanPartialAmortization(){
        
        do{
            guard let loan: LoanDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let getLoanPartialAmortizationResponse = try bsanLoanManager!.getLoanPartialAmortization(loanDTO: loan)
            
            guard let getLoanPartialAmortization = try getResponseData(response: getLoanPartialAmortizationResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            let validatePartialAmortizationResponse = try bsanLoanManager!.validatePartialAmortization(loanPartialAmortizationDTO: getLoanPartialAmortization, amount: FieldsUtils.amountDTO, amortizationType: PartialAmortizationType.decreaseTime)
            
            guard var validatePartialAmortization = try getResponseData(response: validatePartialAmortizationResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            TestUtils.fillSignature(input: &validatePartialAmortization.signature)

            let confirmPartialAmortizationResponse = try bsanLoanManager!.confirmPartialAmortization(loanPartialAmortizationDTO: getLoanPartialAmortization, amount: FieldsUtils.amountDTO, amortizationType: PartialAmortizationType.decreaseTime, loanValidationDTO: validatePartialAmortization, signatureDTO: validatePartialAmortization.signature!)

            XCTAssert(confirmPartialAmortizationResponse.isSuccess())
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
}
