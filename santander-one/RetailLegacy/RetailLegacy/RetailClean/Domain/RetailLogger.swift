import CoreFoundationLib

class RetailLogger {
    static var log: DataLog?
    
    static func setRetailLogger(_ log: DataLog) {
        RetailLogger.log = log
    }
    
    /**
     Logs a verbose priority message.
     It's used for explanations about some functionality.
     - Parameter tag: the class tag.
     - Parameter message: a message describing the log.
    */
    static func v(_ tag: String, _ message: String) {
        if let log = log {
            log.v(tag, message)
        }
    }
    
    /**
     Logs a verbose priority message.
     It's used for explanations about some functionality.
     - Parameter tag: the class tag.
     - Parameter object: an object indicating the log purpose.
     */
    static func v(_ tag: String, _ object: AnyObject) {
        if let log = log {
            log.v(tag, object)
        }
    }
    
    /**
     Logs an info priority message.
     It indicates that a larger operation/block has finished.
     - Parameter tag: the class tag.
     - Parameter message: a message describing the log.
     */
    static func i(_ tag: String, _ message: String) {
        if let log = log {
            log.i(tag, message)
        }
    }
    
    /**
     Logs an info priority message.
     It indicates that a larger operation/block has finished.
     - Parameter tag: the class tag.
     - Parameter object: an object indicating the log purpose.
     */
    static func i(_ tag: String, _ object: AnyObject) {
        if let log = log {
            log.i(tag, object)
        }
    }
    
    /**
     Logs a debug priority message.
     It indicates that a small operation has finished.
     - Parameter tag: the class tag.
     - Parameter message: a message describing the log.
     */
    static func d(_ tag: String, _ message: String) {
        if let log = log {
            log.d(tag, message)
        }
    }
    
    /**
     Logs a debug priority message.
     It indicates that a small operation has finished.
     - Parameter tag: the class tag.
     - Parameter object: an object indicating the log purpose.
     */
    static func d(_ tag: String, _ object: AnyObject) {
        if let log = log {
            log.d(tag, object)
        }
    }
    
    /**
     Logs an error priority message.
     It indicates that an error ocurred or something happened.
     - Parameter tag: the class tag.
     - Parameter message: a message describing the log.
     */
    static func e(_ tag: String, _ message: String) {
        if let log = log {
            log.e(tag, message)
        }
    }
    
    /**
     Logs an error priority message.
     It indicates that an error ocurred or something happended.
     - Parameter tag: the class tag.
     - Parameter object: an object indicating the log purpose.
     */
    static func e(_ tag: String, _ object: AnyObject) {
        if let log = log {
            log.e(tag, object)
        }
    }
}
