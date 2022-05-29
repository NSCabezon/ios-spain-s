//

import Foundation

protocol ProductHeaderCompatible {
    var title: String { get }
    var subtitle: String { get }
    var amount: Amount? { get }
    var pendingText: LocalizedStylableText? { get }
    var isPending: Bool { get }
}
