import Foundation
import OpenCombine
import CoreDomain

public struct DefaultLoanDetailConfig: LoanDetailConfigRepresentable {
    public var isEnabledFirstHolder: Bool = true
    public var isEnabledInitialExpiration: Bool = true
    public var aliasIsNeeded: Bool = true
    public var isEnabledLastOperationDate: Bool = false
    public var isEnabledNextInstallmentDate: Bool = false
    public var isEnabledCurrentInterestAmount: Bool = false
    public func formatPeriodicity(_ periodicity: String) -> String? {
        return nil
    }
    
    public init() {}
}
