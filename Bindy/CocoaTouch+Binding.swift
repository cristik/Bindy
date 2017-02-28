//
//  CocoaTouch+Binding.swift
//  TakeOrToss
//
//  Created by Cristian Kocza on 14/01/2017.
//  Copyright © 2017 TakeOrToss. All rights reserved.
//

import UIKit

public extension UISwitch {
    
    public func bindIsOn<O: Observable>(to observable: O) -> AnyObject where O.ValueType == Bool {
        return bindIsOn(to: observable, transform: { $0 }, reverseTransform: { $0 })
    }
    
    public func bindIsOn<T, O: Observable>(to observable: O, transform: @escaping (T) -> Bool,
                         reverseTransform: @escaping (Bool) -> T) -> AnyObject where O.ValueType == T {
        return ControlValueObservable(control: self,
                                      getter: { return self.isOn },
                                      setter: { self.isOn = $0 })
            .bind(to: observable,
                  transform: transform,
                  reverseTransform: reverseTransform)
    }
}

public extension UILabel {
    public func bindText<O: Observable>(to observable: O) -> AnyObject where O.ValueType == String? {
        return bindText(to: observable, transform: { $0 })
    }
    
    public func bindText<T, O: Observable>(to observable: O, transform: @escaping (T) -> String?) -> AnyObject where O.ValueType == T {
        return ClosureObservable(getter: { return self.text }, setter: { self.text = $0 })
        .connect(to: observable, transform: transform)
    }
}

public extension UITextField {
    public func observableText(_ continous: Bool = false) -> AnyObservable<String?> {
        return AnyObservable(ControlValueObservable(control: self,
                                                    getter: { return self.text },
                                                    setter: { self.text = $0 },
                                                    event: continous ? .editingChanged : .editingDidEnd))
    }
    
    public func bindText<O: Observable>(to observable: O) -> AnyObject where O.ValueType == String? {
        return bindText(to: observable, transform: { $0 }, reverseTransform: { $0 })
    }
    
    public func bindText<T, O: Observable>(to observable: O, transform: @escaping (T) -> String?, reverseTransform: @escaping (String?) -> T) -> AnyObject where O.ValueType == T {
        return ClosureObservable(getter: { return self.text }, setter: { self.text = $0 })
            .bind(to: observable, transform: transform, reverseTransform: reverseTransform)
    }
}

public extension UIView {
    public func bindIsHidden<O: Observable>(to observable: O) -> AnyObject where O.ValueType == Bool {
        return bindIsHidden(to: observable, transform: { $0 })
    }
    
    public func bindIsHidden<T, O: Observable>(to observable: O, transform: @escaping (T) -> Bool) -> AnyObject where O.ValueType == T {
        return ClosureObservable(getter: { return self.isHidden },
                                 setter: { self.isHidden = $0 })
            .connect(to: observable, transform: transform)
    }
}

public extension UIControl {
    public func bindIsEnabled<O: Observable>(to observable: O) -> AnyObject where O.ValueType == Bool {
        return bindIsEnabled(to: observable, transform: { $0 })
    }
    
    public func bindIsEnabled<T, O: Observable>(to observable: O, transform: @escaping (T) -> Bool) -> AnyObject where O.ValueType == T {
        return ClosureObservable(getter: { return self.isEnabled },
                                 setter: { self.isEnabled = $0 })
            .connect(to: observable, transform: transform)
    }
}

public extension UIImageView {
    public func bindImage<O: Observable>(to observable: O) -> AnyObject where O.ValueType == UIImage? {
        return bindImage(to: observable, transform: { $0 })
    }
    
    public func bindImage<T, O: Observable>(to observable: O, transform: @escaping (T) -> UIImage?) -> AnyObject where O.ValueType == T {
        return ClosureObservable(getter: { return self.image },
                          setter: { self.image = $0 })
            .connect(to: observable, transform: transform)
    }
}

public extension UserDefaults {
    public func observableBool<O: Observable>(forKey key: String) -> O where O.ValueType == Bool {
        return KVOObservable(object: self,
                                           keyPath: key,
                                           transformer: { $0 as? Bool ?? false }) as! O
    }
}
