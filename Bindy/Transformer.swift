//
//  Transformer.swift
//  Bindy
//
//  Created by Cristian Kocza on 19/01/2017.
//  Copyright © 2017 cristik. All rights reserved.
//

public protocol Transformer {
    associatedtype From
    associatedtype To
    
    func transform(_ value: From) -> To
    func reverseTransform(_ value: To) -> From
}

public struct InlineTransformer<T,U>: Transformer {
    let direct: (T) -> U
    let reverse: (U) -> T
    
    public init(direct: @escaping (T) -> U, reverse: @escaping (U) -> T) {
        self.direct = direct
        self.reverse = reverse
    }
    
    public func transform(_ value: T) -> U {
        return direct(value)
    }
    
    public func reverseTransform(_ value: U) -> T {
        return reverse(value)
    }
}

public struct IdentityTransformer<T>: Transformer {
    public init() { }
    
    public func transform(_ value: T) -> T {
        return value
    }
    
    public func reverseTransform(_ value: T) -> T {
        return value
    }
}

public struct NegateBoolTransformer: Transformer {
    public init() { }
    
    public func transform(_ value: Bool) -> Bool {
        return !value
    }
    
    public func reverseTransform(_ value: Bool) -> Bool {
        return !value
    }
}
