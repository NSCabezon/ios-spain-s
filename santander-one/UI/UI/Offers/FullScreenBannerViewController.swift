//
//  BigOfferViewController.swift
//  PersonalArea
//
//  Created by Cristobal Ramos Laina on 23/04/2020.
//

import Foundation
import CoreFoundationLib
import CoreDomain

protocol FullScreenBannerViewProtocol: AnyObject {
    func configureView(viewModel: FullScreenBannerViewModel)
}

final class FullScreenBannerViewController: UIViewController {
    @IBOutlet private weak var offerButton: UIButton!
    @IBOutlet private weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var closeImageView: UIImageView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var backgroundButton: UIButton!
    private let presenter: FullScreenBannerPresenterProtocol
    private var timer: Timer?
    private var action: OfferActionRepresentable?

    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: FullScreenBannerPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        self.containerView.isHidden = true
        self.setAcccessibilityIdentifiers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presenter.viewDidLoad()
    }
    
    func startTimer(withTime time: TimeInterval) {
            self.timer = Timer.scheduledTimer(timeInterval: time,
                                              target: self,
                                              selector: #selector(closeImageInTime),
                                              userInfo: nil,
                                              repeats: false)
        
    }
    
    func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    @IBAction func didTapOnOffer(_ sender: Any) {
        self.stopTimer()
        self.presenter.dismiss()
        guard let action = self.action else {return}
        self.presenter.execute(offerAction: action)
    }
    
    @IBAction func didTapOnCloseOffer(_ sender: Any) {
        self.stopTimer()
        self.presenter.didTapOnClose()
    }
    @IBAction func didTapOnBackground(_ sender: Any) {
        self.stopTimer()
        self.presenter.dismiss()
    }
    
    @objc func closeImageInTime() {
        self.presenter.dismiss()
    }
    
    func startAnimation() {
        guard self.view != nil else { return }
        var translation = self.containerView.frame.origin
        translation.y = -self.containerView.frame.height
        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 1.0,
            options: .curveEaseInOut,
            animations: { [weak self] in
                self?.containerView.frame.origin = translation
            }, completion: nil)
    }
}

extension FullScreenBannerViewController: FullScreenBannerViewProtocol {
    func configureView(viewModel: FullScreenBannerViewModel) {
        self.closeImageView.image = !viewModel.transparentClosure ? Assets.image(named: "icnXOffer") : nil
        self.imageView.loadImage(urlString: viewModel.banner.url) { [weak self] in
            guard let image = self?.imageView.image else {
                self?.closeImageInTime()
                return
            }
            let ratioWidth = image.size.width / UIScreen.main.scale
            let ratioHeight = image.size.height / UIScreen.main.scale
            self?.heightConstraint.constant = ratioHeight
            self?.widthConstraint.constant = ratioWidth
            let ratio = (ratioHeight / ratioWidth)
            guard let imageView = self?.imageView  else { return }
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: CGFloat(ratio)).isActive = true
            self?.view.backgroundColor = UIColor.black.withAlphaComponent(0.62)
            self?.containerView.isHidden = false
            self?.action = viewModel.action
            let time = TimeInterval(viewModel.time)
            self?.startTimer(withTime: time)
            self?.startAnimation()
        }
    }
}

private extension FullScreenBannerViewController {
    func setAcccessibilityIdentifiers() {
        self.closeButton.accessibilityIdentifier = "fullScreenBannerCloseButton"
        self.closeImageView.accessibilityIdentifier = "fullScreenBannerCloseImageView"
        self.imageView.accessibilityIdentifier = "fullScreenBannerImageView"
        self.backgroundButton.accessibilityIdentifier = "fullScreenBackgroundButton"
        self.containerView.accessibilityIdentifier = "fullScreenContainerView"
        self.offerButton.accessibilityIdentifier = "fullScreenOfferButton"
    }
}
