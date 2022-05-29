import CoreFoundationLib
import Operative

public protocol TransferConfirmPresenterProtocol: AnyObject {
    var subView: TransferConfirmViewProtocol? { get set }
    func didSelectContinue()
    func didSelectConfirmWithBiometrics()
    func didSelectShare(_ iban: String)
    var dependenciesResolver: DependenciesResolver { get }
}

// Implement when this operative is on Module
final class TransferConfirmPresenter {
    weak var subView: TransferConfirmViewProtocol?
    var dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension TransferConfirmPresenter: TransferConfirmPresenterProtocol {
    func didSelectShare(_ iban: String) {
    }
    
    func didSelectContinue() {
    }
    
    func didSelectConfirmWithBiometrics() {
    }
}
