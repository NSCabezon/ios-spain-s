//
//  EmptyDialogViewController.swift
//  Ecommerce
//
//  Created by Alvaro Royo on 8/3/21.
//

import UIKit
import UI
import CoreFoundationLib

public final class EmptyDialogViewController: UIViewController {

    @IBOutlet private weak var dialogContainer: UIView!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var keyImage: UIImageView!
    @IBOutlet private weak var keyTitle: UILabel!
    @IBOutlet private weak var controllerContainer: UIView!
        
    private var emptyViewController: EmptyPurchasesViewController
    
    public init(emptyViewController: EmptyPurchasesViewController) {
        self.emptyViewController = emptyViewController
        super.init(nibName: "EmptyDialogViewController", bundle: Bundle.module)
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

private extension EmptyDialogViewController {
    
    func setupView() {
        self.dialogContainer.backgroundColor = .skyGray
        self.dialogContainer.layer.cornerRadius = 8
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.closeButton.setImage(Assets.image(named: "icnCloseGray"), for: .normal)
        self.keyImage.image = Assets.image(named: "icnBigSantanderLock")
        setKeyTitle()
        setEmptyView()
    }
    
    func setKeyTitle() {
        let config = LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 18), alignment: .left)
        self.keyTitle.configureText(withKey: "ecommerce_label_SantanderKeyOneLine", andConfiguration: config)
        self.keyTitle.textColor = .black
    }
    
    func setEmptyView() {
        self.addChild(emptyViewController)
        controllerContainer.addSubview(emptyViewController.view)
        emptyViewController.view.fullFit()
        emptyViewController.hideFooter()
    }
}
