//
//  EditFavouriteConfirmationPresenter.swift
//  Account
//
//  Created by Jose Enrique Montero Prieto on 27/07/2021.
//

import Foundation
import Operative
import CoreFoundationLib

protocol EditFavouriteConfirmationPresenterProtocol: OperativeConfirmationPresenterProtocol, MenuTextWrapperProtocol {
    var view: EditFavouriteConfirmationViewProtocol? { get set }
    func viewDidLoad()
}

final class EditFavouriteConfirmationPresenter {
    weak var view: EditFavouriteConfirmationViewProtocol?
    let dependenciesResolver: DependenciesResolver
    var number: Int = 1
    var isBackButtonEnabled: Bool = true
    var isCancelButtonEnabled: Bool = false
    var container: OperativeContainerProtocol?
    var operativeData: EditFavouriteOperativeData {
        guard let container = self.container else { fatalError() }
        return container.get()
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    func didSelectContinue() {
        self.view?.showLoading()
        let input = ValidateEditFavouriteUseCaseInput( beneficiaryName: operativeData.newBeneficiaryName ?? "", iban: self.operativeData.newDestinationAccount, payeeId: operativeData.selectedFavourite?.payeeId ?? ""
        )
        self.validate(input)
    }
}

extension EditFavouriteConfirmationPresenter: EditFavouriteConfirmationPresenterProtocol {
    func viewDidLoad() {
        self.trackScreen()
        self.createView()
    }
}

private extension EditFavouriteConfirmationPresenter {
    func createView() {
        let builder = EditFavouriteConfirmationBuilder(operativeData: self.operativeData, dependenciesResolver: self.dependenciesResolver)
        builder.addAlias()
        builder.addBeneficiary()
        builder.addIban()
        builder.addCountryDestination()
        self.view?.setContinueTitle(localized("generic_button_confirm"))
        self.view?.add(builder.build())
    }
    
    func validate(_ input: ValidateEditFavouriteUseCaseInput) {
        Scenario(useCase: self.dependenciesResolver.resolve(for: ValidateEditFavouriteUseCaseProtocol.self), input: input)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { [weak self] result in
                guard let self = self else { return }
                self.view?.dismissLoading(completion: { [weak self] in
                    guard let self = self else { return }
                    self.container?.save(result.signatureWithToken)
                    self.container?.stepFinished(presenter: self)
                })
            }
            .onError { [weak self] error in
                guard let self = self else { return }
                self.view?.dismissLoading(completion: {
                    self.view?.showError(error.getErrorDesc())
                })
            }
    }
}

extension EditFavouriteConfirmationPresenter: AutomaticScreenTrackable {
    var trackerPage: EditFavouriteConfirmationPage {
        return EditFavouriteConfirmationPage()
    }
    var trackerManager: TrackerManager {
        return self.dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
