//
//  SecureDeviceTutorialViewController.swift
//  PersonalArea
//
//  Created by alvola on 26/12/2019.
//

import UIKit
import UI
import CoreFoundationLib

protocol SecureDeviceTutorialViewProtocol: UIViewController {
    func showVideo()
}

class SecureDeviceTutorialViewController: UIViewController {
    @IBOutlet private weak var videoImageView: UIImageView!
    @IBOutlet private weak var playImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var gradientView: UIView!
    @IBOutlet private weak var separationView: UIView!
    @IBOutlet private weak var configureButton: WhiteLisboaButton!
    @IBOutlet private weak var contentVideoView: UIView!
    
    private var presenter: SecureDeviceTutorialPresenterProtocol

    init(presenter: SecureDeviceTutorialPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "SecureDeviceTutorialViewController", bundle: Bundle.module)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
        self.presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureGradient()
    }
}

// MARK: - privateMethods

private  extension SecureDeviceTutorialViewController {
    func commonInit() {
        configureView()
        configureImages()
        configureLabels()
        configureButtons()
    }
    
    func configureNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .white,
            title: .title(key: "toolbar_title_secureDevice")
        )
        builder.setLeftAction(.back(action: #selector(backDidPressed)))
        builder.setRightActions(.close(action: #selector(closeDidPressed)))
        builder.build(on: self, with: nil)
    }
    
    func configureView() {
        separationView.backgroundColor = UIColor.mediumSkyGray
        gradientView.backgroundColor = UIColor.clear
    }
    
    func configureGradient() {
        guard let gradientView = gradientView else { return }
        gradientView.layer.sublayers?.forEach({ $0.removeFromSuperlayer() })
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.frame = gradientView.bounds
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.skyGray.cgColor, UIColor.skyGray.cgColor]
        gradientView.layer.addSublayer(gradientLayer)
    }
    
    func configureImages() {
        videoImageView.image = Assets.image(named: "imgSecureDevice")
        videoImageView.contentMode = .scaleAspectFit
        playImageView.image = Assets.image(named: "icnPlay")
        playImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(playDidPressed)))
        playImageView.isUserInteractionEnabled = true
    }
    
    func configureLabels() {
        titleLabel.font = UIFont.santander(family: .text, type: .bold, size: 20.0)
        titleLabel.textColor = UIColor.lisboaGray
        titleLabel.text = localized("secureDevice_title_registrer")
        
        descriptionLabel.font = UIFont.santander(family: .text, type: .light, size: 16.0)
        descriptionLabel.textColor = UIColor.lisboaGray
        descriptionLabel.text = localized("secureDevice_label_registrer")
    }
    
    func configureButtons() {
        configureButton?.setTitle(localized("secureDevice_button_configure"), for: .normal)
        configureButton?.addSelectorAction(target: self, #selector(configureDidPressed))
    }
    
    @objc func configureDidPressed() {
        self.presenter.goToUpdate()
    }
    
    @objc func backDidPressed() {
        self.presenter.backDidPressed()
    }
    
    @objc func closeDidPressed() {
        self.presenter.closeDidPressed()
    }
    
    @objc func playDidPressed() {
        self.presenter.videoDidPressed()
    }
}

// MARK: - SecureDeviceTutorialViewProtocol

extension SecureDeviceTutorialViewController: SecureDeviceTutorialViewProtocol {
    func showVideo() {
        self.contentVideoView.isHidden = false
    }
}
