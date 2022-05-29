import Foundation
import SANLegacyLibrary

public class BSANLoanSimulatorManagerImplementation: BSANBaseManager, BSANLoanSimulatorManager {
    private let sanRestServices: SanRestServices
    private let bsanAuthManager: BSANAuthManager
    private var loanSimulatorData: LoanSimulatorLimitDTO?
    private let DEFAULT_CHANNEL = "002"
    private let DEFAULT_COMPANY_ID = "0049"
    private let DEFAULT_PRODUCT_CODE = "143"
    private let DEFAULT_SUB_TYPE_PRODUCT_CODE = "538"
    private let DEFAULT_INSURANCE_SIM_FLAG = "N"

    public init(bsanDataProvider: BSANDataProvider, bsanAuthManager: BSANAuthManager, sanRestServices: SanRestServices) {
        self.bsanAuthManager = bsanAuthManager
        self.sanRestServices = sanRestServices
        super.init(bsanDataProvider: bsanDataProvider)
    }
    
    public func getActiveCampaigns() throws -> BSANResponse<CampaignsCheckLoanSimulatorDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let loanSimulatorDataSource = PreGrantedLoanSimulatorDataSourceImpl(sanRestServices: sanRestServices, bsanDataProvider: bsanDataProvider)
        let storedCheckActiveDataDTO = try bsanDataProvider.get(\.loanSimulatorCheckActiveDataDTO)
        if storedCheckActiveDataDTO != nil {
            return BSANOkResponse(storedCheckActiveDataDTO)
        } else {
            let checkActiveDataDTOResponse = try loanSimulatorDataSource.checkActive(channel: DEFAULT_CHANNEL, companyId: DEFAULT_COMPANY_ID)
            if checkActiveDataDTOResponse.isSuccess(), let responseData = try checkActiveDataDTOResponse.getResponseData() {
                bsanDataProvider.store(checkActiveData: responseData)
            }
            return checkActiveDataDTOResponse
        }
    }
    
    public func loadLimits(input: LoadLimitsInput, selectedCampaignCurrency: String) throws -> BSANResponse<Void> {
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let loanSimulatorDataSource = PreGrantedLoanSimulatorDataSourceImpl(sanRestServices: sanRestServices, bsanDataProvider: bsanDataProvider)
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let limitsDataDTOResponse = try loanSimulatorDataSource.limitManager(body: buildLimitManagerBody(employee: input.employee,
                                                                                                         group: input.group,
                                                                                                         campaignsToRequest: input.campaigns,
                                                                                                         smartInd: input.smartInd,
                                                                                                         accountInd: input.accountInd,
                                                                                                         customerSegment: input.customerSegment
            )
        )
        if limitsDataDTOResponse.isSuccess(), let responseData = try limitsDataDTOResponse.getResponseData(), let selectedCampaign = input.campaigns.first {
            bsanDataProvider.store(loanSimulatorLimitDto: responseData)
            bsanDataProvider.store(selectedCampaign: selectedCampaign)
            self.loanSimulatorData = responseData
        }
        return BSANOkResponse(nil)
    }
    
    public func getLimits() throws -> BSANResponse<LoanSimulatorProductLimitsDTO> {
        guard let data = try bsanDataProvider.get(\.loanSimulatorLimitDto) else {
            return BSANErrorResponse(nil)
        }
        
        guard let product = data.purposeList?.first?.productsList?.first else {
            return BSANErrorResponse(nil)
        }
        return BSANOkResponse(product)
    }
    
    
    public func doSimulation(inputData: LoanSimulatorDataSend) throws -> BSANResponse<LoanSimulatorConditionsDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        guard let checkActiveData = try bsanDataProvider.get(\.loanSimulatorCheckActiveDataDTO) else {
            return BSANErrorResponse(nil)
        }
        guard let product = try bsanDataProvider.get(\.loanSimulatorLimitDto)?.purposeList?.first?.productsList?.first else {
            return BSANErrorResponse(nil)
        }
        guard let selectedCampaign = try bsanDataProvider.get(\.loanSimulatorSelectedCampaignDto) else {
            return BSANErrorResponse(nil)
        }
        let loanSimulatorDataSource = PreGrantedLoanSimulatorDataSourceImpl(sanRestServices: sanRestServices, bsanDataProvider: bsanDataProvider)
        let bodyToSend = LoanSimulationDTO(companyId: DEFAULT_COMPANY_ID,
                                           centerId: checkActiveData.center?.center,
                                           currency: selectedCampaign.currency,
                                           productCode: DEFAULT_PRODUCT_CODE,
                                           productSubType: DEFAULT_SUB_TYPE_PRODUCT_CODE,
                                           productStandard: product.standardReference,
                                           amount: inputData.amount,
                                           insuranceSimFlag: DEFAULT_INSURANCE_SIM_FLAG,
                                           term: inputData.term,
                                           maximumFee: product.maximumFee)
        let checkActiveDataDTOResponse =  try loanSimulatorDataSource.simulation(body: bodyToSend)
        return checkActiveDataDTOResponse
    }
    
}

private extension BSANLoanSimulatorManagerImplementation  {
    
    func buildLimitManagerBody(employee: Bool, group: String, campaignsToRequest: [LoanSimulatorCampaignDTO], smartInd: String, accountInd: String, customerSegment: String) -> CampaignQueryDTO {
        
        return CampaignQueryDTO(employee: employee,
                                group: group,
                                channel: DEFAULT_CHANNEL,
                                companyId: DEFAULT_COMPANY_ID,
                                campaigns: campaignsToRequest,
                                smartInd: smartInd,
                                accountInd: accountInd,
                                customerSegment: customerSegment
        )
    }
}
