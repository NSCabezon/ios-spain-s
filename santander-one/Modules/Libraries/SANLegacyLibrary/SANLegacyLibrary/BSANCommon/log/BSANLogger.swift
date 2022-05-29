import Foundation


public protocol BSANLog {

    func v(_ tag: String, _ message: String)

    func v(_ tag: String, _ object: AnyObject)

    func i(_ tag: String, _ message: String)

    func i(_ tag: String, _ object: AnyObject)

    func d(_ tag: String, _ message: String)

    func d(_ tag: String, _ object: AnyObject)

    func e(_ tag: String, _ message: String)

    func e(_ tag: String, _ object: AnyObject)
}

public class BSANLogger {

    static var log: BSANLog?

    public static func setBSANLogger(_ log: BSANLog) {
        BSANLogger.log = log
    }

    public static func v(_ tag: String, _ message: String) {
        if let log = log {
            log.v(tag, message)
        }
    }

    public static func v(_ tag: String, _ object: AnyObject) {
        if let log = log {
            log.v(tag, object)
        }
    }

    public static func i(_ tag: String, _ message: String) {
        if let log = log {
            log.i(tag, message)
        }
    }

    public static func i(_ tag: String, _ object: AnyObject) {
        if let log = log {
            log.i(tag, object)
        }
    }

    public static func d(_ tag: String, _ message: String) {
        if let log = log {
            log.d(tag, message)
        }
    }

    public static func d(_ tag: String, _ object: AnyObject) {
        if let log = log {
            log.d(tag, object)
        }
    }


    public static func e(_ tag: String, _ message: String) {
        if let log = log {
            log.e(tag, message)
        }
    }

    public static func e(_ tag: String, _ object: AnyObject) {
        if let log = log {
            log.e(tag, object)
        }
    }

}
