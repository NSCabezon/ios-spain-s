//
//  EditFavouriteHolderAndAccountPresenter.swift
//  Transfer
//
//  Created by Jose Enrique Montero Prieto on 05/08/2021.
//

import CoreFoundationLib
import Operative

protocol EditFavouriteHolderAndAccountPresenterProtocol: ValidatableFormPresenterProtocol, OperativeStepPresenterProtocol {
    var view: EditFavouriteHolderAndAccountViewProtocol? { get set }
    func viewDidLoad()
    func didSelectContinue()
}

final class EditFavouriteHolderAndAccountPresenter {
    var view: EditFavouriteHolderAndAccountViewProtocol?
    var number: Int = 0
    var isBackButtonEnabled: Bool = true
    var isCancelButtonEnabled: Bool = false
    var container: OperativeContainerProtocol?
    var fields: [ValidatableField] = []
    private let dependencies: DependenciesResolver
    lazy var operativeData: EditFavouriteOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependencies = dependenciesResolver
    }
}

private extension EditFavouriteHolderAndAccountPresenter {
    func addComponents() {
        self.addAlias()
        self.addHolder()
        self.addAccount()
        self.addCountryDestination()
        self.addCurrency()
    }
    
    func validate() {
        let textFieldValues = self.fields.compactMap { $0.fieldValue }
        guard textFieldValues.count == 2,
              let iban = self.view?.ibanText
        else {
            self.view?.dismissLoading()
            return
        }
        let alias = textFieldValues[1]
        let beneficiaryName = textFieldValues[0]
        let input = PreValidateEditFavouriteUseCaseInput(iban: iban, alias: alias)
        Scenario(useCase: self.dependencies.resolve(firstTypeOf: PreValidateEditFavouriteUseCaseProtocol.self), input: input)
            .execute(on: self.dependencies.resolve())
            .onSuccess({ [weak self] _ in
                self?.view?.dismissLoading(completion: { [weak self] in
                    guard let self = self else { return }
                    self.operativeData.newDestinationAccount = IBANEntity.create(fromText: iban)
                    self.operativeData.newBeneficiaryName = beneficiaryName
                    self.container?.save(self.operativeData)
                    self.container?.stepFinished(presenter: self)
                })
            })
            .onError { [weak self] error in
                self?.view?.dismissLoading(completion: {
                    self?.handleError(error)
                    self?.view?.updateContinueAction(false)
                })
            }
    }
    
    func handleError(_ error: UseCaseError<PreValidateEditFavouriteUseCaseErrorOutput>) {
        switch error {
        case .error(let error):
            guard let errorInfo = error?.errorInfo else { return }
            self.errorInfo(errorInfo)
        case .generic, .intern, .networkUnavailable, .unauthorized:
            self.container?.showGenericError()
        }
    }
    
    func errorInfo(_ error: ErrorDescriptionType) {
        switch error {
        case .key(let key):
            self.view?.showError(localized(key), isIBANerror: key == "onePay_alert_valueIban")
        case .keyWithPlaceHolder:
            break
        }
    }
}

extension EditFavouriteHolderAndAccountPresenter: EditFavouriteHolderAndAccountPresenterProtocol {
    
    func viewDidLoad() {
        self.trackScreen()
        self.addComponents()
    }
    
    func didSelectContinue() {
       self.view?.showLoading()
       self.validate()
    }
    
    func validatableFieldChanged() {
        self.view?.updateContinueAction(isValidForm)
    }
}

extension EditFavouriteHolderAndAccountPresenter: AutomaticScreenTrackable {
    var trackerPage: EditFavouriteHolderAndAccountPage {
        return EditFavouriteHolderAndAccountPage()
    }
    var trackerManager: TrackerManager {
        return dependencies.resolve(for: TrackerManager.self)
    }
}

extension EditFavouriteHolderAndAccountPresenter {
    
    func addAlias() {
        let item = EditFavouriteItemViewModel(title: localized("pt_cross_hint_saveFavoriteName"), description: self.operativeData.selectedFavourite?.payeeDisplayName, accesibilityIdentificator: "alias"
        )
        self.view?.addViewItem(item)
    }
    
    func addCountryDestination() {
        guard  let name = self.operativeData.currentCountry?.name else { return }
        let item = EditFavouriteItemViewModel(
            title: localized("confirmation_item_destinationCountry"),
            description: name.capitalized, accesibilityIdentificator: "country"
        )
      self.view?.addViewItem(item)
    }
    
    func addCurrency() {
        guard  let currency =  self.operativeData.currentCurrency else { return }
        let name = "\(currency.name) (\(currency.getSymbol))"
        let item = EditFavouriteItemViewModel(
            title: localized("confirmation_item_currency"),
            description: name.capitalized, accesibilityIdentificator: "currency"
        )
        self.view?.addViewItem(item)
    }
    
    func addHolder() {
        guard let name = self.operativeData.selectedFavouriteType?.name else { return }
        let item = EditFavouriteItemViewModel(
            title: localized("sendMoney_label_recipients"),
            description: name.capitalized, accesibilityIdentificator: "holderName")
            self.view?.addViewFieldItem(item)
    }
    
    func addAccount() {
        guard let country = self.operativeData.selectedFavourite?.countryCode else { return }
        let bankingUtils: BankingUtilsProtocol = self.dependencies.resolve()
        bankingUtils.setCountryCode(country)
        let name = self.operativeData.selectedFavourite?.ibanRepresentable?.ibanString
        let item = EditFavouriteItemViewModel(
                  title: localized("account_text_iban"),
            description: name, accesibilityIdentificator: "holderIBAN")
        self.view?.addViewFieldIBANItem(bankingUtils, viewModel: item)
    }
}
