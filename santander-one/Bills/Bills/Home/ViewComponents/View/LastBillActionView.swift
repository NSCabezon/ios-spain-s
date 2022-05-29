//
//  LastBillActionView.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 4/14/20.
//

import Foundation
import UI
import CoreFoundationLib

final class LastBillActionView: XibView {
    @IBOutlet weak var billImageView: UIImageView!
    @IBOutlet weak var pdfImageView: UIImageView!
    @IBOutlet weak var billLabel: UILabel!
    @IBOutlet weak var pdfLabel: UILabel!
    private var viewModel: LastBillViewModel?
    private weak var delegate: LastBillDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    func setDelegate(_ delegate: LastBillDelegate?) {
        self.delegate = delegate
    }
    
    func setViewModel(_ viewModel: LastBillViewModel) {
        self.viewModel = viewModel
    }
    
    @IBAction func didSelectReturnReceipt(_ sender: Any) {
        guard let viewModel = self.viewModel else { return }
        self.delegate?.didSelectReturnReceipt(viewModel)
    }
    
    @IBAction func didSelectSeePDF(_ sender: Any) {
        guard let viewModel = self.viewModel else { return }
        self.delegate?.didSelectSeePDF(viewModel)
    }
    
    private func setAppearance() {
        self.view?.backgroundColor = UIColor.skyGray
        self.billImageView.image = Assets.image(named: "icnReturnReceipt1Green")
        self.pdfImageView.image = Assets.image(named: "group")
        self.billLabel.configureText(withKey: "receiptsAndTaxes_label_returnedReceipt")
        self.pdfLabel.configureText(withKey: "generic_button_viewPdf")
        self.view?.drawBorder(cornerRadius: 6, color: .lightSkyBlue, width: 1)
    }
}
