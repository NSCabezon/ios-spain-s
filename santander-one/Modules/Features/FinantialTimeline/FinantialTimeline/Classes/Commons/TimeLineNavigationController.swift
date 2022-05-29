//
//  TimeLineNavigationController.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 31/07/2019.
//

import UIKit

class TimeLineNavigationController: UINavigationController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        navigationBar.shadowImage = UIImage()
        navigationBar.tintColor = .sanRed
        navigationBar.backgroundColor = .white
        navigationBar.isTranslucent = false
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.sanRed,
                                             NSAttributedString.Key.font: UIFont.santanderText(type: .bold, with: 18)]
    }
}
