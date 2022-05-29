import PDFKit
import WebKit
import UI

public struct A4PageConstants {
    public static let a4Height: CGFloat = 841.8
    public static let a4Width: CGFloat = 595.2
}

public class PDFCreator: NSObject {
    private let webView: WKWebView
    private var completion: ((_ data: Data) -> Void)?
    private var failed: (() -> Void)?
    private var renderer: UIPrintPageRenderer
    private let isAdaptableHeight: Bool
    
    public override init() {
        webView = WKWebView()
        renderer = UIPrintPageRenderer()
        isAdaptableHeight = true
        super.init()
        webView.navigationDelegate = self
    }
    
    public init(renderer: UIPrintPageRenderer) {
        webView = WKWebView()
        self.renderer = renderer
        isAdaptableHeight = false
        super.init()
        webView.navigationDelegate = self
    }

    public func createPDF(html: String, completion: @escaping (_ data: Data) -> Void, failed: @escaping () -> Void) {
        self.completion = completion
        self.failed = failed
        webView.loadHTMLString(html, baseURL: Bundle.uiModule?.resourceURL)
    }
    
    private func obtainPdf(height: CGFloat?) {
        let fmt = webView.viewPrintFormatter()
        renderer.addPrintFormatter(fmt, startingAtPageAt: 0)
        let pageHeight: CGFloat
        if isAdaptableHeight, let height: CGFloat = height {
            pageHeight = height < A4PageConstants.a4Height ? height: A4PageConstants.a4Height
        } else {
            pageHeight = A4PageConstants.a4Height
        }
        let page = CGRect(x: 0, y: 0, width: A4PageConstants.a4Width, height: pageHeight)
        let printable = page.insetBy(dx: 0, dy: 0)
        renderer.setValue(NSValue(cgRect: page), forKey: "paperRect")
        renderer.setValue(NSValue(cgRect: printable), forKey: "printableRect")
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, printable, nil)
        let numberOfPages: Int = renderer.numberOfPages > 1 ? renderer.numberOfPages: 1
        for index in 1...numberOfPages {
            UIGraphicsBeginPDFPage()
            let bounds = UIGraphicsGetPDFContextBounds()
            renderer.drawPage(at: index - 1, in: bounds)
        }
        UIGraphicsEndPDFContext()
        completion?(pdfData as Data)
    }
}

extension PDFCreator: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.readyState", completionHandler: { (_, _) in
            webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, _) in
                self.obtainPdf(height: height as? CGFloat)
            })
        })
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        failed?()
    }
}
