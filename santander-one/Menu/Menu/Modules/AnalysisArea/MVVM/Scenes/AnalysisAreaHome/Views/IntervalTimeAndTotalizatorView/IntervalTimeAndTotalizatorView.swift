//
//  IntervalTimeAndTotalizatorView.swift
//  Menu
//
//  Created by Adrian Arcalá Ocón on 14/1/22.
//

import Foundation
import UI
import UIKit
import UIOneComponents
import OpenCombine
import CoreFoundationLib
import CoreDomain

enum IntervalTiemAndTotalizatorState: State {
    case idle
    case didTapChangeButton
    case didTapEditTotalizator
}

final class IntervalTimeAndTotalizatorView: XibView {
    
    @IBOutlet private weak var contentView: OneGradientView!
    @IBOutlet private weak var intervalTimeLabel: UILabel!
    @IBOutlet private weak var changeIntervalTimeViewButton: UIButton!
    @IBOutlet private weak var totalizatorView: UIView!
    @IBOutlet private weak var totalizatorLabel: UILabel!
    @IBOutlet private weak var totalizatorBanksImages: UIStackView!
    @IBOutlet private weak var totalizatorMoreBanksImage: UIImageView!
    @IBOutlet private weak var totalizatorArrowImage: UIImageView!
    private var accessibilityLabelBanksImages: String?
    private var eventSubject = PassthroughSubject<IntervalTiemAndTotalizatorState, Never>()
    public var publisher: AnyPublisher<IntervalTiemAndTotalizatorState, Never> {
        return eventSubject.eraseToAnyPublisher()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupUI()
    }
    
    func setIntervalTimeData(_ data: UserDataAnalysisAreaRepresentable) {
        setIntervalTimeLabel(intervalData: data)
    }
    
    func setTotalizatorData(_ data: TotalizatorRepresentable) {
        setTotalizatorLabel(data.productsInfo.0, data.productsInfo.1)
        setBanksImages(banksImages: data.banksImages)
        setAccessibility(setViewAccessibility: setAccessibilityInfo)
    }
}

private extension IntervalTimeAndTotalizatorView {
    
    func setupUI() {
        contentView.setupType(.oneGrayGradient(direction: .bottomToTop))
        configureTotalizator()
        configureTimeIntervalView()
        setAccessibilityIdentifiers()
        setAccessibility(setViewAccessibility: setAccessibilityInfo)
    }
    
    func configureTimeIntervalView() {
        intervalTimeLabel.textFont = .typography(fontName: .oneH200Bold)
        changeIntervalTimeViewButton.setTitle(localized("generic_button_change").text, for: .normal)
        changeIntervalTimeViewButton.titleLabel?.font = .typography(fontName: .oneB300Bold)
        changeIntervalTimeViewButton.setTitleColor(.oneDarkTurquoise, for: .normal)
    }
    
    func configureTotalizator() {
        configureTotalizatorView()
        setTotalizatorLabel(0, 0)
        totalizatorLabel.textFont = .typography(fontName: .oneB400Bold)
        totalizatorArrowImage.image = Assets.image(named: "oneIcnArrowRoundedRight")?.withRenderingMode(.alwaysTemplate)
        totalizatorArrowImage.tintColor = .lisboaGray
        totalizatorMoreBanksImage.image = Assets.image(named: "oneIcnOthers")
    }
    
