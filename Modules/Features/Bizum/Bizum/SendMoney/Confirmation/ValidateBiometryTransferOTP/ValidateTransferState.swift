import Foundation
import CoreFoundationLib

protocol ValidateTransferState {
    var tokenPush: GetLocalPushTokenUseCaseOkOutput? { get set }
    func execute(_ handler: @escaping (Bool, String?) -> Void)
}
