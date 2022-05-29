//
//  ShareActivityViewController.swift
//  Commons
//
//  Created by Juan Carlos López Robles on 12/11/19.
//

import UIKit

class ShareActivityViewController: UIActivityViewController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { .portrait }
    
    override init(activityItems: [Any], applicationActivities: [UIActivity]?) {
        super.init(activityItems: activityItems, applicationActivities: applicationActivities)
        if #available(iOS 13.0, *) {
            modalPresentationStyle = .formSheet
        } else {
            modalPresentationStyle = .overCurrentContext
        }
    }
}
