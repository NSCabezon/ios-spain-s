import Foundation

protocol CardSettlementMovementsDataSourceProtocol: RestDataSource {
    func getCardSettlementListMovements(params: CardSettlementMovementsRequestParams) throws -> BSANResponse<[CardSettlementMovementDTO]>    
    func getCardSettlementListMovementsByContract(params: CardSettlementMovementsRequestParams) throws -> BSANResponse<[CardSettlementMovementWithPANDTO]>
}
