import CoreDomain
import Foundation

public struct ModifyScheduledTransferInput {
    public let beneficiaryIBAN: IBANDTO
    public let nextExecutionDate: DateModel
    public let amount: AmountDTO
    public let concept: String?
    public let beneficiary: String
    public let transferOperationType: TransferOperationType?
    public let startDateValidity: DateModel?
    public let endDateValidity: DateModel?
    public let periodicalType: PeriodicalTypeTransferDTO?
    public let scheduledDayType: ScheduledDayDTO?
    
    
    public init(beneficiaryIBAN: IBANDTO, nextExecutionDate: DateModel, amount: AmountDTO, concept: String?, beneficiary: String, transferOperationType: TransferOperationType?, startDateValidity: DateModel?, endDateValidity: DateModel?, periodicalType: PeriodicalTypeTransferDTO?, scheduledDayType: ScheduledDayDTO?) {
        self.beneficiaryIBAN = beneficiaryIBAN
        self.nextExecutionDate = nextExecutionDate
        self.amount = amount
        self.concept = concept
        self.beneficiary = beneficiary
        self.transferOperationType = transferOperationType
        self.startDateValidity = startDateValidity
        self.endDateValidity = endDateValidity
        self.periodicalType = periodicalType
        self.scheduledDayType = scheduledDayType
    }
}
