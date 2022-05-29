import UIKit

protocol PDFPageViewDelegate: class {    
    func handleSingleTap(_ pdfPageView: PDFPageView)
}

class PDFPageView: UIScrollView {
    private var tiledPDFView: TiledView
    private var scale: CGFloat
    private let zoomLevels: CGFloat = 2
    private var contentView: UIView
    private let backgroundImageView: UIImageView
    private let pdfPage: CGPDFPage
    private var zoomAmount: CGFloat?
    private weak var pageViewDelegate: PDFPageViewDelegate?
    
    init(frame: CGRect, document: DocumentPDF, pageNumber: Int, backgroundImage: UIImage?, pageViewDelegate: PDFPageViewDelegate?) {
        guard let pageRef = document.coreDocument.page(at: pageNumber + 1) else { fatalError() }
        
        pdfPage = pageRef
        self.pageViewDelegate = pageViewDelegate
        
        let originalPageRect = pageRef.originalPageRect
        
        scale = min(frame.width/originalPageRect.width, frame.height/originalPageRect.height)
        let scaledPageRectSize = CGSize(width: originalPageRect.width * scale, height: originalPageRect.height * scale)
        let scaledPageRect = CGRect(origin: originalPageRect.origin, size: scaledPageRectSize)
        
        guard !scaledPageRect.isEmpty else { fatalError() }
        
        contentView = UIView(frame: scaledPageRect)
        
        backgroundImageView = UIImageView(image: backgroundImage)
        backgroundImageView.frame = contentView.bounds
        
        tiledPDFView = TiledView(frame: contentView.bounds, scale: scale, newPage: pdfPage)
        
        super.init(frame: frame)
        
        let targetRect = bounds.insetBy(dx: 0, dy: 0)
        var zoomScale = zoomScaleThatFits(targetRect.size, source: bounds.size)
        
        minimumZoomScale = zoomScale
        maximumZoomScale = zoomScale * (zoomLevels * zoomLevels)
        zoomAmount = (maximumZoomScale - minimumZoomScale) / zoomLevels
        
        scale = 1
        if zoomScale > minimumZoomScale {
            zoomScale = minimumZoomScale
        }
        
        contentView.addSubview(backgroundImageView)
        contentView.sendSubviewToBack(backgroundImageView)
        contentView.addSubview(tiledPDFView)
        addSubview(contentView)
        
        let doubleTapOne = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapOne.numberOfTapsRequired = 2
        doubleTapOne.cancelsTouchesInView = false
        addGestureRecognizer(doubleTapOne)
        
        let singleTapOne = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
        singleTapOne.numberOfTapsRequired = 1
        singleTapOne.cancelsTouchesInView = false
        addGestureRecognizer(singleTapOne)
        
        singleTapOne.require(toFail: doubleTapOne)
        
        bouncesZoom = false
        decelerationRate = .fast
        delegate = self
        autoresizesSubviews = true
        autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentViewSize = contentView.frame.size
        let xOffset: CGFloat
        if contentViewSize.width < bounds.width {
            xOffset = (bounds.width - contentViewSize.width) / 2
        } else {
            xOffset = 0
        }
    
        let yOffset: CGFloat
        if contentViewSize.height < bounds.height {
            yOffset = (bounds.height - contentViewSize.height) / 2
        } else {
            yOffset = 0
        }
        
        contentView.frame = CGRect(origin: CGPoint(x: xOffset, y: yOffset), size: contentViewSize)
    }
    
    @objc func handleSingleTap(_ tapRecognizer: UITapGestureRecognizer) {
        pageViewDelegate?.handleSingleTap(self)
    }
    
    @objc func handleDoubleTap(_ tapRecognizer: UITapGestureRecognizer) {
        var newScale = zoomScale * zoomLevels
        if newScale >= maximumZoomScale {
            newScale = minimumZoomScale
        }
        let zoomRect = zoomRectForScale(newScale, zoomPoint: tapRecognizer.location(in: tapRecognizer.view))
        zoom(to: zoomRect, animated: true)
    }
    
    private func zoomScaleThatFits(_ target: CGSize, source: CGSize) -> CGFloat {
        let widthScale = target.width / source.width
        let heightScale = target.height / source.height
        return (widthScale < heightScale) ? widthScale : heightScale
    }
    
    private func zoomRectForScale(_ scale: CGFloat, zoomPoint: CGPoint) -> CGRect {
        
        let updatedContentSize = CGSize(width: contentSize.width/zoomScale, height: contentSize.height/zoomScale)
    
        let translatedZoomPoint = CGPoint(x: (zoomPoint.x / bounds.width) * updatedContentSize.width,
                                          y: (zoomPoint.y / bounds.height) * updatedContentSize.height)
        
        let zoomSize = CGSize(width: bounds.width / scale, height: bounds.height / scale)
    
        return CGRect(x: translatedZoomPoint.x - zoomSize.width / 2.0,
                      y: translatedZoomPoint.y - zoomSize.height / 2.0,
                      width: zoomSize.width,
                      height: zoomSize.height)
    }
}

extension PDFPageView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        self.scale = scale
    }
}