    func configureTotalizatorView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.didTapEditTotalizatorView(sender: )))
        totalizatorView.addGestureRecognizer(tap)
    }
    
    func setTotalizatorLabel(_ accounts: Int, _ cards: Int) {
        let accountsLabel = accounts == 1 ? localized("analysis_label_accounts_one",
                                                           [StringPlaceholder(.number, "1")]).text
                                                : localized("analysis_label_accounts_other",
                                                            [StringPlaceholder(.number, "\(accounts)")]).text
        let cardsLabel = cards == 1 ? localized("analysis_label_cards_one",
                                                     [StringPlaceholder(.number, "1")]).text
                                            : localized("analysis_label_cards_other",
                                                    [StringPlaceholder(.number, "\(cards)")]).text
        
        totalizatorLabel.text = "\(accountsLabel), \(cardsLabel)"
    }
    
    func setBanksImages(banksImages: [BankImageRepresentable]) {
        var accessibilityLabelImages = ""
        totalizatorBanksImages.removeAllArrangedSubviews()
        let twoImages = banksImages.prefix(2)
        for image in twoImages {
            let imageView = UIImageView()
            imageView.setImage(url: image.urlImage, placeholder: Assets.image(named: "oneIcnBankGenericLogo")) { bankLogo in
                guard let bankImage = bankLogo else { return }
                let ratio = bankImage.size.width / bankImage.size.height
                imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: ratio).isActive = true
                accessibilityLabelImages = "\(accessibilityLabelImages)\(localized("\(image.accessibilityLabelKey)"))"
                self.accessibilityLabelBanksImages = accessibilityLabelImages.replace("", ", ")
            }
            imageView.contentMode = .scaleAspectFit
            totalizatorBanksImages.addArrangedSubview(imageView)
        }
        totalizatorMoreBanksImage.isHidden = !(banksImages.count > 2)
    }
    
    func setIntervalTimeLabel(intervalData: UserDataAnalysisAreaRepresentable) {
        intervalTimeLabel.text = intervalData.timeSelector?.timeViewSelected.homeText
    }
    
    func setAccessibilityIdentifiers() {
        intervalTimeLabel.accessibilityIdentifier = AnalysisAreaAccessibility.analysisLabelMensualFilter
        changeIntervalTimeViewButton.accessibilityIdentifier = AnalysisAreaAccessibility.btnGenericChange
        changeIntervalTimeViewButton.titleLabel?.accessibilityIdentifier = AnalysisAreaAccessibility.genericChangeLabel
        totalizatorLabel.accessibilityIdentifier = AnalysisAreaAccessibility.analysisLabelCards
        totalizatorBanksImages.accessibilityIdentifier = AnalysisAreaAccessibility.imgFirstBank
        totalizatorMoreBanksImage.accessibilityIdentifier = AnalysisAreaAccessibility.oneIcnOthers
        totalizatorArrowImage.accessibilityIdentifier = AnalysisAreaAccessibility.oneIcnArrowRoundedRight
    }
    
    func setAccessibilityInfo() {
        changeIntervalTimeViewButton.accessibilityLabel = localized("voiceover_changeView")
        let moreBanksLabel = !totalizatorMoreBanksImage.isHidden ? localized("voiceover_moreBanks") : ""
        totalizatorView.isAccessibilityElement = true
        totalizatorView.accessibilityLabel = "\(totalizatorLabel.text ?? "") \(self.accessibilityLabelBanksImages ?? ""), \(moreBanksLabel)"
        totalizatorView.accessibilityTraits = .button
        totalizatorView.accessibilityHint = localized("voiceover_modifySelection")
        self.accessibilityElements = [intervalTimeLabel, changeIntervalTimeViewButton, totalizatorView].compactMap {$0}
    }
    
    @IBAction func didTapChangeTimeIntervalBtn(_ sender: Any) {
        eventSubject.send(.didTapChangeButton)
    }
    
    @objc func didTapEditTotalizatorView(sender: UITapGestureRecognizer) {
        eventSubject.send(.didTapEditTotalizator)
    }
}

extension IntervalTimeAndTotalizatorView: AccessibilityCapable {}

struct TotalizatorModel: TotalizatorRepresentable {
    var productsInfo: (Int, Int)
    var banksImages: [BankImageRepresentable]
}

struct BankImageModel: BankImageRepresentable {
    var urlImage: String
    var accessibilityLabelKey: String
}
