import Foundation
import CoreDomain

public class SessionData: Codable, SessionDataRepresentable {
    
    // Logged User
    var userDTO: UserDTO?
    // PB user
    public var isPB: Bool = false
    // Global Position
    public var globalPositionDTO: GlobalPositionDTO = GlobalPositionDTO()
    public var newGlobalPositionDTO: GlobalPositionDTO = GlobalPositionDTO()
    // Info classes (Wrappers)
    public var portfolioInfo: PortfolioInfo = PortfolioInfo()
    public var cardInfo: CardInfo = CardInfo()
    public var insuranceInfo: InsuranceInfo = InsuranceInfo()
    public var sociusInfo: SociusInfo = SociusInfo()
    public var accountInfo = AccountInfo()
    public var fundInfo = FundInfo()
    public var loanInfo = LoanInfo()
    public var depositInfo = DepositInfo()
    public var pensionInfo = PensionInfo()
    public var stockInfo = StockInfo()
    public var signStatusInfo: SignStatusInfo?
    public var managersInfo = ManagersInfo()
    public var bizumInfo = BizumInfo()
    // Others fields
    public var transferInfo = TransferInfo()
    public var userCampaigns: [String]?
    public var userSegmentDTO: UserSegmentDTO?
    public var cmpsDTO: CMPSDTO?
    public var isSelect: Bool?
    public var isSmart: Bool?
    public var getHistoricalTransferCompleted: Bool?
    public var accountEasyPayCampaigns: [AccountEasyPayDTO]?
    public var cardApplePayStatus: [String: CardApplePayStatusDTO] = [:]
    public var loanSimulatorLimitDto: LoanSimulatorLimitDTO?
    public var loanSimulatorSelectedCampaignDto: LoanSimulatorCampaignDTO?
    public var loanSimulatorCheckActiveDataDTO: CampaignsCheckLoanSimulatorDTO?
    public var pendingSolicitudes: [PendingSolicitudeDTO]?
    public var codeOTPPush: ReturnCodeOTPPush?
    public var customerContractDictionary: [String: CustomerContractListDTO] = [:]
    public var checkOnePlanStatusCodeDictionary: [String: Int] = [:]
    public var aviosDetail: AviosDetailDTO?
    public var recoveryNotices: [RecoveryDTO]?
    public var financialAgregatorDTO: FinancialAgregatorDTO?
    public var billAndTaxesInfo = BillAndTaxesInfo()
    public var cardSettlementDetailInfo = CardSettlementDetailsInfo()
    public var financeableCardMovementsInfo = FinanceableCardMovementsInfo()
    
    init(_ userDTO: UserDTO) {
        self.userDTO = userDTO
        self.isPB = userDTO.isPB
    }
    
    init(_ isPB: Bool) {
        self.userDTO = nil
        self.isPB = isPB
    }
    
    func updateSessionData(_ globalPositionDTO: GlobalPositionDTO, _ isPB: Bool) {
        self.globalPositionDTO = globalPositionDTO
        self.isPB = isPB
    }
}
