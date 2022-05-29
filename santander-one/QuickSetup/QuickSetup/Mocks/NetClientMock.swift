import Foundation
import CoreFoundationLib

final public class NetClientMock: NetClient {
    public func loadURL(_ url: String, date: Date?) -> NetClientResponse {
        .notLoaded
    }
}
