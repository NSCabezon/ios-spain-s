//
//  BizumAcceptRequestMoneyConfirmationPresenter.swift
//  Bizum
//
//  Created by Cristobal Ramos Laina on 03/12/2020.
//

import Foundation
import CoreFoundationLib
import Operative
import SANLibraryV3

protocol BizumAcceptRequestMoneyConfirmationPresenterProtocol: BizumConfirmationWithCommentPresenterProtocol {
    var view: BizumAcceptRequestMoneyConfirmationViewProtocol? { get set }
    func viewDidLoad()
    func didTapClose()
    func getContact()
}

final class BizumAcceptRequestMoneyConfirmationPresenter {
    var view: BizumAcceptRequestMoneyConfirmationViewProtocol?
    // MARK: - OperativeStepPresenterProtocol
    var number: Int = 0
    var isBackButtonEnabled: Bool = true
    var isCancelButtonEnabled: Bool = true
    var container: OperativeContainerProtocol?
    // MARK: - Private Var
    private var dependenciesResolver: DependenciesResolver

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }

    func viewDidLoad() {
        self.trackScreen()
        self.loadData()
        self.view?.setContinueTitle(localized("generic_button_continue"))
    }
}

extension BizumAcceptRequestMoneyConfirmationPresenter: BizumAcceptRequestMoneyConfirmationPresenterProtocol {

    func didSelectContinue(comment: String?) {
        self.view?.showLoading()
        UseCaseWrapper(with: self.signPosUseCase,
                       useCaseHandler: self.dependenciesResolver.resolve(),
                       onSuccess: { [weak self] response in
                        guard let self = self else { return }
                        self.view?.dismissLoading(completion: {
                            self.operativeData?.multimediaData = BizumMultimediaData(image: nil, note: comment)
                            self.container?.save(self.operativeData)
                            self.container?.save(response.signatureWithTokenEntity)
                            self.container?.stepFinished(presenter: self)
                        })
                       }, onError: { [weak self] error in
                        guard let self = self else { return }
                        self.view?.dismissLoading(completion: {
                            self.view?.showDialog(
                                withDependenciesResolver: self.dependenciesResolver,
                                description: error.getErrorDesc()
                            )
                        })
                       })
    }
    
    func getContact() {
        guard let contact = self.operativeData?.bizumContacts?.first else { return }
        let amount = self.operativeData?.bizumSendMoney?.amount
        let viewModel = ConfirmationContactDetailViewModel(
            identifier: contact.identifier,
            name: contact.name,
            alias: contact.alias,
            initials: (contact.name ?? contact.alias ?? "").nameInitials,
            phone: contact.phone,
            amount: amount,
            validateSendAction: contact.validateSendAction?.capitalized,
            colorModel: self.getColorByName(contact.identifier))
        self.view?.setContact(viewModel)
    }
    
    func didTapClose() {
        self.container?.close()
    }
}

private extension BizumAcceptRequestMoneyConfirmationPresenter {
    var signPosUseCase: SignPosSendMoneyUseCase {
        return dependenciesResolver.resolve(for: SignPosSendMoneyUseCase.self)
    }
    var operativeData: BizumAcceptMoneyRequestOperativeData? {
         guard let container = self.container else { return nil }
         return container.get()
     }
    
    func loadData() {
        guard let data = self.operativeData else { return }
        let builder = BizumAcceptRequestMoneyConfirmationBuilder(data: data, dependenciesResolver: self.dependenciesResolver)
        builder.addAmountAndConcept()
        builder.addContacts()
        builder.addDate()
        builder.addOriginAccount()
        builder.addTransferType()
        builder.addTotal()
        self.view?.add(builder.build())
    }
    
    func getColorByName(_ identifier: String) -> ColorsByNameViewModel {
        let colorsEngine: ColorsByNameEngine = self.dependenciesResolver.resolve()
        let colorType = colorsEngine.get(identifier)
        return ColorsByNameViewModel(colorType)
    }
}

extension BizumAcceptRequestMoneyConfirmationPresenter: AutomaticScreenTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: BizumAcceptRequestMoneyConfirmationPage {
        return BizumAcceptRequestMoneyConfirmationPage()
    }

    func getTrackParameters() -> [String: String]? {
        return [
            TrackerDimension.simpleMultipleType.key: self.operativeData?.simpleMultipleType?.rawValue ?? ""
        ]
    }
}
