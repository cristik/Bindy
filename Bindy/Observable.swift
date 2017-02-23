//
//  Observable.swift
//  Bindy
//
//  Created by Cristian Kocza on 21/02/2017.
//  Copyright © 2017 cristik. All rights reserved.
//

public protocol Observable: class {
    associatedtype ValueType
    
    var value: ValueType { get set }
    
    func register(callback: @escaping (ValueType) -> Void) -> AnyObject
    func deregister(entry: AnyObject)
}

public extension Observable {
    func connect<T, O: Observable>(to other: O,
              transform: @escaping (T) -> ValueType)
        -> AnyObject where O.ValueType == T {
            return OneWayBinder(left: self, right: other, r2l: transform)
    }
    
    func connect<O: Observable>(to other: O)
        -> AnyObject where O.ValueType == ValueType {
            return connect(to: other, transform: { $0 })
    }
    
    func bind<T, O: Observable>(to other: O,
              transform: @escaping (T) -> ValueType,
              reverseTransform: @escaping (ValueType) -> T)
        -> AnyObject where O.ValueType == T {
            return TwoWayBinder(left: other,
                                right: self,
                                l2r: transform,
                                r2l: reverseTransform)
    }
    
    func bind<O: Observable>(to other: O)
        -> AnyObject where O.ValueType == ValueType {
            return bind(to: other, transform: { $0 }, reverseTransform: { $0 })
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

// TODO: disconnect previous binder when setting a new one
fileprivate final class TwoWayBinder {
    private var doCleanup: (() -> Void)!
    private var ignoreLeft = false
    private var ignoreRight = false
    
    fileprivate convenience init<T, O1: Observable, O2: Observable>(left: O1,
                            right: O2) where O1.ValueType == T, O2.ValueType == T {
        self.init(left: left, right: right, l2r: { $0 }, r2l: { $0 })
    }
    
    fileprivate init<T, U, O1: Observable, O2: Observable>(left: O1,
                right: O2,
                l2r: @escaping (T) -> U,
                r2l: @escaping (U) -> T) where O1.ValueType == T, O2.ValueType == U {
        
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

fileprivate final class OneWayBinder {
    private var doCleanup: (() -> Void)!
    
    fileprivate convenience init<T, O1: Observable, O2: Observable>(left: O1,
                            right: O2) where O1.ValueType == T, O2.ValueType == T {
        self.init(left: left, right: right, r2l: { $0 })
    }
    
    fileprivate init<T, U, O1: Observable, O2: Observable>(left: O1,
                right: O2,
                r2l: @escaping (U) -> T) where O1.ValueType == T, O2.ValueType == U {
        
        left.value = r2l(right.value)
        
        let rightCallbackEntry = right.register {
            left.value = r2l($0)
        }
        
        doCleanup = {
            right.deregister(entry: rightCallbackEntry)
        }
    }
    
    deinit {
        doCleanup()
    }
}
