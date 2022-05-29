import SANLegacyLibrary
import CoreFoundationLib
import Foundation

class Logger: BSANLog, DataLog {
    private let isLogEnabled: Bool
    
    init(isLogEnabled: Bool) {
        self.isLogEnabled = isLogEnabled
    }
    
    func v(_ tag: String, _ message: String) {
        base(tag, "💜 V", message)
    }
    
    func v(_ tag: String, _ object: AnyObject) {
        base(tag, "💜 V", object)
    }
    
    func i(_ tag: String, _ message: String) {
        base(tag, "💚 I", message)
    }
    
    func i(_ tag: String, _ object: AnyObject) {
        base(tag, "💚 I", object)
    }
    
    func d(_ tag: String, _ message: String) {
        base(tag, "💙 D", message)
    }
    
    func d(_ tag: String, _ object: AnyObject) {
        base(tag, "💙 D", object)
    }
    
    func e(_ tag: String, _ message: String) {
        base(tag, "💔 E", message)
    }
    
    func e(_ tag: String, _ object: AnyObject) {
        base(tag, "💔 E", object)
    }
    
    func v(_ context: Any, _ message: String) {
        v(String(describing: type(of: context)), message)
    }
    
    func v(_ context: Any, _ object: AnyObject) {
        v(String(describing: type(of: context)), object)
    }
    
    func i(_ context: Any, _ message: String) {
        i(String(describing: type(of: context)), message)
    }
    
    func i(_ context: Any, _ object: AnyObject) {
        i(String(describing: type(of: context)), object)
    }
    
    func d(_ context: Any, _ message: String) {
        d(String(describing: type(of: context)), message)
    }
    
    func d(_ context: Any, _ object: AnyObject) {
        d(String(describing: type(of: context)), object)
    }
    
    func e(_ context: Any, _ message: String) {
        e(String(describing: type(of: context)), message)
    }
    
    func e(_ context: Any, _ object: AnyObject) {
        e(String(describing: type(of: context)), object)
    }
    
    private func base(_ tag: String, _ mode: String, _ message: String) {
        guard isLogEnabled else { return }
        let messages = message.splitByLength(10000)
        var firstTag = "\(getTime()) \(mode): \(tag) -> "
        for msg in messages {
            print("\(firstTag)\(msg)", terminator: "")
            firstTag = ""
        }
        print("")
    }
    
    private func base(_ tag: String, _ mode: String, _ object: AnyObject) {
        guard isLogEnabled else { return }
        let messages = object.description.splitByLength(10000)
        var firstTag = "\(getTime()) \(mode): \(tag) -> "
        for msg in messages {
            print("\(firstTag)\(msg)", terminator: "")
            firstTag = ""
        }
        print("")
    }
    
    private func getTime() -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter.string(from: Date())
    }
}
