//
//  LogoutByeViewModel.swift
//  RetailClean
//
//  Created by Luis Escámez Sánchez on 06/04/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import UIKit
import Foundation
import UI
import CoreFoundationLib

protocol LogoutByeViewModelProtocol {
    var image: UIImage? { get }
    var attributedTitle: NSAttributedString { get }
    var subtitleText: LocalizedStylableText { get }
    var activateText: LocalizedStylableText { get }
}

struct LogoutByeViewModel {
    
    private let thankYouLocalizedStringKey = "exit_title_thankYou"
    private let seeYouLocalizedStringKey = "exit_title_seeYou"
    private let imageName: String
    
    public init(imageName: String) {
        self.imageName = imageName
    }
}

// MARK: - Private Methods
private extension LogoutByeViewModel {
    
    private func getAttributedThanksString() -> NSAttributedString {
        let thanksFont: UIFont = UIFont.santander(family: .headline, type: .bold, size: 30)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: thanksFont,
            .foregroundColor: UIColor.lisboaGrayNew
        ]
        return NSAttributedString(string: localized(thankYouLocalizedStringKey) + " \n", attributes: attributes)
    }
    
    private func getAttributedSeeYouSoonString() -> NSAttributedString {
        let seeYouFont: UIFont = UIFont.santander(family: .headline, type: .bold, size: 38)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: seeYouFont,
            .foregroundColor: UIColor.santanderRed
        ]
        return NSAttributedString(string: localized(seeYouLocalizedStringKey), attributes: attributes)
    }
    
    private func generateAttributedTitle() -> NSAttributedString {
        let title = NSMutableAttributedString()
        title.append(getAttributedThanksString())
        title.append(getAttributedSeeYouSoonString())
        return title
    }
}

// MARK: - LogoutBye ViewModel Protocol
extension LogoutByeViewModel: LogoutByeViewModelProtocol {

    var image: UIImage? {
        Assets.image(named: self.imageName)
    }
    
    var attributedTitle: NSAttributedString {
        generateAttributedTitle()
    }
    
    var subtitleText: LocalizedStylableText { localized("exit_text_quiet") }
    
    var activateText: LocalizedStylableText { localized("exit_text_activate") }
}
