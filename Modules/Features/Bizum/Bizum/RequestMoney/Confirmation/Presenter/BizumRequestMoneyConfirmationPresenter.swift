//
//  BizumRequestMoneyConfirmationPresenter.swift
//  Pods
//
//  Created by Jose Ignacio de Juan Díaz on 02/12/2020.
//

import CoreFoundationLib
import Operative
import SANLibraryV3
import SANLegacyLibrary

final class BizumRequestMoneyConfirmationPresenter {
    var view: BizumConfirmationViewProtocol?
    // MARK: - OperativeStepPresenterProtocol
    var number: Int = 0
    var isBackButtonEnabled: Bool = true
    var isCancelButtonEnabled: Bool = true
    var container: OperativeContainerProtocol?
    // MARK: - Private Var
    private var dependenciesResolver: DependenciesResolver
    private lazy var operativeData: BizumRequestMoneyOperativeData? = {
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
        self.view?.setContinueTitle(localized("generic_button_send"))
    }
    
}

extension BizumRequestMoneyConfirmationPresenter: BizumConfirmationPresenterProtocol {
    
    func modifyAmount() {
        self.container?.back(to: BizumAmountPresenter.self)
    }
    func modifyContacts() {
        self.container?.back(to: BizumContactPresenter.self)
    }
    
    func didSelectContinue() {
        self.view?.showLoading()
        self.requestMoneyContinue()
    }
    
    func getContacts() {
        guard let contacts = self.operativeData?.bizumContactEntity,
              let amount = self.operativeData?.bizumSendMoney?.amount
        else { return }
        let viewModels = contacts.map {
            ConfirmationContactDetailViewModel(
                identifier: $0.identifier,
                name: $0.name,
                alias: $0.alias,
                initials: ($0.name ?? $0.alias ?? "").nameInitials,
                phone: $0.phone,
                amount: contacts.count == 1 ? nil : amount,
                validateSendAction: $0.validateSendAction?.capitalized,
                colorModel: self.getColorByName($0.identifier),
                thumbnailData: $0.thumbnailData
            )
        }
        self.view?.setContacts(viewModels)
    }

    func didTapClose() {
        self.container?.close()
    }
    
}
private extension BizumRequestMoneyConfirmationPresenter {
    func loadData() {
        guard let data = self.operativeData else { return }
        let builder = BizumRequestMoneyConfirmationBuilder(data: data, dependenciesResolver: self.dependenciesResolver)
        builder.addAmountAndConcept(action: modifyAmount)
        builder.addMedia()
        builder.addContacts(action: modifyContacts)
        builder.addTotal()
        self.view?.add(builder.build())
    }
    
