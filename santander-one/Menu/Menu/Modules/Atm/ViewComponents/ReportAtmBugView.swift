//
//  ReportAtmBugView.swift
//  Menu
//
//  Created by Cristobal Ramos Laina on 01/09/2020.
//

import Foundation
import UI
import CoreFoundationLib

protocol ReportAtmBugViewDelegate: AnyObject {
    func didSelectedReportAtmBug(_ viewModel: OfferEntityViewModel?)
}

final class ReportAtmBugView: XibView {
    
    weak var delegate: ReportAtmBugViewDelegate?
    @IBOutlet weak var offerImageView: UIImageView!
    public var viewModel: OfferEntityViewModel?
    @IBOutlet weak var reportButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
        self.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
        self.isHidden = true
    }
    
    func setImageWithUrl(_ url: String?) {
        guard let urlUnwrapped = url else {return}
        offerImageView.loadImage(urlString: urlUnwrapped) { [weak self] in
            guard let image = self?.offerImageView.image else {return}
            guard let widthAnchor = self?.offerImageView.widthAnchor else {return}
            let ratioWidth = Double(image.size.width)
            let ratioHeight = Double(image.size.height)
            let ratio = ratioHeight / ratioWidth
            self?.offerImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: CGFloat(ratio)).isActive = true
            self?.isHidden = false
        }
    }
 
    @IBAction func didTapOnReportFault(_ sender: Any) {
        self.delegate?.didSelectedReportAtmBug(viewModel)
    }
}

private extension ReportAtmBugView {
    func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setAccessibilityIdentifiers()
    }
    
    func setAccessibilityIdentifiers() {
        self.reportButton.accessibilityIdentifier = AccessibilityAtm.atmBtnReportFault.rawValue
    }
}
