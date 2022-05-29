//
//  SKCustomerDetailsHeaderView.swift
//  SantanderKey
//
//  Created by Angel Abad Perez on 11/4/22.
//

import UIKit
import UI
import UIOneComponents
import CoreFoundationLib
import OpenCombine
import ESUI

enum SKCustomerDetailsHeaderState: State {
    case didTapMoreInfo
}

final class SKCustomerDetailsHeaderView: XibView {
    @IBOutlet private weak var leftIconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var moreInfoLink: OneAppLink!
    
    private let stateSubject = PassthroughSubject<SKCustomerDetailsHeaderState, Never>()
    lazy var state: AnyPublisher<SKCustomerDetailsHeaderState, Never> = {
        return stateSubject.eraseToAnyPublisher()
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    @IBAction func didTapMoreInfo(_ sender: Any) {
        stateSubject.send(.didTapMoreInfo)
    }
}

private extension SKCustomerDetailsHeaderView {
    enum Constants {
        enum View {
            static let accessibilityId: String = "santanderKeyHeaderSanKey"
        }
        enum LeftIcon {
            static let imageName: String = "IcnSanKeyLock"
            static let accessibilityId: String = "oneIcnSanKeyRed"
            static let tintColor: UIColor = .bostonRed
        }
        enum Title {
            static let key: String = "santanderKey_label_santanderKey"
        }
        enum Subtitle {
            static let key: String = "santanderKey_label_authenticationSystem"
        }
        enum MoreInfoButton {
            static let key: String = "ganeric_label_knowMore"
        }
    }
    
    func setupView() {
        setupLeftIcon()
        setupLabels()
        setupMoreInfoButton()
        setAccessibilityIds()
    }
    
    func setupLeftIcon() {
        leftIconImageView.image = ESAssets.image(named: Constants.LeftIcon.imageName)?.withRenderingMode(.alwaysTemplate)
        leftIconImageView.tintColor = .bostonRed
    }
    
    func setupLabels() {
        titleLabel.applyStyle(LabelStylist(textColor: .oneLisboaGray,
                                           font: .typography(fontName: .oneH100Regular),
                                           textAlignment: .left))
        titleLabel.configureText(withKey: Constants.Title.key)
        subtitleLabel.font = .typography(fontName: .oneB300Regular)
        subtitleLabel.textColor = .lisboaGray
        subtitleLabel.configureText(withKey: Constants.Subtitle.key)
    }
    
    func setupMoreInfoButton() {
        moreInfoLink.configureButton(type: .secondary,
                                     style: OneAppLink.ButtonContent(text: localized(Constants.MoreInfoButton.key),
                                                                     icons: .none,
                                                                     textAlignment: .left))
    }
    
    func setAccessibilityIds() {
        accessibilityIdentifier = Constants.View.accessibilityId
        titleLabel.accessibilityIdentifier = Constants.Title.key
        subtitleLabel.accessibilityIdentifier = Constants.Subtitle.key
        moreInfoLink.accessibilityIdentifier = Constants.MoreInfoButton.key
        leftIconImageView.accessibilityIdentifier = Constants.LeftIcon.accessibilityId
    }
}
