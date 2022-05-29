import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class PensionTests: BaseLibraryTests {
    typealias T = PensionDTO
    
    let maxTries = 25
    
    override func setUp() {
        setLoginUser(newLoginUser: LOGIN_USER.PENSIONS_LOGIN)
        resetDataRepository()
        super.setUp()
    }
    
    override func getElements<T>(_ sessionData: SessionData) -> [T]? {
        return sessionData.globalPositionDTO.pensions as? [T]
    }
    
    func testGetPensionTransactions(){
        do{
            guard let pension: PensionDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let pensionTransactionsResponse = try bsanPensionManager!.getPensionTransactions(forPension: pension, pagination: nil, dateFilter: DateFilter.getDateFilterFor(numberOfYears: -5))
            
            guard let pensionTransactionsDTO = try getResponseData(response: pensionTransactionsResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: pensionTransactionsDTO, function: #function)

        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetPensionTransactionsWithPagination(){
        
        do{
            guard let pension: PensionDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let pensionTransactionsResponse = try bsanPensionManager!.getPensionTransactions(forPension: pension, pagination: nil, dateFilter: DateFilter.getDateFilterFor(numberOfYears: -5))
            
            guard let pensionTransactionsDTO = try getResponseData(response: pensionTransactionsResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            print("\n\n\(#function) :\n\(pensionTransactionsDTO)")
            
            if !pensionTransactionsDTO.pagination.endList{
                print("\(#function) SecondPage")
                let pensionTransactionsResponseSecond = try bsanPensionManager!.getPensionTransactions(forPension: pension, pagination: pensionTransactionsDTO.pagination, dateFilter: DateFilter.getDateFilterFor(numberOfYears: -5))
                
                guard let pensionTransactionsDTOSecond = try getResponseData(response: pensionTransactionsResponseSecond) else {
                    logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                    return
                }
                
                logTestSuccess(result: pensionTransactionsDTOSecond, function: #function)
            }
            else{
                logTestError(errorMessage: "getPensionTransactions ONLY HAS ONE PAGE", function: #function)
            }
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetPensionDetail(){
        
        do{
            guard let pension: PensionDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let pensionDetailResponse = try bsanPensionManager!.getPensionDetail(forPension: pension)
            
            guard let pensionDetailDTO = try getResponseData(response: pensionDetailResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: pensionDetailDTO, function: #function)

        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetPensionContributions(){
        do{
            guard let pension: PensionDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let getPensionContributionsResponse = try bsanPensionManager!.getPensionContributions(pensionDTO: pension, pagination: nil)
            
            guard let getPensionContributions = try getResponseData(response: getPensionContributionsResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: getPensionContributions, function: #function)

            
//            guard let pensionsContributions = responseData.pensionContributions, let pagination = responseData.pagination else {
//                return
//            }
//
//            var pensionContributionsDTOS = [PensionContributionsDTO]()
//            var tries = 1
//
//            pensionContributionsDTOS += pensionsContributions
//            var totalLastRequest = pensionContributionsDTOS.count
//            var goOut = false
//
//            while !pagination.endList && tries <= maxTries && !goOut {
//                tries += 1
//                response = try bsanPensionManager!.getPensionContributions(pensionDTO: pension, pagination: responseData.pagination)
//
//                guard let responseData = try response.getResponseData() else {
//                    return
//                }
//
//                pensionContributionsDTOS += responseData.pensionContributions ?? []
//
//                if totalLastRequest == pensionContributionsDTOS.count {
//                    goOut = true
//                }
//                totalLastRequest = pensionContributionsDTOS.count
//            }
//
//            logTestSuccess(result: pensionContributionsDTOS, function: #function)
            
        } catch let error {
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetAllPensionContributions(){
        do{
            guard let pension: PensionDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let getPensionContributionsResponse = try bsanPensionManager!.getAllPensionContributions(pensionDTO: pension)
            
            guard let getPensionContributions = try getResponseData(response: getPensionContributionsResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: getPensionContributions, function: #function)
            
        } catch let error {
            logTestException(error: error, function: #function)
        }
    }
    
    func testClausesMifidCalled(){
        do{
            guard let pension: PensionDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let pensionContributionsListResponse = try bsanPensionManager!.getPensionContributions(pensionDTO: pension, pagination: nil)
            
            guard let pensionContributionsListDTO = try getResponseData(response: pensionContributionsListResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            let mifidResponse = try bsanPensionManager!.getClausesPensionMifid(pensionDTO: pension, pensionInfoOperationDTO: pensionContributionsListDTO.pensionInfoOperationDTO, amountDTO: FieldsUtils.amountDTO)
            
            guard let pensionMifidDTO = try getResponseData(response: mifidResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: pensionMifidDTO, function: #function)
            
        } catch let error {
            logTestException(error: error, function: #function)
        }
    }
    
    func testConfirmExtraordinaryContribution(){
        do{
            guard let pension: PensionDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let signResponse = try bsanSignatureManager!.consultPensionSignaturePositions()
            
            guard var signature = try getResponseData(response: signResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            TestUtils.fillSignature(input: &signature.signatureDTO)
            
            let responseConfirm = try bsanPensionManager!.confirmExtraordinaryContribution(pensionDTO: pension, amountDTO: AmountDTO(value: Decimal(50), currency: CurrencyDTO(currencyName: CurrencyType.eur.name, currencyType: CurrencyType.eur)), signatureWithTokenDTO: signature)
            
            XCTAssert(responseConfirm.isSuccess())
            
        } catch let error {
            logTestException(error: error, function: #function)
        }
    }
    
    func testConfirmPeriodicalContribution(){
        do{
            guard let pension: PensionDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let pensionContributionsResponse = try bsanPensionManager!.getPensionContributions(pensionDTO: pension, pagination: nil)
            
            guard let pensionContributionsList = try getResponseData(response: pensionContributionsResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let pensionContributions = pensionContributionsList.pensionContributions else{
                logTestError(errorMessage: "RETURNED NO pensionContributions", function: #function)
                return
            }
            
            if pensionContributions.count == 0{
                logTestError(errorMessage: "RETURNED NO pensionContributions", function: #function)
                return
            }
            
            if let pensionContribution = pensionContributions.filter({$0.statusPlan == FieldsUtils.STOCK_PERIODICAL_ACTIVE}).first{
                logTestError(errorMessage: "YA EXISTE UNA APORTACION PERIODICA : \(pensionContribution)", function: #function)
                return
            }
            
            let signResponse = try bsanSignatureManager!.consultPensionSignaturePositions()
            
            guard var signature = try getResponseData(response: signResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            TestUtils.fillSignature(input: &signature.signatureDTO)
            
            let pensionContributionInput = PensionContributionInput(startDate: Date.getDayOneOfTheFollowingMonth(), periodicyType: PeriodicityType.monthly, amountDTO: AmountDTO(value: Decimal(50), currency: CurrencyDTO(currencyName: CurrencyType.eur.name, currencyType: CurrencyType.eur)), percentage: "", revaluationType: RevaluationType.without_revaluation)
            
            let responseConfirm = try bsanPensionManager!.confirmPeriodicalContribution(pensionDTO: pension, pensionContributionInput: pensionContributionInput, signatureWithTokenDTO: signature)
            
            XCTAssert(responseConfirm.isSuccess())
            
        } catch let error {
            logTestException(error: error, function: #function)
        }
    }
    
    private func findPensionPeriodicalActive(pensionContributions: [PensionContributionsDTO]?) -> Bool {
        guard let pensionContributions = pensionContributions else {
            return false
        }
        
        var i = 0
        
        while i < pensionContributions.count && pensionContributions[i].statusPlan != FieldsUtils.STOCK_PERIODICAL_ACTIVE {
            i += 1
        }
        return i != pensionContributions.count
    }
}
