import CoreFoundationLib
import UIKit
import UI

final class BizumTopBarExampleViewController: UIViewController, UIGestureRecognizerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .oneSkyGray
        OneNavigationBarBuilder(.whiteWithRedComponents)
            .setLeftAction(.back)
            .setRightAction(.close, action: {
                self.navigationController?.popViewController(animated: true)
            })
            .setTitle(withKey: "toolbar_title_contact")
            .setTitleImage(withKey: "icnBizum")
            .build(on: self)
    }
}

final class AccountsTopBarExampleViewController: UIViewController, UIGestureRecognizerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .oneSkyGray
        OneNavigationBarBuilder(.whiteWithRedComponents)
            .setLeftAction(.back)
            .setRightAction(.search, action: {})
            .setRightAction(.close, action: {
                self.navigationController?.popViewController(animated: true)
            })
            .setTitle(withKey: "toolbar_title_accounts")
            .setTooltip(didTapTooltip)
            .build(on: self)
    }
    
    func didTapTooltip(sender: UIView) {
        let navigationToolTip = NavigationToolTip()
        navigationToolTip.add(title: localized("accountsTooltip_title_accounts"))
        navigationToolTip.add(description: localized("accountsTooltip_text_viewAccountsSection"))
        navigationToolTip.show(in: self, from: sender)
    }
}

final class GPTopBarExampleViewController: UIViewController, UIGestureRecognizerDelegate {
    var santanderLogo: OneNavigationBarSantanderLogo = .normal
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .oneSkyGray
        OneNavigationBarBuilder(.whiteWithRedComponents)
            .setLeftAction(.santanderLogo(santanderLogo))
            .setRightAction(.mail, action: {})
            .setRightAction(.search, action: {})
            .setRightAction(.menu, action: {
                self.navigationController?.popViewController(animated: true)
            })
            .build(on: self)
    }
}

final class TripTopBarExampleViewController: UIViewController, UIGestureRecognizerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        let imageView = UIImageView(image: Assets.image(named: "bg_travel"))
        self.view.addSubview(imageView)
        imageView.fullFit()
        OneNavigationBarBuilder(.transparentWithWhiteComponents)
            .setLeftAction(.back)
            .setRightAction(.search, action: {})
            .setRightAction(.menu, action: {
                self.navigationController?.popViewController(animated: true)
            })
            .setTitle(withKey: "toolbar_title_yourTrips")
            .setTooltip(didTapTooltip)
            .build(on: self)
    }
    
    func didTapTooltip(sender: UIView) {
        let navigationToolTip = NavigationToolTip()
        navigationToolTip.add(title: localized("security_button_travelMode"))
        navigationToolTip.add(description: localized("yourTripsTooltip_text_travelMode"))
        navigationToolTip.show(in: self, from: sender)
    }
}

final class SmartGPTopBarExampleViewController: UIViewController, UIGestureRecognizerDelegate {
    var santanderLogo: OneNavigationBarSantanderLogo = .normal
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        let imageView = UIImageView(image: Assets.image(named: "icnRedBackground"))
        self.view.addSubview(imageView)
        imageView.fullFit()
        OneNavigationBarBuilder(.transparentWithWhiteComponents)
            .setLeftAction(.santanderLogo(santanderLogo))
            .setRightAction(.mail, action: {})
            .setRightAction(.search, action: {})
            .setRightAction(.menu, action: {
                self.navigationController?.popViewController(animated: true)
            })
            .build(on: self)
    }
}
