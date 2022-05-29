import Foundation
import CoreFoundationLib
import CoreDomain

class ProductDetailInfoPresenter: PrivatePresenter<ProductDetailInfoViewController, ProductDetailNavigatorProtocol, ProductDetailInfoPresenterProtocol>, ProductDetailProfileSeteable {
    var productInfo = [TableModelViewSection]()
    var productHome: PrivateMenuProductHome!
    var productDetailProfile: ProductDetailProfile? {
        didSet {
            if let productDetailProfile = productDetailProfile {
                productInfo = productDetailProfile.getInfo()
                self.view.reloadData()
                if productHome != .cards {
                    productDetailProfile.requestDetail(completion: { [weak self] (sections) in
                        guard let strongSelf = self else {
                            return
                        }
                        if let section = sections {
                            strongSelf.productInfo = section
                        } else {
                            strongSelf.productInfo = productDetailProfile.removeLoading(sections: strongSelf.productInfo)
                        }
                        strongSelf.view.reloadData()
                    })
                }
                
            }
        }
    }

    // MARK: - TrackerScreenProtocol

    override var screenId: String? {
        return nil
    }

    // MARK: -

    fileprivate func infoLoadingView() -> LoadingInfo {
        let type = LoadingViewType.onScreen(controller: view, completion: nil)
        let text = LoadingText(title: localized(key: "generic_popup_loading"))
        let info = LoadingInfo(type: type, loadingText: text, placeholders: nil, topInset: nil)
        return info
    }
}

extension ProductDetailInfoPresenter: Presenter {}

extension ProductDetailInfoPresenter: ProductDetailInfoPresenterProtocol {
    
}

extension ProductDetailInfoPresenter: ProductDetailInfoDataSourceDelegate {
    
    func endEditing(withNewAlias alias: String?) {
        
        guard let productDetailProfile = productDetailProfile, let card = productDetailProfile.genericProduct() as? Card else { return }
        guard let aliasChecked = alias, aliasChecked != "" else {
            let stringLoader = dependencies.stringLoader
            let accept = DialogButtonComponents(titled: stringLoader.getString("generic_button_accept"), does: nil)
            let text = stringLoader.getString("cardDetail_error_aliasCard")
                
            Dialog.alert(title: stringLoader.getString("generic_alert_title_errorData"), body: text, withAcceptComponent: accept, withCancelComponent: nil, showsCloseButton: true, source: view)
            return
        }

        let input = ChangeCardAliasNameInputUseCase(card: card.cardEntity, alias: aliasChecked.trim())
        let useCase = dependencies.useCaseProvider.changeCardAliasNameUseCase(input: input)
        showLoading(info: infoLoadingView())
        
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.hideLoading()
            strongSelf.productInfo.removeAll()
            productDetailProfile.aliasSection(withNewAlias: aliasChecked)
            strongSelf.productInfo = productDetailProfile.getInfo()
            strongSelf.view.reloadData()
            NotificationCenter.default.post(name: PresenterNotifications.updateChangeAliasDidReloadNotification, object: nil)
        }, onError: {[weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.hideLoading(completion: {() -> Void in
                strongSelf.showError(keyTitle: "", keyDesc: error?.getErrorDesc(), phone: nil, completion: nil)
            }, tag: 0)
        })
    }
    
    func edit() {
        guard let detailProfile = productDetailProfile else { return }
        productInfo = detailProfile.showEditCell(sections: productInfo)!
        view.reloadData()
    }
}
