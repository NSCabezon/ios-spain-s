import Foundation
import CoreFoundationLib
import MarketingCloudSDK

final class DeleteSalesForceInboxMessagesUseCaseUseCase: UseCase<DeleteSalesForceInboxMessagesUseCaseUseCaseInput, Void, StringErrorOutput> {
    
    private let sdk = MarketingCloudSDK.sharedInstance()
    
    override func executeUseCase(requestValues: DeleteSalesForceInboxMessagesUseCaseUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        var result: [Bool] = []
        
        requestValues.notifications.forEach { (notificationDict) in
            let deleteResult = sdk.sfmc_markMessageDeleted(notificationDict)
            result.append(deleteResult)
        }
        let anyFailure = result.first(where: {$0.isFalse}) ?? false
        return anyFailure ? .error(StringErrorOutput(nil)) : .ok()
    }
}

struct DeleteSalesForceInboxMessagesUseCaseUseCaseInput {
    let notifications: [[String: AnyObject]]
}
