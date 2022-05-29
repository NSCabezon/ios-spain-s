//
//  ForeignCurrency.swift
//  PersonalArea
//
//  Created by Juan Carlos López Robles on 3/20/20.
//

import Foundation
import UI
import CoreFoundationLib

protocol ForeignCurrencyDelegate: AnyObject {
    func didSelectScheduleDate(_ viewModel: ForeignCurrencyVieModel)
}

final class ForeignCurrency: XibView {
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var currencyImageView: UIImageView!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var scheduleDateButton: LisboaButton!
    private weak var delegate: ForeignCurrencyDelegate?
    private var viewModel: ForeignCurrencyVieModel?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    private func setAppearance() {
        self.viewContainer.drawBorder(cornerRadius: 4, color: .mediumSkyGray, width: 1)
        self.viewContainer?.drawShadow(offset: (2, 0), opacity: 30, color: .lightSanGray, radius: 4)
        self.currencyImageView.image = Assets.image(named: "icnRequestForeignCurrency")
        self.currencyLabel.configureText(withKey: "yourTrips_label_foreignExchange",
                                         andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.75))
        self.viewContainer.backgroundColor = .white
        self.setupScheduleDateButton()
    }
    
    private func setupScheduleDateButton() {
        self.scheduleDateButton.configureAsWhiteButton()
        self.scheduleDateButton.setTitle(localized("yourTrips_button_requestDate"), for: .normal)
        self.scheduleDateButton.titleLabel?.numberOfLines = 2
        self.scheduleDateButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.scheduleDateButton.contentEdgeInsets = UIEdgeInsets(top: 7, left: 10, bottom: 7, right: 10)
        self.viewContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOnScheduleDate)))
        self.scheduleDateButton.addSelectorAction(target: self, #selector(didTapOnScheduleDate))
    }
    
    func setDelegate(_ delegate: ForeignCurrencyDelegate) {
        self.delegate = delegate
    }
    
    func setViewModel(_ viewModel: ForeignCurrencyVieModel) {
        self.viewModel = viewModel
    }
    
    @objc func didTapOnScheduleDate(_ sender: Any) {
        guard let viewModel = viewModel else { return }
        self.delegate?.didSelectScheduleDate(viewModel)
    }
}
