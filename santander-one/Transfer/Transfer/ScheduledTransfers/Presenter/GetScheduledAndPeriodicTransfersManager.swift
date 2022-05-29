//
//  GetScheduledAndPeriodicTransfersManager.swift
//  Transfer
//
//  Created by alvola on 12/07/2021.
//

import Foundation
import CoreFoundationLib

public typealias StandingOrdersUseCaseType = UseCase<PTScheduledTransfersInput,
                                                     PTScheduledTransfersOKOutput,
                                                     StringErrorOutput>

protocol GetScheduledAndPeriodicTransfersManagerDelegate: AnyObject {
    func set(scheduledtransfers: [ScheduledTransferViewModelProtocol], periodicTransfers: [PeriodicTransferViewModelProtocol])
    func setNoResult()
}

public protocol GetScheduledAndPeriodicTransfersUseCaseProtocol: StandingOrdersUseCaseType {}

final class GetScheduledAndPeriodicTransfersManager {
    private let dependenciesResolver: DependenciesResolver
    private weak var delegate: GetScheduledAndPeriodicTransfersManagerDelegate?
    
    private lazy var scheduledTransferSuperUseCase: LoadScheduledTransferSuperUseCase = {
        let superUseCase = self.dependenciesResolver.resolve(for: LoadScheduledTransferSuperUseCase.self)
        superUseCase.delegate = self
        return superUseCase
    }()
    
    private var viewModelBuilder: ScheduledTransferViewModelBuilder {
        return ScheduledTransferViewModelBuilder(dependenciesResolver: self.dependenciesResolver)
    }
    
    init(dependenciesResolver: DependenciesResolver, delegate: GetScheduledAndPeriodicTransfersManagerDelegate?) {
        self.dependenciesResolver = dependenciesResolver
        self.delegate = delegate
    }
    
    func execute() {
        guard let countryUseCase = dependenciesResolver.resolve(forOptionalType: GetScheduledAndPeriodicTransfersUseCaseProtocol.self)
        else { return scheduledTransferSuperUseCase.execute() }
        let input = PTScheduledTransfersInput(maxRecords: 20)
        Scenario(useCase: countryUseCase, input: input)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { [weak self] output in
                self?.buildStandingOrdersViewModels(list: output.standingOrderList)
            }
            .onError { [weak self] _ in
                self?.delegate?.setNoResult()
            }
    }
}

extension GetScheduledAndPeriodicTransfersManager: ScheduledTransferSuperUseCaseDelegate {
    func didFinishSuccessfully(with transferList: ScheduledTransferListEntity) {
        let scheduledTransfersViewModels = self.viewModelBuilder
            .scheduledTransferViewModels(for: transferList.scheduledTransfers)
        let periodicTransferViewModels = self.viewModelBuilder
            .periodicTransferViewModels(for: transferList.periodicTransfers)
        self.delegate?.set(scheduledtransfers: scheduledTransfersViewModels, periodicTransfers: periodicTransferViewModels)
    }
    
    func didFinishWithError(_ error: String?) {
        self.delegate?.setNoResult()
    }
}

extension GetScheduledAndPeriodicTransfersManager {
    func buildStandingOrdersViewModels(list: [StandingOrderEntity]) {
        let scheduled = list.filter({$0.orderType == .standalone})
        let periodic = list.filter({$0.orderType == .recurrent})
        
        let scheduledViewModel = scheduled.map {
            return StandingOrdersScheduledViewModel(entity: $0)
        }
        scheduledViewModel.first?.isTopSeparatorHidden = false
        let periodicViewModel = periodic.map {
            return StandingOrdersPeriodicViewModel(entity: $0)
        }
        periodicViewModel.first?.isTopSeparatorHidden = false
        self.delegate?.set(scheduledtransfers: scheduledViewModel, periodicTransfers: periodicViewModel)
    }
}
