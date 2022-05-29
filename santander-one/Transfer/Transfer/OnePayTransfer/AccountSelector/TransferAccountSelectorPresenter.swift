import Foundation
import CoreFoundationLib
import Operative

public protocol TransferAccountSelectorPresenterProtocol: AnyObject {
    var selectorView: TransferAccountSelectorViewProtocol? { get set }
    func viewDidAppear()
    func didSelectAccount(_ viewModel: TransferAccountItemViewModel)
}
