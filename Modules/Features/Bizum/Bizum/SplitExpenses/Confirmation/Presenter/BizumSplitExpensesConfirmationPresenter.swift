//
//  BizumSplitExpensesConfirmationPresenter.swift
//  Bizum
//
//  Created by Carlos Monfort Gómez on 13/01/2021.
//

import CoreFoundationLib
import Operative
import SANLibraryV3
import SANLegacyLibrary

final class BizumSplitExpensesConfirmationPresenter {
    weak var view: BizumConfirmationViewProtocol?
    var number: Int = 0
    var isBackButtonEnabled: Bool = true
    var isCancelButtonEnabled: Bool = true
    var container: OperativeContainerProtocol?
    private var dependenciesResolver: DependenciesResolver
    private lazy var operativeData: BizumSplitExpensesOperativeData? = {
        guard let container = self.container else { return nil }
        return container.get()
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    func viewDidLoad() {
        self.trackScreen()
        self.updateBizumContactEntity()
        self.loadData()
        self.view?.setContinueTitle(localized("bizum_button_askForMoney"))
    }
    
}

extension BizumSplitExpensesConfirmationPresenter: BizumConfirmationPresenterProtocol {
    func didSelectContinue() {
        self.view?.showLoading()
        self.requestMoneyContinue()
    }
    
    func getContacts() {
        guard let contacts = self.operativeData?.bizumContactEntity,
              let amount = self.operativeData?.bizumSendMoney?.amount
        else { return }
        let viewModels = contacts.map { ConfirmationContactDetailViewModel(identifier: $0.identifier,
                                                                           name: $0.name,
                                                                           alias: $0.alias,
                                                                           initials: $0.name?.nameInitials,
                                                                           phone: $0.phone,
                                                                           amount: contacts.count == 1 ? nil : amount,
                                                                           validateSendAction: $0.validateSendAction?.capitalized,
                                                                           colorModel: self.getColorByName($0.identifier), thumbnailData: $0.thumbnailData) }
        self.view?.setContacts(viewModels)
    }
    
    func didTapClose() {
        self.container?.close()
    }
    
    func modifyContacts() {
        self.container?.back(to: BizumSplitExpensesAmountPresenter.self)
    }
}
private extension BizumSplitExpensesConfirmationPresenter {
    func loadData() {
        guard let data = self.operativeData else { return }
        let builder = BizumSplitExpensesConfirmationBuilder(data: data, dependenciesResolver: self.dependenciesResolver)
        builder.addAmountAndConcept()
        builder.addMedia()
        builder.addContacts(action: modifyContacts)
        builder.addTotal()
        self.view?.add(builder.build())
    }
    
    func updateBizumContactEntity() {
        guard let data = self.operativeData,
              let contacts = data.bizumContactEntity,
              var firstContact = contacts.first else { return }
        if contacts.count == 1 {
            guard let simpleEntity = data.bizumValidateMoneyRequestEntity else { return }
            firstContact.addAliasIsBizum(alias: simpleEntity.beneficiaryAlias,
                                         validateSendAction: simpleEntity.transferInfo.errorCode == "0" ? localized("confirmation_label_request") : localized("confirmation_label_invite"))
            data.bizumContactEntity = [firstContact]
        } else {
            guard let multipleEntity = data.bizumValidateMoneyRequestMultiEntity else { return }
            let newContacts: [BizumContactEntity] = contacts.reduce(into: []) { result, contact in
                if let action = multipleEntity.actions.first(where: { $0.id == contact.phone }) {
                    result.append(
                        BizumContactEntity(
                            identifier: contact.identifier,
                            name: contact.name,
                            phone: contact.phone,
                            alias: action.beneficiaryAlias,
                            validateSendAction: action.action,
                            thumbnailData: contact.thumbnailData
                        )
                    )
                }
            }
            data.bizumContactEntity = newContacts
        }
    }
    
    func getColorByName(_ identifier: String) -> ColorsByNameViewModel {
        let colorsEngine: ColorsByNameEngine = self.dependenciesResolver.resolve()
        let colorType = colorsEngine.get(identifier)
        return ColorsByNameViewModel(colorType)
    }
    
    func requestMoneyContinue() {
        self.performSendMultimedia()
        switch operativeData?.simpleMultipleType {
        case .simple:
            self.performRequestMoneyUseCase()
        case .multiple:
            self.performRequestMoneyMultiUseCase()
        case nil:
            break
        }
    }
    
    func performRequestMoneyUseCase() {
        guard let input = self.generateBizumRequestMoneyUseCaseInput() else { return }
        let useCase = BizumRequestMoneyUseCase(dependenciesResolver: self.dependenciesResolver)
        Scenario(useCase: useCase, input: input)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { [weak self] _ in
                guard let self = self else { return }
                self.view?.dismissLoading(completion: {
                    self.container?.rebuildSteps()
                    self.container?.save(self.operativeData)
                    self.container?.stepFinished(presenter: self)
                })
            }.onError { [weak self] error in
                guard let self = self else { return }
                self.view?.dismissLoading(completion: {
                    self.view?.showDialog(
                        withDependenciesResolver: self.dependenciesResolver,
                        description: error.getErrorDesc()
                    )
                })
            }
    }
    
