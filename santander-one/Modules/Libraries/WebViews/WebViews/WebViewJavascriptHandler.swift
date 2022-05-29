import Foundation

public struct JavascriptMessage {
    public var name: String
    public var body: String
    
    public init (name: String, body: String) {
        self.name = name
        self.body = body
    }
}

public enum JavascriptAction: String, CaseIterable {
    case showPDF = "showBASE64PDF"
    case downloadFile = "showBASE64File"
    case shareText = "shareText"
    case selectContacts = "selectContacts"
}

public class WebViewJavascriptHandler {
    public init() { }
    private struct File: Codable {
        let fileName: String
        let base64: String
    }
    
    public weak var delegate: WebViewJavascriptHandlerDelegate?
    public func handleReceived(message: JavascriptMessage) {
        guard let type = JavascriptAction(rawValue: message.name) else { return }
        switch type {
        case .showPDF:
            guard let bodyData = Data(base64Encoded: message.body) else { return }
            delegate?.handlePDF(with: bodyData)
        case .downloadFile:
            guard
                let bodyData = message.body.data(using: .utf8),
                let file = try? JSONDecoder().decode(File.self, from: bodyData),
                let fileData =  Data(base64Encoded: file.base64)
            else {
                return assertionFailure("Error parsing message \(message.body)")
            }
            delegate?.handleFileWithData(fileData, title: file.fileName)
        case .shareText:
            delegate?.shareText(message.body)
        case .selectContacts:
            delegate?.handleContacts()
        }
    }
}

public protocol WebViewJavascriptHandlerDelegate: AnyObject {
    func handlePDF(with data: Data)
    func handleFileWithData(_ data: Data, title: String)
    func shareText(_ text: String)
    func handleContacts()
}
