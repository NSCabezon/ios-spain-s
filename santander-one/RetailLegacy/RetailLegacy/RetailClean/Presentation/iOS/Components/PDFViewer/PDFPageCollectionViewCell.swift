import UIKit

protocol PDFPageCollectionViewCellDelegate: class {
    func handleSingleTap(_ cell: PDFPageCollectionViewCell, pdfPageView: PDFPageView)
}

class PDFPageCollectionViewCell: UICollectionViewCell {
    
    var pageIndex: Int?
    var pageView: PDFPageView? {
        didSet {
            subviews.forEach { $0.removeFromSuperview() }
            if let pageView = pageView {
                addSubview(pageView)
            }
        }
    }
    
    private weak var pageCollectionViewCellDelegate: PDFPageCollectionViewCellDelegate?

    func setup(_ indexPathRow: Int, collectionViewBounds: CGRect, document: DocumentPDF, pageCollectionViewCellDelegate: PDFPageCollectionViewCellDelegate?) {
        self.pageCollectionViewCellDelegate = pageCollectionViewCellDelegate
        document.pdfPageImage(at: indexPathRow + 1) { (backgroundImage) in
            pageView = PDFPageView(frame: bounds, document: document, pageNumber: indexPathRow, backgroundImage: backgroundImage, pageViewDelegate: self)
            pageIndex = indexPathRow
        }
    }
}

extension PDFPageCollectionViewCell: PDFPageViewDelegate {
    func handleSingleTap(_ pdfPageView: PDFPageView) {
        pageCollectionViewCellDelegate?.handleSingleTap(self, pdfPageView: pdfPageView)
    }
}