    func updateBizumContactEntity() {
        guard let data = self.operativeData,
              let contacts = data.bizumContactEntity,
              var firstContact = contacts.first
        else { return }
        if contacts.count == 1 {
            guard let simpleEntity = data.bizumValidateMoneyRequestEntity else { return }
            firstContact.addAliasIsBizum(
                alias: simpleEntity.beneficiaryAlias,
                validateSendAction: simpleEntity.transferInfo.errorCode == "0" ?
                    localized("confirmation_label_request") :
                    localized("confirmation_label_invite")
            )
            data.bizumContactEntity = [firstContact]
        } else {
            guard let multipleEntity = data.bizumValidateMoneyRequestMultiEntity else { return }
            let newContacts: [BizumContactEntity] = contacts.reduce([]) { result, contact in
                var new = result
                multipleEntity.actions.contains { action in
                    if action.id == contact.phone {
                        new.append(
                            BizumContactEntity(
                                identifier: contact.identifier,
                                name: contact.name,
                                phone: contact.phone,
                                alias: action.beneficiaryAlias,
                                validateSendAction: action.action,
                                thumbnailData: contact.thumbnailData
                            )
                        )
                        return true
                    } else {
                        return false
                    }
                }
                return new
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
            performRequestMoneyUseCase()
        case .multiple:
            performRequestMoneyMultiUseCase()
        case nil:
            break
        }
    }
    
    func performRequestMoneyUseCase() {
        guard let safeOperativeData = operativeData,
              let document = safeOperativeData.document,
              let validateMoneyRequestEntity = safeOperativeData.bizumValidateMoneyRequestEntity,
              let requestMoney = safeOperativeData.bizumSendMoney,
              let contact = safeOperativeData.bizumContactEntity?.first
        else { return }
        let input = BizumRequestMoneyUseCaseInput(
            checkPayment: safeOperativeData.bizumCheckPaymentEntity,
            document: document,
            operationId: validateMoneyRequestEntity.operationId,
            dateTime: Date(),
            concept: requestMoney.concept,
            amount: requestMoney.amount.getFormattedServiceValue(),
            receiverUserId: contact.phone
        )
        let requestMoneyUseCase = dependenciesResolver.resolve(for: BizumRequestMoneyUseCase.self).setRequestValues(requestValues: input)
        UseCaseWrapper(
            with: requestMoneyUseCase,
            useCaseHandler: self.dependenciesResolver.resolve(),
            onSuccess: { [weak self] _ in
                guard let self = self else { return }
                self.view?.dismissLoading(completion: {
                    self.container?.rebuildSteps()
                    self.container?.save(self.operativeData)
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
    
    func performRequestMoneyMultiUseCase() {
        guard let safeOperativeData = operativeData,
              let document = safeOperativeData.document,
              let validateMoneyRequestMultiEntity = safeOperativeData.bizumValidateMoneyRequestMultiEntity,
              let requestMoney = safeOperativeData.bizumSendMoney
        else { return }
        let actions = validateMoneyRequestMultiEntity.actions.map {
            BizumMoneyRequestMultiActionInputParam(
                operationId: $0.operationId,
                receiverUserId: $0.id,
                action: $0.action
            )
        }
        let input = BizumRequestMoneyMultiUseCaseInput(
            checkPayment: safeOperativeData.bizumCheckPaymentEntity,
            document: document,
            dateTime: Date(),
            concept: requestMoney.concept,
            amount: requestMoney.amount.getFormattedServiceValue(),
            operationId: validateMoneyRequestMultiEntity.operationId,
            actions: actions
        )
        let requestMoneyMultiUseCase = dependenciesResolver.resolve(for: BizumRequestMoneyMultiUseCase.self).setRequestValues(requestValues: input)
        UseCaseWrapper(
            with: requestMoneyMultiUseCase,
            useCaseHandler: self.dependenciesResolver.resolve(),
            onSuccess: { [weak self] _ in
                guard let self = self else { return }
                self.view?.dismissLoading(completion: {
                    self.container?.rebuildSteps()
                    self.container?.save(self.operativeData)
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
            self.performSendMultimedia(phones)
        } else {
            self.performSendMultimedia(phones.first)
        }
    }
    
    func performSendMultimedia(_ phone: String?) {
        guard let phone = phone,
              let operativeData = operativeData,
              let operationId = operativeData.bizumValidateMoneyRequestEntity?.operationId
        else { return }
        let input = SendMultimediaSimpleInputUseCase(
            checkPayment: operativeData.bizumCheckPaymentEntity,
            operationId: operationId,
            receiverUserId: phone,
            image: operativeData.multimediaData?.image,
            text: operativeData.multimediaData?.note,
            operationType: .requestMoney
        )
        let useCase = self.dependenciesResolver.resolve(for: SendMultimediaSimpleUseCase.self).setRequestValues(requestValues: input)
        UseCaseWrapper(with: useCase, useCaseHandler: self.dependenciesResolver.resolve())
    }
    
    func performSendMultimedia(_ phones: [String]) {
        guard let operativeData = operativeData,
              let emitterId = operativeData.bizumCheckPaymentEntity.phone,
              let bizumValidateMoneyRequestMultiEntity = operativeData.bizumValidateMoneyRequestMultiEntity else {
            return
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
            text: operativeData.multimediaData?.note,
            operationType: .requestMoney
        )
        let useCase = self.dependenciesResolver.resolve(for: SendMultimediaMultiUseCase.self).setRequestValues(requestValues: input)
        UseCaseWrapper(with: useCase, useCaseHandler: self.dependenciesResolver.resolve())
    }
}

extension BizumRequestMoneyConfirmationPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: BizumRequestMoneyConfirmationPage {
        return BizumRequestMoneyConfirmationPage()
    }
    
    func getTrackParameters() -> [String: String]? {
        return [
            TrackerDimension.simpleMultipleType.key: self.operativeData?.simpleMultipleType?.rawValue ?? ""
        ]
    }
}
