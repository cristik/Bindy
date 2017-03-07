//
//  CocoaTouch+Binding.swift
//  TakeOrToss
//
//  Created by Cristian Kocza on 14/01/2017.
//  Copyright © 2017 TakeOrToss. All rights reserved.
//

import UIKit

public final class ObservableControlValue<T>: NSObject, Observable {
    private var callbackList = CallbackList<T>()
    private let getter: () -> T
    private let setter: (T) -> Void
    
    public var value: T {
        get { return getter() }
        set { setter(newValue) }
    }
    
    public init(_ control: UIControl, getter: @escaping () -> T, setter: @escaping (T) -> Void, event: UIControlEvents = .valueChanged) {
        self.getter = getter
        self.setter = setter
        super.init()
        control.addTarget(self, action: #selector(controlValueChanged), for: event)
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

public extension UISwitch {
    
    public func bindIsOn<O: Observable>(to observable: O) -> AnyObject where O.ValueType == Bool {
        return bindIsOn(to: observable, transform: { $0 }, reverseTransform: { $0 })
    }
    
    public func bindIsOn<T, O: Observable>(to observable: O, transform: @escaping (T) -> Bool,
                         reverseTransform: @escaping (Bool) -> T) -> AnyObject where O.ValueType == T {
        return ObservableControlValue(self,
                                      getter: { return self.isOn },
                                      setter: { self.isOn = $0 })
            .bind(to: observable,
                  transform: transform,
                  reverseTransform: reverseTransform)
    }
}

public extension UILabel {
    public func connectText<O: Observable>(to observable: O) -> AnyObject where O.ValueType == String? {
        return connectText(to: observable, transform: { $0 })
    }
    
    public func connectText<T, O: Observable>(to observable: O, transform: @escaping (T) -> String?) -> AnyObject where O.ValueType == T {
        text = transform(observable.value)
        return observable.register { self.text = transform($0) }
    }
}

public extension UITextField {
    public func bindText<O: Observable>(to observable: O) -> AnyObject where O.ValueType == String? {
        return bindText(to: observable, transform: { $0 }, reverseTransform: { $0 })
    }
    
    public func bindText<T, O: Observable>(to observable: O, transform: @escaping (T) -> String?, reverseTransform: @escaping (String?) -> T) -> AnyObject where O.ValueType == T {
        return ObservableControlValue(self, getter: { return self.text }, setter: { self.text = $0 })
            .bind(to: observable, transform: transform, reverseTransform: reverseTransform)
    }
    
    public func observableText<O: Observable>(continous: Bool = false) -> O where O.ValueType == String? {
        return ObservableControlValue(self,
                                      getter: { self.text },
                                      setter: { self.text = $0 },
                                      event: continous ? .editingChanged : .editingDidEnd) as! O
    }
}

public extension UIView {
    public func connectIsHidden<O: Observable>(to observable: O) -> AnyObject where O.ValueType == Bool {
        return connectIsHidden(to: observable, transform: { $0 })
    }
    
    public func connectIsHidden<T, O: Observable>(to observable: O, transform: @escaping (T) -> Bool) -> AnyObject where O.ValueType == T {
        isHidden = transform(observable.value)
        return observable.register { self.isHidden = transform($0) }
    }
}

public extension UIControl {
    public func connectIsEnabled<O: Observable>(to observable: O) -> AnyObject where O.ValueType == Bool {
        return connectIsEnabled(to: observable, transform: { $0 })
    }
    
    public func connectIsEnabled<T, O: Observable>(to observable: O, transform: @escaping (T) -> Bool) -> AnyObject where O.ValueType == T {
        isEnabled = transform(observable.value)
        return observable.register { self.isEnabled = transform($0) }
    }
}

public extension UIImageView {
    public func connectImage<O: Observable>(to observable: O) -> AnyObject where O.ValueType == UIImage? {
        return connectImage(to: observable, transform: { $0 })
    }
    
    public func connectImage<T, O: Observable>(to observable: O, transform: @escaping (T) -> UIImage?) -> AnyObject where O.ValueType == T {
        image = transform(observable.value)
        return observable.register { self.image = transform($0) }
    }
}

public extension UserDefaults {
    public func observableBool<O: Observable>(forKey key: String) -> O where O.ValueType == Bool {
        return ObservableKeyPath(object: self,
                                 keyPath: key,
                                 transformer: { $0 as? Bool ?? false }) as! O
    }
}
