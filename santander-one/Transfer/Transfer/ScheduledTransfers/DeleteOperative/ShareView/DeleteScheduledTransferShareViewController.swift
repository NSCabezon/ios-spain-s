//
//  DeleteScheduledTransferShareViewController.swift
//  Account
//
//  Created by Alvaro Royo on 29/7/21.
//

import UIKit
import UI
import CoreFoundationLib

final class DeleteScheduledTransferShareViewController: UIShareView {

    private let configuration: [DeleteScheduledTransferShareConfiguration]
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var bottomImage: UIImageView!
    @IBOutlet private var borders: [UIView]!

    init(configuration: [DeleteScheduledTransferShareConfiguration]) {
        self.configuration = configuration
        super.init(nibName: "DeleteScheduledTransferShareViewController", bundleName: .module)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomImage.image = Assets.image(named: "imgTornBig")
        borders.forEach { $0.backgroundColor = .mediumSkyGray }
        configuration.forEach { stackView.addArrangedSubview($0.view) }
    }
    
}
