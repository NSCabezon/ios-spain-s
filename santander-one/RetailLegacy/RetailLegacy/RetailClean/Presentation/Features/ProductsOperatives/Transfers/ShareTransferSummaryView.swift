//
//  ShareTransferSummaryView.swift
//  RetailClean
//
//  Created by Laura González on 16/11/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import Foundation
import UIKit
import UI
import CoreFoundationLib

final class ShareTransferSummaryView: UIShareView, NotRotatable {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet private weak var santanderImage: UIImageView!
    @IBOutlet private weak var nameTitle: UILabel!
    @IBOutlet private weak var amountTitle: UILabel!
    @IBOutlet private weak var amountText: UILabel!
    @IBOutlet private weak var conceptTitle: UILabel!
    @IBOutlet private weak var conceptText: UILabel!
    @IBOutlet private weak var sentDateTitle: UILabel!
    @IBOutlet private weak var sentDateText: UILabel!
    @IBOutlet private weak var destinationAccountTitle: UILabel!
    @IBOutlet private weak var destinationAccountImage: UIImageView!
    @IBOutlet private weak var destinationAccountText: UILabel!
    @IBOutlet private weak var originAccountTitle: UILabel!
    @IBOutlet private weak var originAccountImage: UIImageView!
    @IBOutlet private weak var originAccountText: UILabel!
    @IBOutlet private weak var brokenTicketImage: UIImageView!
    
    init() {
        super.init(nibName: "ShareTransferSummaryView", bundleName: Bundle.module)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let forcedRotatable = self as? ForcedRotatable {
            forcedRotatable.forceOrientationForPresentation()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let forcedRotatable = self as? ForcedRotatable {
            forcedRotatable.forceOrientationForDismission()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setInfo(_ viewModel: ShareTransferSummaryViewModel) {
        nameTitle.set(localizedStylableText: viewModel.nameTitle)
        amountText.attributedText = viewModel.amountText
        conceptText.text = viewModel.conceptText
        sentDateText.text = viewModel.sentDateText
        destinationAccountText.text = viewModel.destinationAccountText
        originAccountText.text = viewModel.originAccountText
        originAccountImage.loadImage(urlString: viewModel.originAccountImage)
        destinationAccountImage.loadImage(urlString: viewModel.destinationAccountImage ?? "")
    }
    
    func shareImage(_ completion: @escaping () -> Void) {
        self.shareImage(self.containerView, onlyWhatsApp: false, completion: completion)
    }
}

private extension ShareTransferSummaryView {
    func setupView() {
        amountTitle.set(localizedStylableText: localized("summary_item_amount"))
        conceptTitle.set(localizedStylableText: localized("summary_item_concept"))
        sentDateTitle.set(localizedStylableText: localized("summary_item_sentDate"))
        destinationAccountTitle.set(localizedStylableText: localized("summary_item_destinationAccounts"))
        originAccountTitle.set(localizedStylableText: localized("summary_item_originAccount"))
        santanderImage.image = Assets.image(named: "icnSantander")
        brokenTicketImage.image = Assets.image(named: "icnBrokenPaper")
        amountTitle.setSantanderTextFont(type: .regular, size: 13.0, color: .grafite)
        conceptTitle.setSantanderTextFont(type: .regular, size: 13.0, color: .grafite)
        sentDateTitle.setSantanderTextFont(type: .regular, size: 13.0, color: .grafite)
        destinationAccountTitle.setSantanderTextFont(type: .regular, size: 13.0, color: .grafite)
        originAccountTitle.setSantanderTextFont(type: .regular, size: 13.0, color: .grafite)
        nameTitle.setSantanderTextFont(type: .regular, size: 16.0, color: .lisboaGrayNew)
        amountText.setSantanderTextFont(type: .bold, size: 32.0, color: .lisboaGrayNew)
        conceptText.setSantanderTextFont(type: .regular, size: 14.0, color: .lisboaGrayNew)
        sentDateText.setSantanderTextFont(type: .regular, size: 13.0, color: .lisboaGrayNew)
        destinationAccountText.setSantanderTextFont(type: .regular, size: 13.0, color: .lisboaGrayNew)
        originAccountText.setSantanderTextFont(type: .regular, size: 13.0, color: .lisboaGrayNew)
    }
}

extension ShareTransferSummaryView: ForcedRotatable {
    func forcedOrientationForPresentation() -> UIInterfaceOrientation {
        return .portrait
    }

    func forcedOrientationForDismission() -> UIInterfaceOrientation? {
        return .portrait
    }

    override var shouldAutorotate: Bool {
        return false
    }
}
