fileprivate final class CallbackListEntry {
    fileprivate let cleanup: (CallbackListEntry) -> Void
    
    fileprivate init(cleanup: @escaping (CallbackListEntry) -> Void) {
        self.cleanup = cleanup
    }
    
    deinit {
        cleanup(self)
    }
}

public final class CallbackList<T,U> {
    fileprivate var callbacks: [(CallbackListEntry, (T) -> U)] = []
    
    public func add(callback:  @escaping (T) -> U) -> AnyObject {
        let callbackEntry = CallbackListEntry(cleanup: { self.remove(entry: $0) } )
        callbacks.append((callbackEntry, callback))
        return callbackEntry
    }
    
    public func remove(entry: AnyObject) {
        guard let idx = callbacks.index(where: { $0.0 === entry }) else { return }
        callbacks.remove(at: idx)
    }
}

extension CallbackList: Collection {
    public var startIndex: Int { return callbacks.startIndex }
    public var endIndex: Int { return callbacks.endIndex }
    public func index(after i: Int) -> Int { return callbacks.index(after: i) }
    public subscript(_ index: Int) -> (T) -> U { return callbacks[index].1 }
}
