//
//  BillEmittersManualEmitterView.swift
//  Bills
//
//  Created by Cristobal Ramos Laina on 27/05/2020.
//

import Foundation
import UI
import CoreFoundationLib

class BillEmittersManualEmitterView: XibView {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var emitterLabel: UILabel!
    @IBOutlet weak var emitterCodLabel: UILabel!
    @IBOutlet weak var emitterImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setup(viewModel: EmitterSelectedViewModel) {
        self.containerView.drawBorder(cornerRadius: 6, color: UIColor.lightSkyBlue, width: 1)
        self.emitterLabel.font = .santander(family: .text, type: .bold, size: 18)
        self.emitterCodLabel.font = .santander(family: .text, type: .regular, size: 14)
        self.emitterLabel.textColor = UIColor.lisboaGray
        self.emitterCodLabel.textColor = UIColor.mediumSanGray
        self.emitterLabel.text = viewModel.name.camelCasedString
        self.emitterCodLabel.text = viewModel.code
        self.emitterImageView.loadImage(urlString: viewModel.urlImage)
        self.containerView.accessibilityIdentifier = "btn1"
    }
    
}
