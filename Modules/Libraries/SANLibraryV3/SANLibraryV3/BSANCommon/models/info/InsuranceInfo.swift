import Foundation

public class InsuranceInfo: Codable {

    public var insuranceData: [String: InsuranceDataDTO] = [:]
    public var participants: [String: [InsuranceParticipantDTO]] = [:]
    public var beneficiaries: [String: [InsuranceBeneficiaryDTO]] = [:]
    public var coverages: [String: [InsuranceCoverageDTO]] = [:]


}
