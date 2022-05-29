//
//  ScheduledTransferInputRepresentable.swift
//  CoreFoundationLib
//
//  Created by José María Jiménez Pérez on 27/7/21.
//

public struct SendMoneyScheduledTransferInput {
    public let ibanDestinationRepresentable: IBANRepresentable?
    public let amountRepresentable: AmountRepresentable?
    public let dateNextExecution: Date?
    public let dateStartValidity: Date?
    public let dateEndValidity: Date?
    public let concept: String?
    public let saveAsUsual: Bool?
    public let saveAsUsualAlias: String?
    public let beneficiary: String?
    public let transferType: String?
    public let actuanteCompany: String?
    public let actuanteCode: String?
    public let actuanteNumber: String?
    public let periodicity: String?
    public let workingDayIssue: String?
    public let nameBankIbanBeneficiary: String?
    
    public init(ibanDestinationRepresentable: IBANRepresentable?,
                amountRepresentable: AmountRepresentable?,
                dateNextExecution: Date?,
                dateStartValidity: Date?,
                dateEndValidity: Date?,
                concept: String?,
                saveAsUsual: Bool?,
                saveAsUsualAlias: String?,
                beneficiary: String?,
                transferType: String?,
                actuanteCompany: String?,
                actuanteCode: String?,
                actuanteNumber: String?,
                periodicity: String?,
                workingDayIssue: String?,
                nameBankIbanBeneficiary: String?) {
        self.ibanDestinationRepresentable = ibanDestinationRepresentable
        self.amountRepresentable = amountRepresentable
        self.dateNextExecution = dateNextExecution
        self.dateStartValidity = dateStartValidity
        self.dateEndValidity = dateEndValidity
        self.concept = concept
        self.saveAsUsual = saveAsUsual
        self.saveAsUsualAlias = saveAsUsualAlias
        self.beneficiary = beneficiary
        self.transferType = transferType
        self.actuanteCompany = actuanteCompany
        self.actuanteCode = actuanteCode
        self.actuanteNumber = actuanteNumber
        self.periodicity = periodicity
        self.workingDayIssue = workingDayIssue
        self.nameBankIbanBeneficiary = nameBankIbanBeneficiary
    }
    
    public func stringReverseWithDashSeparator(date: Date?) -> String? {
        guard let date = date else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        let day = formatter.string(from: date)
        formatter.dateFormat = "MM"
        let month = formatter.string(from: date)
        formatter.dateFormat = "yyyy"
        let year = formatter.string(from: date)
        return year + "-" + month + "-" + day
    }
}
