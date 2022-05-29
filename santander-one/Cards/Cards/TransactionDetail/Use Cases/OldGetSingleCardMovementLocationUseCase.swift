import Foundation
import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

class OldGetSingleCardMovementLocationUseCase: UseCase<GetSingleCardMovementLocationUseCaseInput, GetSingleCardMovementLocationUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: GetSingleCardMovementLocationUseCaseInput) throws -> UseCaseResponse<GetSingleCardMovementLocationUseCaseOkOutput, StringErrorOutput> {
        return try self.executeLocation(card: requestValues.card, transaction: requestValues.transaction, transactionDetail: requestValues.transactionDetail)
    }
}

private extension OldGetSingleCardMovementLocationUseCase {
    func executeLocation(card: CardEntity, transaction: CardTransactionEntity, transactionDetail: CardTransactionDetailEntity) throws -> UseCaseResponse<GetSingleCardMovementLocationUseCaseOkOutput, StringErrorOutput> {
        let cardsManager = self.dependenciesResolver.resolve(for: BSANManagersProvider.self).getBsanCardsManager()
        let response = try cardsManager.getCardTransactionLocation(card: card.dto, transaction: transaction.dto, transactionDetail: transactionDetail.dto)
        guard response.isSuccess(), let locationDTO = try response.getResponseData(), let unwrappedStatus = locationDTO.status, let status = checkStatus(unwrappedStatus, location: Location(latitude: locationDTO.latitude, longitude: locationDTO.longitude)) else {
            return .error(StringErrorOutput(nil))
        }
        return .ok(GetSingleCardMovementLocationUseCaseOkOutput(location: CardMovementLocation(locationDTO), status: status))
    }
    
    struct Location {
        let latitude: Double?
        let longitude: Double?
    }
    
    func checkStatus(_ status: String, location: Location) -> CardMovementLocationUseType? {
        switch status {
        case "200", "201":
            return hasLocationOK(location) ? .locatedMovement : .notLocatedMovement
        case "206", "207":
            return .onlineMovement
        case "208", "209":
            return .neverLocalizable
        case "500", "501", "502", "503", "504":
            return .serviceError
        default:
            return nil
        }
    }
    
    func hasLocationOK(_ location: Location) -> Bool {
        guard let latitude = location.longitude, latitude != 0, let longitude = location.longitude, longitude != 0 else {
            return false
        }
        return true
    }
}

struct GetSingleCardMovementLocationUseCaseInput {
    let transaction: CardTransactionEntity
    let transactionDetail: CardTransactionDetailEntity
    let card: CardEntity
}

struct GetSingleCardMovementLocationUseCaseOkOutput {
    let location: CardMovementLocation
    let status: CardMovementLocationUseType
}
