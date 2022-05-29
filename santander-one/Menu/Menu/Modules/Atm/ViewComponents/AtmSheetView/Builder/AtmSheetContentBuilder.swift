//
//  AtmSheetContentBuilder.swift
//  Menu
//
//  Created by Juan Carlos López Robles on 10/29/20.
//
import UI
import Foundation

final class AtmSheetContentBuilder {
    private let scrollableContent: SheetScrollableContent
    private let viewModel: AtmViewModel!
    private weak var delegate: AtmMachineViewDelegate?
    
    init(viewModel: AtmViewModel) {
        self.viewModel = viewModel
        self.scrollableContent = SheetScrollableContent()
    }
    
    func addDelegate(_ delegate: AtmMachineViewDelegate) {
        self.delegate = delegate
    }
    
    func build() -> SheetScrollableContent {
        self.addAtmMachineView()
        self.addAtmCashTypeView()
        self.addAtmServices()
        return self.scrollableContent
    }
}

private extension AtmSheetContentBuilder {
    func addAtmMachineView() {
        let atmMachineView = AtmMachineView()
        atmMachineView.setDelegate(delegate)
        atmMachineView.setViewModel(viewModel)
        self.scrollableContent.addArrangedSubview(atmMachineView)
    }
    
    func addAtmCashTypeView() {
        guard self.viewModel.cashTypes.count > 0 else { return }
        let atmCashTypeView = AtmCashType()
        atmCashTypeView.setViewModels(viewModel.cashTypes)
        self.scrollableContent.addArrangedSubview(atmCashTypeView)
    }
    
    func addAtmServices() {
        guard self.viewModel.services.count > 0 else { return }
        let atmServicesView = AtmServicesView()
        atmServicesView.setViewModels(viewModel.services)
        self.scrollableContent.addArrangedSubview(atmServicesView)
    }
}
