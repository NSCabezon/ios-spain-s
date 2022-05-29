import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class LoanSimulatorTests: BaseLibraryTests {
    
    override func setUp() {
        environmentDTO = BSANEnvironments.environmentPre
        setLoginUser(newLoginUser: LOGIN_USER.CAMPAIGNS_USER)
        resetDataRepository()
        super.setUp()
    }
    
    func testCheckActive() {
        
        do{
            
            let checkActiveDataResponse = try bsanLoanSimulatorManager?.getActiveCampaigns()
            
            if checkActiveDataResponse == nil {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let checkActiveDataDTO = try getResponseData(response: checkActiveDataResponse!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: checkActiveDataDTO, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testLimitManager() {
        
        let limitManagerUrl = "https://gatewayweb-san-recibos-prox-vencimiento-pre.appls.san01.san.pre.bo1.paas.cloudcenter.corp/api/v1/envioPagos/preconcedidos/limitManager"
        
        do{
            
            let checkActiveDataResponse = try bsanLoanSimulatorManager?.getActiveCampaigns()
            
            if checkActiveDataResponse == nil {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let checkActiveDataDTO = try getResponseData(response: checkActiveDataResponse!),
                let selectedCampaign = getCandidateCampaign(from: checkActiveDataDTO.campaigns),
                let _ = try bsanLoanSimulatorManager?.loadLimits(input: LoadLimitsInput(employee: checkActiveDataDTO.employee, group: getGroupId(from: selectedCampaign.campaignPurpose), campaigns: [selectedCampaign], smartInd: checkActiveDataDTO.indSmart, accountInd: checkActiveDataDTO.indAccount123), selectedCampaignCurrency: selectedCampaign.currency)
                else
            {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: try bsanLoanSimulatorManager?.getLimits(), function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testSimulation() {
        
        let limitManagerUrl = "https://gatewayweb-san-recibos-prox-vencimiento-pre.appls.san01.san.pre.bo1.paas.cloudcenter.corp/api/v1/envioPagos/preconcedidos/limitManager"
        
        let simulationUrl = "https://gatewayweb-san-recibos-prox-vencimiento-pre.appls.san01.san.pre.bo1.paas.cloudcenter.corp/api/v1/envioPagos/preconcedidos/consumo/simulacion"
        
        do{
            
            let checkActiveDataResponse = try bsanLoanSimulatorManager?.getActiveCampaigns()
            
            if checkActiveDataResponse == nil {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let checkActiveDataDTO = try getResponseData(response: checkActiveDataResponse!),
                let selectedCampaign = getCandidateCampaign(from: checkActiveDataDTO.campaigns),
                let _ = try bsanLoanSimulatorManager?.loadLimits(input: LoadLimitsInput(employee: checkActiveDataDTO.employee, group: getGroupId(from: selectedCampaign.campaignPurpose), campaigns: [selectedCampaign], smartInd: checkActiveDataDTO.indSmart, accountInd: checkActiveDataDTO.indAccount123), selectedCampaignCurrency: selectedCampaign.currency),
                let doSimulationResponse = try bsanLoanSimulatorManager?.doSimulation(inputData: LoanSimulatorDataSend(term: 60, amount: 30000))
                else
            {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            
            logTestSuccess(result: doSimulationResponse, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
}

private extension LoanSimulatorTests {
    
    func getCandidateCampaign(from campaigns: [LoanSimulatorCampaignDTO]) -> LoanSimulatorCampaignDTO? {
        let candidateCampaignCodes = ["E04", "E05", "E21", "E22", "E18", "E01"]
        
        return campaigns.filter {
            $0.familyCode == "T05" && candidateCampaignCodes.contains( $0.campaignCode.trim().uppercased().substring(0, 3) ?? "" )
        }.max{ $0.maxAmount < $1.maxAmount }
    }
    
    func getGroupId(from campaignPurpose: String) -> String {
        let purposeId = CampaignPurpose(rawValue: campaignPurpose)
        switch purposeId {
        case .C:
            return "2551"
        case .N:
            return "2549"
        case .T:
            return "2549"
        case .none:
            return "2549"
        }
    }
    
}

public enum CampaignPurpose : String {
    case C
    case N
    case T
}
