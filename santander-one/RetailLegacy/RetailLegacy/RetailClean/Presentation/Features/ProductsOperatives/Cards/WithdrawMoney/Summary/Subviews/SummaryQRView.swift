//
//  SummaryQRView.swift
//  RetailClean
//
//  Created by David Gálvez Alonso on 25/02/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import UIKit

class SummaryQRView: DesignableView {
    @IBOutlet weak var qrImageView: UIImageView!
    
    public func setQRImage(codQR: String?) {
        guard let codQR = codQR, !codQR.isEmpty, let img = createQRFromString(str: codQR) else {
            self.isHidden = true
            return
        }
        qrImageView.image = UIImage(ciImage: img)
        qrImageView.layer.magnificationFilter = CALayerContentsFilter.nearest
    }
    
    private func createQRFromString(str: String) -> CIImage? {
        let stringData = str.data(using: .utf8)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(stringData, forKey: "inputMessage")
        return filter?.outputImage
    }
    
    func setAccessibilityIdentifiers(identifier: String) {
        self.qrImageView.accessibilityIdentifier = identifier
    }
}
