
public final class Binder {
    private var doCleanup: (() -> Void)!
    private var ignoreLeft = false
    private var ignoreRight = false
    
    public convenience init<T, O1: Observable, O2: Observable>(left: O1,
                right: O2) where O1.ValueType == T, O2.ValueType == T {
        self.init(left: left, right: right, l2r: { $0 }, r2l: { $0 })
    }
    
    public init<T, U, O1: Observable, O2: Observable>(left: O1,
                right: O2,
                l2r: @escaping (T) -> U,
                r2l: @escaping (U) -> T) where O1.ValueType == T, O2.ValueType == U {
        
        left.value = r2l(right.value)
        right.value = l2r(left.value)
        
        let leftCallbackEntry = left.register {
            guard !self.ignoreLeft else { return }
            self.ignoreRight = true
            right.value = l2r($0)
            self.ignoreRight = false
        }
        let rightCallbackEntry = right.register {
            guard !self.ignoreRight else { return }
            self.ignoreLeft = true
            left.value = r2l($0)
            self.ignoreLeft = false
        }
        
        doCleanup = {
            left.deregister(entry: leftCallbackEntry)
            right.deregister(entry: rightCallbackEntry)
        }
    }
    
    deinit {
        doCleanup()
    }
}

public final class Linker {
    private var doCleanup: (() -> Void)!
    private var ignoreLeft = false
    
    public convenience init<T, O1: Observable, O2: Observable>(left: O1,
                            right: O2) where O1.ValueType == T, O2.ValueType == T {
        self.init(left: left, right: right, l2r: { $0 })
    }
    
    public init<T, U, O1: Observable, O2: Observable>(left: O1,
                right: O2,
                l2r: @escaping (T) -> U) where O1.ValueType == T, O2.ValueType == U {
        
        right.value = l2r(left.value)
        
        let leftCallbackEntry = left.register {
            guard !self.ignoreLeft else { return }
            right.value = l2r($0)
        }
        
        doCleanup = {
            left.deregister(entry: leftCallbackEntry)
        }
    }
    
    deinit {
        doCleanup()
    }
}
