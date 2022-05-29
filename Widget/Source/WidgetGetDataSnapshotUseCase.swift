import Foundation
import CoreFoundationLib
import RetailLegacy

class WidgetGetDataSnapshotUseCase: LocalAuthLoginDataUseCase<Void, WidgetGetDataSnapshotUseCaseOkOutput, StringErrorOutput> {
    private let daoDataSnapshot: DAODataSnapshot
    
    init(daoDataSnapshot: DAODataSnapshot) {
        self.daoDataSnapshot = daoDataSnapshot
        super.init()
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<WidgetGetDataSnapshotUseCaseOkOutput, StringErrorOutput> {
        guard getLocalAuthData(requestValues: requestValues) != nil, getLocalWidgetEnabled() else {
            return UseCaseResponse.ok(WidgetGetDataSnapshotUseCaseOkOutput(dataSnapshot: nil))
        }
        return UseCaseResponse.ok(WidgetGetDataSnapshotUseCaseOkOutput(dataSnapshot: daoDataSnapshot.get()))
    }
}

struct WidgetGetDataSnapshotUseCaseOkOutput {
    let dataSnapshot: DataSnapshot?
}
