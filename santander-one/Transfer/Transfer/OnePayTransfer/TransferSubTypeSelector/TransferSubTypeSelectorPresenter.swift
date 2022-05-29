import Foundation
import CoreFoundationLib

public protocol TransferSubTypeSelectorPresenterProtocol: AnyObject {
    var subTypeView: TransferSubTypeSelectorViewProtocol? { get set }
    func didSelectContinue()
    func viewDidAppear()
    func didSelectSubType(_ viewModel: TransferSubTypeItemViewModel)
    func didSelectHireTransferPackage()
    func didTapBack()
}

class TransferSubTypeSelectorPresenter {
    
    weak var subTypeView: TransferSubTypeSelectorViewProtocol?
    let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension TransferSubTypeSelectorPresenter: TransferSubTypeSelectorPresenterProtocol {
    func didTapBack() {}
    
    func viewDidAppear() {}
    
    func didSelectContinue() {}
    
    func didSelectSubType(_ viewModel: TransferSubTypeItemViewModel) {}
    
    func didSelectHireTransferPackage() {}
}
