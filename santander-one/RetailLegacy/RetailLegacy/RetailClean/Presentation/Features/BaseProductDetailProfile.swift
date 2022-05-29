import UIKit.UIPasteboard

typealias DetailCardCell = CollectionCellConfigurator<ProductDetailCardCollectionViewCell, ProductDetailHeader>

protocol ProductDetailProfileDelegate: class, TrackerEventProtocol {
}

class BaseProductDetailProfile<T: Equatable>: ShareInfoHandler {
    
    weak var shareDelegate: ShowShareType?
    var logTag: String {
        return String(describing: type(of: self))
    }
    
    var emmaScreenToken: String? {
        return nil
    }
    
    var currentPosition = 0
    var completionHandler: ((CarouselItem) -> Void)?
    var detailProduct: T! {
        didSet {
            defer {
                completionHandler = nil
            }
            let result = convertToProductHeader(element: detailProduct, position: 0)
            completionHandler?(result)
        }
    }
    let dependencies: PresentationComponent
    let errorHandler: GenericPresenterErrorHandler

    weak var delegate: ProductDetailProfileDelegate?

    private var copiableTags = Set<CopyType>()

    init(errorHandler: GenericPresenterErrorHandler, dependencies: PresentationComponent, shareDelegate: ShowShareType?) {
        self.dependencies = dependencies
        self.errorHandler = errorHandler
        self.shareDelegate = shareDelegate
    }
    
    func convertToProductHeader(element: T, position: Int) -> CarouselItem {
        fatalError()
    }
    
    func detailProduct(completion: @escaping (CarouselItem) -> Void) {
        completionHandler = completion
        detailProduct = extractProduct()
    }
    
    func extractProduct() -> T {
        fatalError()
    }
    
    func infoToShareWithCode(_ code: Int?) -> String? {
        guard let tag = code, let info = copiableTags.first(where: { $0.tag == tag })?.info else {
            return nil
        }

        return info
    }
    
    func addCopyTag(tag: Int, info: String?) {
        copiableTags.insert(CopyType(tag: tag, info: info))
    }

//    // MARK: - ShareInfoHandler

    func shareInfoWithCode(_ code: Int?) {
        guard let infoToShare = infoToShareWithCode(code) else {
            return
        }
        shareDelegate?.shareContent(infoToShare)
    }
}
