//
//  SearchEmittersPresenter+Extension.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 5/18/20.
//

import Foundation
import CoreFoundationLib
import UI

extension SearchEmittersPresenter {
    func doSearchByCriterias(emitterCode: String) {
        guard emitterCode.isEmpty else {
            self.view?.setFrecuentEmitterHidden()
            self.doSearch(emitterCode: emitterCode)
            return
        }
        self.view?.showFrequentEmitter()
        self.getForFrequentEmitters()
    }
    
    func getForFrequentEmitters() {
        self.view?.showSearchingView()
        self.emitterRequest.addRequest()
        self.emitterRequest.addPagination(nil)
        self.emitterRequest.setAllowMoreRequest(false)
        
        guard operartiveData.selectedAccount != nil else {
            self.didFinishEmitters(emitters: [])
            return
        }
        
        UseCaseWrapper(
            with: self.frequentEmittersUseCase,
            useCaseHandler: self.useCaseHandler,
            onSuccess: { [weak self] response in
                self?.emitterList.clear()
                self?.didFinishEmitters(emitters: response.emitters)
                self?.emitterRequest.removeRequest()
            },
            onError: { [weak self] _ in
                self?.didFinishEmitters(emitters: [])
                self?.view?.setFrecuentEmitterHidden()
                self?.emitterRequest.removeRequest()
        })
    }
    
    func doSearch(emitterCode: String) {
        self.emitterRequest.addRequest()
        guard let account = operartiveData.selectedAccount else {
            self.didFinishEmitters(emitters: [])
            return
        }
        let input =  SearchEmitterUseCaseInput(
            account: account,
            emitterCode: emitterCode,
            pagination: emitterRequest.pagination)
        
        UseCaseWrapper(
            with: self.searchEmitterUseCase.setRequestValues(requestValues: input),
            useCaseHandler: self.useCaseHandler,
            onSuccess: { [weak self] response in
                let isEnd = response.pagination?.isEnd == true
                self?.emitterRequest.addPagination(response.pagination)
                self?.emitterRequest.setAllowMoreRequest(!isEnd)
                self?.didFinishEmitters(emitters: response.emitters)
                self?.emitterRequest.removeRequest()
            },
            onError: { [weak self] _ in
                self?.emitterRequest.addPagination(nil)
                self?.emitterRequest.setAllowMoreRequest(false)
                self?.didFinishEmitters(emitters: [])
                self?.emitterRequest.removeRequest()
        })
    }
    
    func fetchEmitterIncomes(_ emitter: EmitterEntity) {
           guard let account = operartiveData.selectedAccount else { return }
           let input =  GetEmitterIncomesUseCaseInput( emitter: emitter, account: account, pagination: nil)
           UseCaseWrapper(
               with: self.getEmitterIncomesUseCase.setRequestValues(requestValues: input),
               useCaseHandler: self.useCaseHandler,
               onSuccess: { [weak self] response in
                    self?.didFinishEmitterIncomes(emitter, incomes: response.incomes)
               },
               onError: { [weak self] error in
                guard let self = self else { return }
                self.didFinishEmitterIncomes(emitter, incomes: [])
                let acceptAction = DialogButtonComponents(titled: localized("generic_button_accept"), does: nil)
                self.view?.showOldDialog(
                    withDependenciesResolver: self.dependenciesResolver,
                    for: error,
                    acceptAction: acceptAction,
                    cancelAction: nil,
                    isCloseOptionAvailable: true
                )
        })
    }
    
    func fetchFields(forEmitter emitter: EmitterEntity, income: IncomeEntity) {
        guard let account = operartiveData.selectedAccount else { return }
        self.view?.showLoading()
        let input = GetBillEmittersPaymentFieldsUseCaseInput(account: account, emitterCode: emitter.code, productIdentifier: income.productIdentifier, collectionTypeCode: income.typeCode, collectionCode: income.code)
        UseCaseWrapper(
            with: self.getBillEmittersPaymentFieldsUseCase.setRequestValues(requestValues: input),
            useCaseHandler: self.useCaseHandler,
            onSuccess: { [weak self] output in
                guard let self = self else { return }
                self.operartiveData.selectedIncome = income
                self.operartiveData.selectedEmitter = emitter
                self.operartiveData.formats = output.formats
                self.container?.save(self.operartiveData)
                self.container?.save(output.formats.signature)
                self.view?.dismissLoading {
                    self.container?.stepFinished(presenter: self)
                }
            },
            onError: { [weak self] error in
                guard let self = self else { return }
                let acceptAction = DialogButtonComponents(titled: localized("generic_button_accept"), does: nil)
                self.view?.dismissLoading {
                    self.view?.showOldDialog(
                        withDependenciesResolver: self.dependenciesResolver,
                        for: error,
                        acceptAction: acceptAction,
                        cancelAction: nil,
                        isCloseOptionAvailable: true
                    )
                }
            }
        )
    }
}
