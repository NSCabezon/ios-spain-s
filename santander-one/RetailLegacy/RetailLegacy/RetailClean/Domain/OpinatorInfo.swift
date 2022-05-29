import Operative
import CoreFoundationLib

protocol OpinatorInfo: CaseIterable {
    var titleKey: String { get }
    var endPoint: String { get }
    var params: [OpinatorParameter] { get }
    var page: OpinatorPage { get }
}
