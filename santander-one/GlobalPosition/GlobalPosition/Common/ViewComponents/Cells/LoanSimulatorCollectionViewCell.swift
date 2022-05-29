//
//  LoanSimulatorCollectionViewCell.swift
//  GlobalPosition
//
//  Created by César González Palomino on 09/03/2020.
//

import Foundation
import UI
import CoreFoundationLib

protocol LoanSimulatorCollectionViewCellProtocol: AnyObject {
    func circularSliderDidStart()
    func circularSliderDidStop()
}

final class LoanSimulatorCollectionViewCell: UICollectionViewCell {

    weak var delegate: LoanSimulatorCollectionViewCellProtocol?
    private var simulatorViewConfigured = false
    
    func configureWith(viewModel: LoanSimulatorViewModel, resolver: DependenciesResolver) {
        guard simulatorViewConfigured == false else { return }
        let loanSimulatorView = LoanSimulatorViewBuilder.createSimulatorView(viewModel: viewModel,
                                                                             resolver: resolver,
                                                                             delegate: self)
        contentView.addSubview(loanSimulatorView)
        loanSimulatorView.fullFit()
        simulatorViewConfigured = true
    }
}

extension LoanSimulatorCollectionViewCell: LoanSimulatorViewDelegateProtocol {

    func sliderDidStart() {
        delegate?.circularSliderDidStart()
    }

    func sliderDidFinish() {
        delegate?.circularSliderDidStop()
    }
}
