import UIKit
import UI

class FavoriteRecipientWithCurrencyStackView: StackItemView {

    @IBOutlet weak var favoriteView: FavoriteView!
    
    func setAlias(_ alias: String, withTitle title: String) {
        favoriteView.setSubtitle(alias)
        favoriteView.setTitle(title)
    }
    
    func setCountry(_ country: String, withImageKey imageKey: String) {
        favoriteView.setLeftIconAndTitle(country, icon: Assets.image(named: "icnWorldRetail"))
    }
    
    func setCurrency(_ currency: String, withImageKey imageKey: String) {
        favoriteView.setRightIconAndTitle(currency, icon: Assets.image(named: "icnBillRetail"))
    }
    
    func displayAsField(_ isDisplayingAsField: Bool) {
        favoriteView.setTitleAsFieldTitle(isDisplayingAsField)
    }

}
