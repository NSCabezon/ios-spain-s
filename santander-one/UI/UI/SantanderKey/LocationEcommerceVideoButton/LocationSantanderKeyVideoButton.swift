//
//  LocationSantanderKeyVideoButton.swift
//  Commons
//
//  Created by Margaret López Calderón on 8/9/21.
//

import UIKit

public protocol LocationSantanderKeyVideoButtonDelegate: AnyObject {
    func didTapPlayVideo()
}

public final class LocationSantanderKeyVideoButton: XibView {

    @IBOutlet weak var contentView: UIView! {
        didSet {
            self.contentView.drawShadow(offset: (0, 2), opacity: 0.5, color: .gray, radius: 4)
            self.contentView.layer.cornerRadius = 6
        }
    }
    @IBOutlet weak var buttonVideoImg: UIImageView! {
        didSet {
            self.buttonVideoImg.image = Assets.image(named: "icnPlayGreen26")
        }
    }
    @IBOutlet weak var videoDescription: UILabel! {
        didSet {
            let config = LocalizedStylableTextConfiguration(
                font: .santander(family: .text, type: .light, size: 15),
                alignment: .left,
                lineHeightMultiple: 0.85
            )
            self.videoDescription.configureText(
                withKey: "securityDevice_button_video",
                andConfiguration: config)
            self.videoDescription.textColor = .lisboaGray
            self.videoDescription.numberOfLines = 0
        }
    }
    @IBOutlet weak var pressableButton: PressableButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(didTapPlayVideo))
            self.pressableButton.addGestureRecognizer(tap)
            self.pressableButton.backgroundColor = .clear
            self.pressableButton.setup(style: pressableButtonStyle)
        }
    }
    
    private var pressableButtonStyle: PressableButtonStyle {
        return PressableButtonStyle(
            pressedColor: .skyGray,
            cornerRadius: 6.0
        )
    }
    weak var delegate: LocationSantanderKeyVideoButtonDelegate?
}

private extension LocationSantanderKeyVideoButton {
    
    @objc
    func didTapPlayVideo() {
        self.delegate?.didTapPlayVideo()
    }
}
