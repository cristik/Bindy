import Foundation

public final class ObservableValue<T>: Observable {
    private var callbackList = CallbackList<T>()

    public var value: T {
        didSet {
            callbackList.forEach { $0(value) }
        }
    }
    
    public init(_ value: T) {
        self.value = value
    }
    
    public func register(callback: @escaping (T) -> Void) -> AnyObject {
        return callbackList.add(callback: callback)
    }
    
    public func deregister(entry: AnyObject) {
        callbackList.remove(entry: entry)
    }
}

public final class ObservableKeyPath<T>: NSObject, Observable {
    private var callbackList = CallbackList<T>()
    public let object: NSObject
    public let keyPath: String
    public let transformer: ((Any?) -> T)?
    
    public var value: T {
        get {
            guard let transformer = transformer else {
                return (object.value(forKeyPath: keyPath) as Any as? T)!
            }
            return transformer(object.value(forKeyPath: keyPath))
        }
        set {
            object.setValue(newValue, forKeyPath: keyPath)
        }
    }
    
    public required init(object: NSObject, keyPath: String, transformer: ((Any?) -> T)? = nil) {
        self.object = object
        self.keyPath = keyPath
        self.transformer = transformer
        super.init()
        object.addObserver(self,
                           forKeyPath: keyPath,
                           options: [NSKeyValueObservingOptions.new],
                           context: nil)
    }
    
    public func register(callback: @escaping (T) -> Void) -> AnyObject {
        return callbackList.add(callback: callback)
    }
    
    public func deregister(entry: AnyObject) {
        callbackList.remove(entry: entry)
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // we want to crash if `change` is not provided, it means the runtime failed
        var change = change!
        if change[.newKey] is NSNull { change.removeValue(forKey: .newKey) }
        let newValue = (change[.newKey] as Any as? T)!
        callbackList.forEach { $0(newValue) }
    }
}
