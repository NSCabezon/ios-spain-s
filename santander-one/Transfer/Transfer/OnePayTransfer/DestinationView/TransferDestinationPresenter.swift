import Foundation
import CoreFoundationLib
import Operative
import TransferOperatives

public protocol TransferDestinationPresenterProtocol: ValidatableFormPresenterProtocol {
    var dataEntryView: TransferDestinationViewProtocol? { get set }
    func viewDidLoad()
    func changeAccountSelected()
    func didChangeSpanishCheck(_ state: Bool)
    func didChangeAliasCheck(_ state: Bool)
    func updateInfo(_ ibanText: String?, nameText: String?, aliasText: String?, transferTime: SendMoneyDateTypeFilledViewModel, isFavouriteSelected: Bool)
    func didSelectBeneficiary(_ transferEmitted: TransferEmittedEntity?)
    func onContinueButtonClicked()
    func getMaxLengthAlias() -> Int
    func differenceOfDaysToDeferredTransfers() -> Int
}

final class TransferDestinationPresenter {
    weak var dataEntryView: TransferDestinationViewProtocol?
    let dependenciesResolver: DependenciesResolver
    
    var coordinator: TransferHomeModuleCoordinator {
        return self.dependenciesResolver.resolve(for: TransferHomeModuleCoordinator.self)
    }
    var contactsEngine: ContactsEngineProtocol {
        return self.dependenciesResolver.resolve(for: ContactsEngineProtocol.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension TransferDestinationPresenter: ModuleLauncher {}
