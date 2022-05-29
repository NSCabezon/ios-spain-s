import Operative
import CoreFoundationLib

protocol OpinatorParametrizable {
    var parameters: [PresentationOpinatorParameter: String]? { get }
}
