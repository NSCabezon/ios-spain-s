//
//  LiquidationButtonView.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 11/4/19.
//

import UI
import CoreFoundationLib

protocol LiquidationButtonViewProtocol: AnyObject {
    func liquidationButtonTapped()
}

class LiquidationButtonView: BaseInformationButton {
    @IBOutlet weak var progreBar: ProgressBar!
    @IBOutlet weak var liquidationLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    weak var delegate: LiquidationButtonViewProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func updateLiquidationAmount(_ liquidationAmount: AmountEntity?) {
        guard let liquidationAmount = liquidationAmount else { return }
        self.amountLabel.text = liquidationAmount.getAbsFormattedAmountUI()
    }
    
    private func setupView() {
        self.backgroundColor = UIColor.clear
        self.progreBar.setProgressBackgroundColor(UIColor.silverDark)
        self.progreBar.setProgressPercentage(80)
        self.liquidationLabel.configureText(withLocalizedString:
            localized("card_text_settlement", [StringPlaceholder(.number, "3")]))
        self.startDateLabel.text = "20/08"
        self.endDateLabel.text = "20/09"
        addGesture()
    }
 
    private func addGesture() {
        self.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func buttonTapped(_ sender: UITapGestureRecognizer) {
        delegate?.liquidationButtonTapped()
    }
}
