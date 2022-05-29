import CoreDomain

public protocol BSANPensionsManager {
    func getPensionTransactions(forPension pension: PensionDTO, pagination: PaginationDTO?, dateFilter: DateFilter?) throws -> BSANResponse<PensionTransactionsListDTO>
    func getPensionDetail(forPension pension: PensionDTO) throws -> BSANResponse<PensionDetailDTO>
    func getPensionContributions(pensionDTO: PensionDTO, pagination: PaginationDTO?) throws -> BSANResponse<PensionContributionsListDTO>
    func getAllPensionContributions(pensionDTO: PensionDTO) throws -> BSANResponse<PensionContributionsListDTO>
    func getClausesPensionMifid(pensionDTO: PensionDTO, pensionInfoOperationDTO: PensionInfoOperationDTO, amountDTO: AmountDTO) throws -> BSANResponse<PensionMifidDTO>
    func confirmExtraordinaryContribution(pensionDTO: PensionDTO, amountDTO: AmountDTO, signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<Void>
    func confirmPeriodicalContribution(pensionDTO: PensionDTO, pensionContributionInput: PensionContributionInput, signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<Void>
    func changePensionAlias(_ pension: PensionDTO, newAlias: String) throws -> BSANResponse<Void>
}
