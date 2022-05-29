//
//  FeePaymentView.swift
//  Menu
//
//  Created by Juan Carlos López Robles on 7/3/20.
//

import CoreFoundationLib

public final class FeePaymentView: XibView {
    @IBOutlet private weak var headerView: FeePaymentHeaderPillView!
    @IBOutlet private weak var detailView: FeePaymentDetailPillView!

    private var viewModel: FeeViewModel?
    private var viewIndexInContainer: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawBorder(cornerRadius: 4, color: .mediumSkyGray, width: 1)
    }
    
    public func setViewModel(_ viewModel: FeeViewModel, index: Int) {
        self.viewModel = viewModel
        self.viewIndexInContainer = index
        headerView.configView(viewModel)
        detailView.configView(viewModel, viewIndexInContainer: index)
    }
    
    @IBAction func didSelectFee(_ sender: Any) {
        viewModel?.doAction()
    }
}

private extension FeePaymentView {
    func setupView() {
        backgroundColor = .clear
        drawShadow(offset: (x: 1, y: 2), opacity: 0.8, color: .mediumSkyGray, radius: 2)
        setAccessibilityIds()
    }
    
    func setAccessibilityIds() {
        accessibilityIdentifier = AccessibilitySeeFractionableOptions.feePaymentsBaseView
    }
}