    func generateBizumRequestMoneyUseCaseInput() -> BizumRequestMoneyUseCaseInput? {
        guard
            let safeOperativeData = operativeData,
            let document = safeOperativeData.document,
            let validateMoneyRequestEntity = safeOperativeData.bizumValidateMoneyRequestEntity,
            let requestMoney = safeOperativeData.bizumSendMoney,
            let contact = safeOperativeData.bizumContactEntity?.first else {
            return nil
        }
        let input = BizumRequestMoneyUseCaseInput(checkPayment: safeOperativeData.bizumCheckPaymentEntity,
                                                  document: document,
                                                  operationId: validateMoneyRequestEntity.operationId,
                                                  dateTime: Date(),
                                                  concept: safeOperativeData.concept ?? "",
                                                  amount: requestMoney.amount.getFormattedServiceValue(),
                                                  receiverUserId: contact.phone)
        return input
    }
    
    func performRequestMoneyMultiUseCase() {
        guard let input = self.generateBizumRequestMoneyMultiUseCaseInput() else { return }
        let useCase = BizumRequestMoneyMultiUseCase(dependenciesResolver: self.dependenciesResolver)
        Scenario(useCase: useCase, input: input)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { [weak self] _ in
                guard let self = self else { return }
                self.view?.dismissLoading(completion: {
                    self.container?.rebuildSteps()
                    self.container?.save(self.operativeData)
                    self.container?.stepFinished(presenter: self)
                })
            }.onError { [weak self] error in
                guard let self = self else { return }
                self.view?.dismissLoading(completion: {
                    self.view?.showDialog(
                        withDependenciesResolver: self.dependenciesResolver,
                        description: error.getErrorDesc()
                    )
                })
            }
    }
    
    func generateBizumRequestMoneyMultiUseCaseInput() -> BizumRequestMoneyMultiUseCaseInput? {
        guard
            let safeOperativeData = operativeData,
            let document = safeOperativeData.document,
            let validateMoneyRequestMultiEntity = safeOperativeData.bizumValidateMoneyRequestMultiEntity,
            let requestMoney = safeOperativeData.bizumSendMoney else {
            return nil
        }
        let actions = validateMoneyRequestMultiEntity.actions.map {
            BizumMoneyRequestMultiActionInputParam(operationId: $0.operationId,
                                                   receiverUserId: $0.id,
                                                   action: $0.action)
        }
        let input = BizumRequestMoneyMultiUseCaseInput(checkPayment: safeOperativeData.bizumCheckPaymentEntity,
                                                       document: document,
                                                       dateTime: Date(),
                                                       concept: requestMoney.concept,
                                                       amount: requestMoney.amount.getFormattedServiceValue(),
                                                       operationId: validateMoneyRequestMultiEntity.operationId,
                                                       actions: actions)
        return input
    }
    
    // MARK: - Multimedia
    
    func performSendMultimedia() {
        guard
            let multimediaData = self.operativeData?.multimediaData,
            multimediaData.hasSomeValue(),
            let contacts = self.operativeData?.bizumContactEntity
        else {
            return
        }
        let phones: [String] = contacts.map({ $0.phone })
        guard !phones.isEmpty else { return }
        if phones.count > 1 {
            self.performSendMultimediaMulti(phones)
        } else {
            self.performSendMultimediaSimple(phones.first)
        }
    }
    
    func performSendMultimediaSimple(_ phone: String?) {
        guard let input = self.generateSendMultimediaSimpleInputUseCase(phone) else { return }
        let useCase = SendMultimediaSimpleUseCase(dependenciesResolver: self.dependenciesResolver)
        Scenario(useCase: useCase, input: input)
            .execute(on: self.dependenciesResolver.resolve())
    }
    
    func generateSendMultimediaSimpleInputUseCase(_ phone: String?) -> SendMultimediaSimpleInputUseCase? {
        guard
            let phone = phone,
            let operativeData = operativeData,
            let operationId = operativeData.bizumValidateMoneyRequestEntity?.operationId
        else { return nil }
        let input = SendMultimediaSimpleInputUseCase(checkPayment: operativeData.bizumCheckPaymentEntity,
                                                     operationId: operationId,
                                                     receiverUserId: phone,
                                                     image: operativeData.multimediaData?.image,
                                                     text: operativeData.multimediaData?.note,
                                                     operationType: .send)
        return input
    }
    
    func performSendMultimediaMulti(_ phones: [String]) {
        guard let input = self.generateSendMultimediaMultiInput(phones) else { return }
        let useCase = SendMultimediaMultiUseCase(dependenciesResolver: self.dependenciesResolver)
        Scenario(useCase: useCase, input: input)
            .execute(on: self.dependenciesResolver.resolve())
    }
    
    func generateSendMultimediaMultiInput(_ phones: [String]) -> SendMultimediaMultiInputUseCase? {
        guard
            let operativeData = operativeData,
            let emitterId = operativeData.bizumCheckPaymentEntity.phone,
            let bizumValidateMoneyRequestMultiEntity = operativeData.bizumValidateMoneyRequestMultiEntity else {
            return nil
        }
        let receivers = bizumValidateMoneyRequestMultiEntity.actions
            .filter { phones.contains($0.id) }
            .map {
                SendMultimediaMultiReceiverInput(
                    receiverUserId: $0.id,
                    operationId: $0.operationId
                )
            }
        let input = SendMultimediaMultiInputUseCase(
            emitterId: emitterId.trim(),
            multiOperationId: bizumValidateMoneyRequestMultiEntity.operationId,
            receivers: receivers,
            image: operativeData.multimediaData?.image,
            text: operativeData.multimediaData?.note, operationType: .requestMoney
        )
        return input
    }
}

extension BizumSplitExpensesConfirmationPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: BizumSplitExpensesConfirmationPage {
        return BizumSplitExpensesConfirmationPage()
    }
    
    func getTrackParameters() -> [String: String]? {
        return [
            TrackerDimension.simpleMultipleType.key: self.operativeData?.simpleMultipleType?.rawValue ?? ""
        ]
    }
}
