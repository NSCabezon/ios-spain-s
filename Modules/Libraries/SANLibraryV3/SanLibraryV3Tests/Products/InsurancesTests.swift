import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class InsurancesTests: BaseLibraryTests {
    typealias T = InsuranceDTO
    
    var usesProtectionInsurances = false
    
    override func setUp() {
        environmentDTO = BSANEnvironments.environmentPre
        setLoginUser(newLoginUser: LOGIN_USER.INSURANCES_LOGIN)
        resetDataRepository()
        super.setUp()
    }
    
    override func getElements<T>(_ sessionData: SessionData) -> [T]? {
        return (usesProtectionInsurances)
            ? sessionData.globalPositionDTO.protectionInsurances as? [T]
            : sessionData.globalPositionDTO.savingsInsurances as? [T]
    }
    
    func testRestRefreshToken(){
        do{
            let environmentDTO = try bsanDataProvider!.getEnvironment()
            let authCredentials = try bsanDataProvider!.getAuthCredentials()
            
            let tokenOAuthResponse = try bsanAuthManager?.tryOauthLogin(bsanEnvironmentDTO: environmentDTO, tokenCredential: authCredentials.soapTokenCredential)

            if let tokenOAuthResponse = tokenOAuthResponse,
                let accessToken = tokenOAuthResponse.accessToken,
                let tokenType = tokenOAuthResponse.tokenType{
                bsanDataProvider!.storeAuthCredentials(AuthCredentials(soapTokenCredential: authCredentials.soapTokenCredential, apiTokenCredential: accessToken, apiTokenType: tokenType))
                
                XCTAssert(true)
                return
            }
        }
        catch _ as NSError{
            XCTAssert(false)
        }
        
        XCTAssert(false)
    }
    
    func testGetInsuranceData(){
        
        do{
            guard let insurance: InsuranceDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let insuranceDataResponse = try bsanInsurancesManager?.getInsuranceData(contractId: insurance.contract?.contratoPKWithNoSpaces ?? "")
            
            if insuranceDataResponse == nil{
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let insuranceDataDTO = try getResponseData(response: insuranceDataResponse!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: insuranceDataDTO, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetParticipants(){

        do{
            usesProtectionInsurances = true
            
            guard let insurance: InsuranceDTO = getElementForTesting(orderInArray: 1, function: #function) else{
                return
            }

            let insuranceDataResponse = try bsanInsurancesManager?.getInsuranceData(contractId: insurance.contract?.contratoPKWithNoSpaces ?? "")

            if insuranceDataResponse == nil{
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }

            guard let insuranceDataDTO = try getResponseData(response: insuranceDataResponse!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            let getParticipantsResponse = try bsanInsurancesManager?.getParticipants(policyId: insuranceDataDTO.policyId ?? "", familyId: insuranceDataDTO.familyId ?? "", thirdPartyInd: insuranceDataDTO.thirdPartyInd ?? "", factoryPolicyNumber: insuranceDataDTO.factoryPolicyNumber ?? "", contractId: insurance.contract?.contratoPKWithNoSpaces ?? "")

            if getParticipantsResponse == nil{
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let getParticipants = try getResponseData(response: getParticipantsResponse!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }

            logTestSuccess(result: getParticipants, function: #function)

        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetBeneficiaries(){
        
        do{
            guard let insurance: InsuranceDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let insuranceDataResponse = try bsanInsurancesManager?.getInsuranceData(contractId: insurance.contract?.contratoPKWithNoSpaces ?? "")
            
            if insuranceDataResponse == nil{
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let insuranceDataDTO = try getResponseData(response: insuranceDataResponse!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            let getBeneficiariesResponse = try bsanInsurancesManager?.getBeneficiaries(policyId: insuranceDataDTO.policyId ?? "", familyId: insuranceDataDTO.familyId ?? "", thirdPartyInd: insuranceDataDTO.thirdPartyInd ?? "", factoryPolicyNumber: insuranceDataDTO.factoryPolicyNumber ?? "", contractId: insurance.contract?.contratoPKWithNoSpaces ?? "")
            
            if getBeneficiariesResponse == nil{
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let getBeneficiaries = try getResponseData(response: getBeneficiariesResponse!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: getBeneficiaries, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetCoverages(){
        
        do{
            self.usesProtectionInsurances = true
            
            guard let insurance: InsuranceDTO = getElementForTesting(orderInArray: 2, function: #function) else{
                return
            }
            
            let insuranceDataResponse = try bsanInsurancesManager?.getInsuranceData(contractId: insurance.contract?.contratoPKWithNoSpaces ?? "")
            
            if insuranceDataResponse == nil{
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let insuranceDataDTO = try getResponseData(response: insuranceDataResponse!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            let getCoveragesResponse = try bsanInsurancesManager?.getCoverages(policyId: insuranceDataDTO.policyId ?? "", familyId: insuranceDataDTO.familyId ?? "", thirdPartyInd: insuranceDataDTO.thirdPartyInd ?? "", factoryPolicyNumber: insuranceDataDTO.factoryPolicyNumber ?? "", contractId: insurance.contract?.contratoPKWithNoSpaces ?? "")
            
            if getCoveragesResponse == nil{
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let getCoverages = try getResponseData(response: getCoveragesResponse!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: getCoverages, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }

}

