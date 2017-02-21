import Foundation

public protocol Observable: class {
    associatedtype ValueType
    
    var value: ValueType { get set }
    
    func register(callback: @escaping (ValueType) -> Void) -> AnyObject
    func deregister(entry: AnyObject)
}

extension Observable where ValueType == Bool {
    var not: Self {
        let negated = AnyObservable(self)        
        return negated  as! Self
    }
}

public final class AnyObservable<T>: Observable {
    private let _getter: () -> T
    private let _setter: (T) -> Void
    private let _register: (@escaping (T) -> Void) -> AnyObject
    private let _deregister: (AnyObject) -> Void
    
    public var value: T {
        get { return _getter() }
        set { _setter(newValue) }
    }
    
    public init<O: Observable>(_ observable: O) where O.ValueType == T {
        _getter = { return observable.value }
        _setter = { observable.value = $0 }
        _register = observable.register
        _deregister = observable.deregister
    }
    
    public func register(callback: @escaping (T) -> Void) -> AnyObject {
        return _register(callback)
    }
    
    public func deregister(entry: AnyObject) {
        _deregister(entry)
    }
}

public final class ObservableValue<T>: Observable {
    private var callbackList = CallbackList<T,Void>()

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

public final class KVOObservable<T>: NSObject, Observable {
    private var callbackList = CallbackList<T,Void>()
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

public final class ClosureObservable<T>: Observable {
    private var callbackList = CallbackList<T,Void>()
    private let getter: () -> T
    private let setter: (T) -> Void
    
    public var value: T {
        get { return getter() }
        set { setter(newValue); callbackList.forEach { $0(newValue) } }
    }
    
    public init(getter: @escaping () -> T, setter: @escaping (T) -> Void) {
        self.getter = getter
        self.setter = setter
    }
    
    public func register(callback: @escaping (T) -> Void) -> AnyObject {
        return callbackList.add(callback: callback)
    }
    
    public func deregister(entry: AnyObject) {
        callbackList.remove(entry: entry)
    }
}

public final class ControlValueObservable<T>: NSObject, Observable {
    private var callbackList = CallbackList<T,Void>()
    private let getter: () -> T
    private let setter: (T) -> Void
    
    public var value: T {
        get { return getter() }
        set { setter(newValue) }
    }
    
    public init(control: UIControl, getter: @escaping () -> T, setter: @escaping (T) -> Void, event: UIControlEvents = .valueChanged) {
        self.getter = getter
        self.setter = setter
        super.init()
        control.addTarget(self, action: #selector(controlValueChanged), for: event)
    }
    
    deinit {
        print("control observable deinited")
    }
    
    public func register(callback: @escaping (T) -> Void) -> AnyObject {
        return callbackList.add(callback: callback)
    }
    
    public func deregister(entry: AnyObject) {
        callbackList.remove(entry: entry)
    }
    
    func controlValueChanged(_ sender: UIControl) {
        callbackList.forEach { $0(getter()) }
    }
}

// TODO: not complete
public final class ObservableArray<T>: Observable {
    private var callbackList = CallbackList<[T],Void>()
    fileprivate var storage: [T]
    public var value: [T] {
        get { return storage }
        set { storage = newValue; callbackList.forEach { $0(newValue) } }
    }
    
    init() {
        storage = []
    }
    
    init(_ array: [T]) {
        storage = array
    }
    
    public func register(callback: @escaping ([T]) -> Void) -> AnyObject {
        return callbackList.add(callback: callback)
    }
    
    public func deregister(entry: AnyObject) {
        callbackList.remove(entry: entry)
    }
}

extension ObservableArray: Collection {
    public var startIndex: Int { return storage.startIndex }
    public var endIndex: Int { return storage.endIndex }
    public func index(after i: Int) -> Int { return storage.index(after: i) }
    public subscript(_ index: Int) -> T { return storage[index] }
}
