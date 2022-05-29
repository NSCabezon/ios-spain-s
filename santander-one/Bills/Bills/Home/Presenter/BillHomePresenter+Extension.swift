//
//  BillHomePresenter+Extension.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 4/15/20.
//

import Foundation
import CoreFoundationLib

extension BillHomePresenter {
    func loadAppConfiguration(_ completion: @escaping (_ isTimelineEnable: Bool, _ isFutureBillsEnable: Bool, _ isGlobalSearchEnabled: Bool, _ isBillEmitterPaymentEnable: Bool) -> Void) {
         MainThreadUseCaseWrapper(
            with: self.getAppConfigurationUseCase,
             onSuccess: { response in
                 completion(response.isTimeLineEnable,
                            response.isFutureBillsEnable,
                            response.isGlobalSearchEnabled,
                            response.isBillEmitterPaymentEnable)
         })
     }
     
     func loadGlobalPositionV2(_ completion: @escaping() -> Void) {
         UseCaseWrapper(
             with: self.globalPositionV2UseCase,
             useCaseHandler: useCaseHandler,
             onSuccess: {_ in
                 completion()
             }, onError: {_ in
                 completion()
             }
         )
     }
    
    func loadLastBillDetailEntity(_ viewModel: LastBillViewModel) {
        let lastBillDetail = LastBillDetail(bill: viewModel.bill, account: viewModel.account)
        let input = GetDetailBillUseCaseInput(lastBillDetail: lastBillDetail)
        UseCaseWrapper(
            with: self.getBillDetailUseCase.setRequestValues(requestValues: input),
            useCaseHandler: self.useCaseHandler,
            onSuccess: { [weak self] response in
                self?.view?.hideLoadingView({ [weak self] in
                    self?.coordinator.didSelectReturnReceipt(bill: viewModel.bill,
                    billDetail: response.billDetail)
                })
            },
            onError: { [weak self] error in
                self?.view?.hideLoadingView({
                    let error = error.getErrorDesc() ?? localized("generic_error_internetConnection")
                    self?.coordinator.showAlertDialog(body: error)
                })
            }
        )
    }
    
    func loadBillDocumentPDF(_ viewModel: LastBillViewModel) {
        let input = GetBillPdfDocumentUseCaseInput(
            account: viewModel.account,
            bill: viewModel.bill
        )
        UseCaseWrapper(
            with: self.getBillPdfDocumentUseCase.setRequestValues(requestValues: input),
            useCaseHandler: self.useCaseHandle,
            onSuccess: { [weak self] response in
                self?.view?.hideLoadingView({
                    self?.coordinator.didSelectSeePDF(response.document)
                })
            },
            onError: { [weak self] error in
                self?.view?.hideLoadingView({
                    let error = error.getErrorDesc() ?? localized("generic_error_internetConnection")
                    self?.coordinator.showAlertDialog(body: error)
                })
            }
        )
    }
}
