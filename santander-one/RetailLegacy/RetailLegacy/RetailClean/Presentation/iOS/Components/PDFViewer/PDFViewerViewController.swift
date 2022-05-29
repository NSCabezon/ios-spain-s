import UIKit
import PDFKit
import MessageUI
import UI

protocol PDFViewerPresenterProtocol: Presenter {
    var pdfDocument: DocumentPDF? { get }
    var pdfData: Data { get }
    var title: LocalizedStylableText? { get }
    var shareFilename: String { get }
    func shareButtonPressed()
}

final class PDFViewerViewController: BaseViewController<PDFViewerPresenterProtocol>, UIDocumentInteractionControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    override class var storyboardName: String {
        return "PDFViewer"
    }
    
    //iOS PDF View for iOS less than 11.0
    @IBOutlet var collectionView: UICollectionView!
    
    var scrollDirection: UICollectionView.ScrollDirection = .vertical {
        didSet {
            if collectionView == nil {
                _ = view
            }
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = scrollDirection
            }
        }
    }
    
    override func prepareView() {
        super.prepareView()
        view.backgroundColor = .white
        styledTitle = presenter.title
        titleIdentifier = "pdfPageTitle"
        collectionView.register(PDFPageCollectionViewCell.self, forCellWithReuseIdentifier: "page")
        collectionView.isHidden = true
        
        if #available(iOS 11.0, *) {
            let pdfView = PDFView()
            pdfView.frame = view.bounds
            pdfView.translatesAutoresizingMaskIntoConstraints = false
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTappedPdfView(gestureRecognizer:)))
            gestureRecognizer.numberOfTapsRequired = 2
            pdfView.addGestureRecognizer(gestureRecognizer)
            pdfView.embedInto(container: view, insets: UIEdgeInsets(top: topbarHeight, left: 0, bottom: 0, right: 0))
            pdfView.displayMode = .singlePageContinuous
            pdfView.displayDirection = .vertical
            pdfView.autoScales = true
            pdfView.backgroundColor = .lightSanGray
            if let document = PDFDocument(data: presenter.pdfData) {
                pdfView.document = document
            }
        } else {
            collectionView.backgroundColor = .uiWhite
            collectionView.isHidden = false
        }
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .white,
            title: .title(key: title ?? "", identifier: "pdfPageTitle")
        )
        builder.setLeftAction(.back(action: #selector(dismissViewController)))
        builder.build(on: self, with: nil)
    }

    @objc private func dismissViewController() {
        if self.navigationController?.popViewController(animated: true) == nil {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc
    @available(iOS 11.0, *)
    private func doubleTappedPdfView(gestureRecognizer: UITapGestureRecognizer) {
        guard let pdfView = gestureRecognizer.view as? PDFView, pdfView.canZoomIn else {
            return
        }
        pdfView.scaleFactor *= 1.5
        UIView.animate(withDuration: 0.3) {
            pdfView.zoomIn(self)
        }
    }
    
    override public var prefersStatusBarHidden: Bool {
        return navigationController?.isNavigationBarHidden == true
    }
    
    override public var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override func shareButtonTouched() {
        presenter.shareButtonPressed()
    }
    
    func showActivity(with items: [Any]) {
        let controller = CustomActivityViewController(activityItems: items, applicationActivities: nil)
        if !MFMailComposeViewController.canSendMail() {
            controller.excludedActivityTypes = [.mail]
        }
        present(controller, animated: true, completion: nil)
    }
    
    // MARK: - CollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.pdfDocument?.pageCount ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "page", for: indexPath) as! PDFPageCollectionViewCell
        guard let document = presenter.pdfDocument else { return cell}
        cell.setup(indexPath.row, collectionViewBounds: collectionView.bounds, document: document, pageCollectionViewCellDelegate: self)
        return cell
    }
    
    // MARK: - CollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 1, height: collectionView.frame.height)
    }
}

extension PDFViewerViewController: PDFPageCollectionViewCellDelegate {
    
    func handleSingleTap(_ cell: PDFPageCollectionViewCell, pdfPageView: PDFPageView) {
        var shouldHide: Bool {
            guard let isNavigationBarHidden = navigationController?.isNavigationBarHidden else {
                return false
            }
            return !isNavigationBarHidden
        }
        UIView.animate(withDuration: 0.25) {
            self.navigationController?.setNavigationBarHidden(shouldHide, animated: true)
        }
    }
}
