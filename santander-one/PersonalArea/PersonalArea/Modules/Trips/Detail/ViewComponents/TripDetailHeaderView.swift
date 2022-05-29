//
//  TripDetailHeaderView.swift
//  PersonalArea
//
//  Created by Luis Escámez Sánchez on 20/03/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol TripDetailHeaderViewModelProtocol {
    var currencyText: LocalizedStylableText { get }
    var tripDates: String { get }
    var countryText: String { get }
    var reasonText: String { get }
}

final class TripDetailHeaderView: UIView {
    
    @IBOutlet var headerContentView: UIView!
    private var view: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var datesLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var tripReasonLabel: UILabel!
    @IBOutlet weak var tripReasonLabelContainerView: UIView!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    
    private var viewModel: TripDetailHeaderViewModelProtocol? {
        didSet {
            configureWithViewModel()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        xibSetup()
        setAppearance()
        setFonts()
    }
    
    private func setAppearance() {
        self.tripReasonLabelContainerView.drawBorder(cornerRadius: 2, color: .darkTorquoise, width: 1)
        self.headerContentView.backgroundColor = UIColor.skyGray
        self.contentView.backgroundColor = UIColor.skyGray
        self.tripReasonLabelContainerView.backgroundColor = .darkTorquoise
        self.tripReasonLabel.backgroundColor = .clear
        self.tripReasonLabel.textColor = .white
        [countryLabel, datesLabel, currencyLabel].forEach { $0?.textColor = .lisboaGray}
        separatorView.backgroundColor = .mediumSkyGray
    }
    
    private func setFonts() {
        self.datesLabel.font = UIFont.santander(family: .text, type: .bold, size: 13.0)
        self.datesLabel.adjustsFontSizeToFitWidth = true
        self.tripReasonLabel.font =  UIFont.santander(family: .text, type: .bold, size: 10.0)
        self.currencyLabel.numberOfLines = 0
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
    
    private func xibSetup() {
        self.view = loadViewFromNib()
        self.view.frame = bounds
        self.addSubview(view)
    }
    
    private func configureWithViewModel() {
        guard let viewModel = self.viewModel else { return }
        self.countryLabel.configureText(withKey: viewModel.countryText,
                                        andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 28.0),
                                                                                             lineHeightMultiple: 0.75,
                                                                                             lineBreakMode: .byWordWrapping))
        self.datesLabel.text = viewModel.tripDates
        self.currencyLabel.configureText(withLocalizedString: viewModel.currencyText,
                                         andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 16.0),
                                                                                              lineHeightMultiple: 0.75,
                                                                                              lineBreakMode: .byWordWrapping))
        self.tripReasonLabel.text = viewModel.reasonText
    }
    
    // MARK: - Accesible Methods
    func setViewInfo(with viewModel: TripViewModel) {
        self.viewModel = viewModel
    }
}
