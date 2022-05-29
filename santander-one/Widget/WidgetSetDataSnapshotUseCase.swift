import Foundation
import CoreFoundationLib

class WidgetSetDataSnapshotUseCase: UseCase<WidgetSetDataSnapshotUseCaseInput, Void, StringErrorOutput> {
    private let daoDataSnapshot: DAODataSnapshot
    
    init(daoDataSnapshot: DAODataSnapshot) {
        self.daoDataSnapshot = daoDataSnapshot
        super.init()
    }
    
    override func executeUseCase(requestValues: WidgetSetDataSnapshotUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        _ = daoDataSnapshot.set(dataSnapshot: requestValues.dataSnapshot)
        return UseCaseResponse.ok()
    }
}

struct WidgetSetDataSnapshotUseCaseInput {
    let dataSnapshot: DataSnapshot
}
