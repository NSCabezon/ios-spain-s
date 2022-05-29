import SANLegacyLibrary
import CoreDomain

struct MockBSANPensionsManager: BSANPensionsManager {
    func getPensionTransactions(forPension pension: PensionDTO, pagination: PaginationDTO?, dateFilter: DateFilter?) throws -> BSANResponse<PensionTransactionsListDTO> {
        fatalError()
    }
    
    func getPensionDetail(forPension pension: PensionDTO) throws -> BSANResponse<PensionDetailDTO> {
        fatalError()
    }
    
    func getPensionContributions(pensionDTO: PensionDTO, pagination: PaginationDTO?) throws -> BSANResponse<PensionContributionsListDTO> {
        fatalError()
    }
    
    func getAllPensionContributions(pensionDTO: PensionDTO) throws -> BSANResponse<PensionContributionsListDTO> {
        fatalError()
    }
    
    func getClausesPensionMifid(pensionDTO: PensionDTO, pensionInfoOperationDTO: PensionInfoOperationDTO, amountDTO: AmountDTO) throws -> BSANResponse<PensionMifidDTO> {
        fatalError()
    }
    
    func confirmExtraordinaryContribution(pensionDTO: PensionDTO, amountDTO: AmountDTO, signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<Void> {
        fatalError()
    }
    
    func confirmPeriodicalContribution(pensionDTO: PensionDTO, pensionContributionInput: PensionContributionInput, signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<Void> {
        fatalError()
    }
    
    func changePensionAlias(_ pension: PensionDTO, newAlias: String) throws -> BSANResponse<Void> {
        fatalError()
    }
}
