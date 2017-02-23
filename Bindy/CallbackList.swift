fileprivate final class CallbackListEntry {
    fileprivate let cleanup: (CallbackListEntry) -> Void
    
    fileprivate init(cleanup: @escaping (CallbackListEntry) -> Void) {
        self.cleanup = cleanup
    }
    
    deinit {
        cleanup(self)
    }
}

public final class CallbackList<T> {
    fileprivate var callbacks: [(CallbackListEntry, (T) -> Void)] = []
    
    public init() { }
    
    public func add(callback:  @escaping (T) -> Void) -> AnyObject {
        let callbackEntry = CallbackListEntry(cleanup: { self.remove(entry: $0) } )
        callbacks.append((callbackEntry, callback))
        return callbackEntry
    }
    
    public func remove(entry: AnyObject) {
        guard let idx = callbacks.index(where: { $0.0 === entry }) else { return }
        callbacks.remove(at: idx)
    }
    
    public func notify(_ arg: T) {
        callbacks.enumerated().forEach { $1.1(arg) }
    }
}

extension CallbackList: Collection {
    public var startIndex: Int { return callbacks.startIndex }
    public var endIndex: Int { return callbacks.endIndex }
    public func index(after i: Int) -> Int { return callbacks.index(after: i) }
    public subscript(_ index: Int) -> (T) -> Void { return callbacks[index].1 }
}
