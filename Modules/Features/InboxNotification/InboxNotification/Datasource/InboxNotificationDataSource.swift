//
//  InboxNotificationDataSource.swift
//  InboxNotification
//
//  Created by Boris Chirino Fernandez on 11/05/2021.
//

import CoreFoundationLib
import ESCommons

final class InboxNotificationDataSource {
    let dependenciesResolver: DependenciesResolver
    private lazy var inboxMessagesManager: InboxMessagesManager = {
        self.dependenciesResolver.resolve()
    }()
    init(dependencies: DependenciesResolver) {
        self.dependenciesResolver = dependencies
    }
}

extension InboxNotificationDataSource: InboxNotificationDataSourceProtocol {
    
    func getInbox(completion: @escaping(_ list: [PushNotificationConformable]?) -> Void) {
        self.inboxMessagesManager.getUserInbox(completion: completion)
    }

    func delete(notification: [PushNotificationConformable], completion: @escaping(Bool) -> Void) {
        self.inboxMessagesManager.delete(notification: notification, completion: completion)
    }
}
