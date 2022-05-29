//
//  TransmitterSheetBuilder.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 4/7/20.
//

import Foundation
import UI

protocol TransmitterContentSheetBuilderDelegate: AnyObject {
    func didSelectLastBillViewModelFromSheetView(_ viewModel: LastBillViewModel)
}

final class TransmitterContentSheetBuilder {
    private let viewModel: TransmitterGroupViewModel
    private let sheetContent = SheetScrollableContent()
    private weak var delegate: TransmitterContentSheetBuilderDelegate?
    
    init(viewModel: TransmitterGroupViewModel) {
        self.viewModel = viewModel
    }
    
    func addDelegate(delegate: TransmitterContentSheetBuilderDelegate) {
        self.delegate = delegate
    }
    
    func build() -> SheetScrollableContent {
        self.addHeader()
        self.addElements()
        return sheetContent
    }
}

private extension TransmitterContentSheetBuilder {
    func addHeader() {
        let header = TransmitterHeaderView()
        header.setViewModel(viewModel)
        sheetContent.addArrangedSubview(header)
    }
    
    func addElements() {
        for index in 0..<viewModel.bills.count {
            let element = TransmitterElementView()
            element.setViewModel(viewModel.bills[index])
            element.setDelegate(delegate)
            element.accessibilityIdentifier = "btn\(index)"
            sheetContent.addArrangedSubview(element)
        }
    }
}
