import UserNotifications
import CoreFoundationLib
import UIKit

open class SanNotificationService: UNNotificationServiceExtension {
    public var dependenciesEngine: DependenciesDefault = DependenciesDefault()
    private var contentHandler: ((_ contentToDeliver: UNNotificationContent) -> Void)?
    private var modifiedNotificationContent: UNMutableNotificationContent?
    
    open override func didReceive(_ request: UNNotificationRequest,
                                  withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        modifiedNotificationContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        saveNotification(request)
        guard
            let mediaUrlString = request.content.userInfo["_mediaUrl"] as? String,
            let mediaUrl = URL(string: mediaUrlString)
        else {
            contentHandler(request.content)
            return
        }
        let session = URLSession(configuration: URLSessionConfiguration.default)
        session.downloadTask(
            with: mediaUrl,
            completionHandler: { [weak self] (_ location: URL?, _ response: URLResponse?, _ error: Error?) in
                if let downloadResponse = response as? HTTPURLResponse,
                   let location = location,
                   downloadResponse.statusCode >= 200 && downloadResponse.statusCode <= 299,
                   error == nil {
                    let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent(mediaUrl.lastPathComponent)
                    try? FileManager.default.removeItem(at: cacheDirectory)
                    if (try? FileManager.default.moveItem(at: location, to: cacheDirectory)) != nil,
                       let mediaAttachment = self?.createMediaAttachment(cacheDirectory) {
                        self?.modifiedNotificationContent?.attachments = [mediaAttachment]
                    }
                }
                guard let modifiedNotificationContent = self?.modifiedNotificationContent else {
                    contentHandler(request.content)
                    return
                }
                contentHandler(modifiedNotificationContent)
            }
        ).resume()
    }
    
    /// Called just before the extension will be terminated by the system.
    /// Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    public override func serviceExtensionTimeWillExpire() {
        guard
            let contentHandler = contentHandler,
            let bestAttemptContent =  modifiedNotificationContent
        else { return }
        contentHandler(bestAttemptContent)
    }
}

private extension SanNotificationService {
    func createMediaAttachment(_ localMediaUrl: URL) -> UNNotificationAttachment? {
        let clippingRect = CGRect.zero
        let mediaAttachment = try? UNNotificationAttachment(
            identifier: "attachmentIdentifier",
            url: localMediaUrl,
            options: [
                UNNotificationAttachmentOptionsThumbnailClippingRectKey: clippingRect.dictionaryRepresentation,
                UNNotificationAttachmentOptionsThumbnailHiddenKey: false
            ]
        )
        return mediaAttachment
    }
    
    func saveNotification(_ request: UNNotificationRequest) {
        let dependencies = self.dependenciesEngine.resolve(for: NotificationServiceDependenciesProtocol.self)
        let pushInfo = PushInfoFactory.create(from: request.content.userInfo, date: nil)
        SaveNotificationManager(dependencies: dependencies).saveNotification(info: pushInfo)
    }
}
