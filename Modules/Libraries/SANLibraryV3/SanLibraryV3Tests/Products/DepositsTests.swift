import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class DepositsTests: BaseLibraryTests {
    typealias T = DepositDTO
    
    override func setUp() {
        setLoginUser(newLoginUser: LOGIN_USER.DEPOSITS_PAGINATION_LOGIN)
        resetDataRepository()
        super.setUp()
    }
    
    override func getElements<T>(_ sessionData: SessionData) -> [T]? {
        return sessionData.globalPositionDTO.deposits as? [T]
    }
    
    func testGetDepositImpositionsTransactions(){
        
        do{
            guard let deposit: DepositDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let impositionsResponse = try bsanDepositsManager!.getDepositImpositionsTransactions(depositDTO: deposit, pagination: nil)
            
            guard let impositionsDTO = try getResponseData(response: impositionsResponse) else {
                logTestError(errorMessage: "getDepositImpositionsTransactions RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: impositionsDTO, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetDepositImpositionsTransactionsWithPagination(){
        
        do{
            //EL USUARIO DE PRUEBAS DE DEPOSIT_PAGINATION TIENE PAGINADO EN SU 2º DEPOSITO
            guard let deposit: DepositDTO = getElementForTesting(orderInArray: 1, function: #function) else{
                return
            }

            let impositionsResponse = try bsanDepositsManager!.getDepositImpositionsTransactions(depositDTO: deposit, pagination: nil)
            
            guard let impositionsDTO = try getResponseData(response: impositionsResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            print("\n\n\(#function) :\n\(impositionsDTO)")

            //PARA PROBAR PAGINACION
            do{
                let impositionsResponseSecondPage = try bsanDepositsManager!.getDepositImpositionsTransactions(depositDTO: deposit, pagination: impositionsDTO.pagination)
                
                guard let impositionsDTOSecondPage = try getResponseData(response: impositionsResponseSecondPage) else {
                    logTestError(errorMessage: "SecondPage RETURNED NO RESPONSE DATA", function: #function)
                    return
                }
                
                logTestSuccess(result: impositionsDTOSecondPage, function: #function)
                
            } catch let error{
                logTestException(error: error, function: #function)
            }
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetImpositionTransactions(){
        
        do{
            guard let deposit: DepositDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let impositionsResponse = try bsanDepositsManager!.getDepositImpositionsTransactions(depositDTO: deposit, pagination: nil)
            
            guard let impositionsDTO = try getResponseData(response: impositionsResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let impositionDTO = impositionsDTO.impositionsDTOs.first else {
                logTestError(errorMessage: "impositionsDTO HAS NO impositionsDTO", function: #function)
                return
            }
            
            let impositionTransactionsResponse = try bsanDepositsManager!.getImpositionTransactions(impositionDTO: impositionDTO, pagination: nil, dateFilter: DateFilter.getDateFilterFor(numberOfYears: -10))
            
            guard let impositionTransactionsDTO = try getResponseData(response: impositionTransactionsResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: impositionTransactionsDTO, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetImpositionLiquidations(){
        
        do{
            guard let deposit: DepositDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let impositionsResponse = try bsanDepositsManager!.getDepositImpositionsTransactions(depositDTO: deposit, pagination: nil)
            
            guard let impositionsDTO = try getResponseData(response: impositionsResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let impositionDTO = impositionsDTO.impositionsDTOs.first else {
                logTestError(errorMessage: "impositionsDTO HAS NO impositionsDTO", function: #function)
                return
            }
            
            let getImpositionLiquidationsResponse = try bsanDepositsManager!.getImpositionLiquidations(impositionDTO: impositionDTO, pagination: nil, dateFilter: DateFilter.getDateFilterFor(numberOfYears: -10))
            
            guard let getImpositionLiquidations = try getResponseData(response: getImpositionLiquidationsResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: getImpositionLiquidations, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetLiquidationDetail(){
        
        do{
            guard let deposit: DepositDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let impositionsResponse = try bsanDepositsManager!.getDepositImpositionsTransactions(depositDTO: deposit, pagination: nil)
            
            guard let impositionsDTO = try getResponseData(response: impositionsResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let impositionDTO = impositionsDTO.impositionsDTOs.first else {
                logTestError(errorMessage: "impositionsDTO HAS NO impositionsDTO", function: #function)
                return
            }
            
            let getImpositionLiquidationsResponse = try bsanDepositsManager!.getImpositionLiquidations(impositionDTO: impositionDTO, pagination: nil, dateFilter: DateFilter.getDateFilterFor(numberOfYears: -10))
            
            guard let getImpositionLiquidations = try getResponseData(response: getImpositionLiquidationsResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            if getImpositionLiquidations.liquidationDTOS == nil{
                logTestError(errorMessage: "getImpositionLiquidations HAS NO liquidationDTOS", function: #function)
                return
            }
            
            guard let liquidationDTO = getImpositionLiquidations.liquidationDTOS!.first else {
                logTestError(errorMessage: "getImpositionLiquidations HAS NO liquidationDTOS", function: #function)
                return
            }
            
            let getLiquidationDetailResponse = try bsanDepositsManager!.getLiquidationDetail(impositionDTO: impositionDTO, liquidationDTO: liquidationDTO)
            
            guard let getLiquidationDetail = try getResponseData(response: getLiquidationDetailResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: getLiquidationDetail, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
}
