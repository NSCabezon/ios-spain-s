//

import Foundation
import UIKit
import UI

class ProfileManagerViewModel: TableModelViewItem<PersonalManagerProfileViewCell> {
    
    private let profileImageURL: String
    private let profileName: String
    private let isHiddenTopSeparator: Bool
    private let isPersonalManager: Bool
    private let managerCode: String
    
    init(profileImageURL: String, profileName: String, isHiddenTopSeparator: Bool, isPersonalManager: Bool, managerCode: String, privateComponent: PresentationComponent) {
        self.profileImageURL = profileImageURL
        self.profileName = profileName
        self.isHiddenTopSeparator = isHiddenTopSeparator
        self.isPersonalManager = isPersonalManager
        self.managerCode = managerCode
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: PersonalManagerProfileViewCell) {
        viewCell.profileName.text = self.profileName
        if isPersonalManager {
            dependencies.imageLoader.loadWithAspectRatio(relativeUrl: "apps/SAN/imgGP/\(managerCode).jpg", imageView: viewCell.profileImageView, placeholderIfDoesntExist: "sanAvatar") { _ in
                viewCell.profileImageView.image = viewCell.profileImageView.image?.resizeTopAlignedToFill(newWidth: viewCell.profileImageView.frame.size.width)
            }
        } else {
            viewCell.profileImageView.image = Assets.image(named: "sanAvatar")
        }
        
        viewCell.topSeparatorView.isHidden = isHiddenTopSeparator
    }
}
