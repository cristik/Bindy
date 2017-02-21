//
//  CocoaTouch+Binding.swift
//  TakeOrToss
//
//  Created by Cristian Kocza on 14/01/2017.
//  Copyright © 2017 TakeOrToss. All rights reserved.
//

import UIKit

public extension UISwitch {
    public func bindIsOn<O: Observable>(to observable: O) -> Binder where O.ValueType == Bool {
        return bindIsOn(to: observable, transformer: IdentityTransformer())
    }
    
    public func bindIsOn<V, O: Observable, T: Transformer>(to observable: O, transformer: T) -> Binder where O.ValueType == V, T.From == V, T.To == Bool {
        return Binder(left: observable,
                      right: ControlValueObservable(control: self,
                                                   getter: { return self.isOn },
                                                   setter: { self.isOn = $0 }),
                      l2r: { transformer.transform($0) },
                      r2l: { transformer.reverseTransform($0) })
    }
}

public extension UILabel {
    public func bindText(to: AnyObservable<String?>) {
        
    }
}

public extension UITextField {
    public func observableText(_ continous: Bool = false) -> AnyObservable<String?> {
        return AnyObservable(ControlValueObservable(control: self,
                                                    getter: { return self.text },
                                                    setter: { self.text = $0 },
                                                    event: continous ? .editingChanged : .editingDidEnd))
    }
}

public extension UIView {
    public func bindIsHidden<O: Observable>(to observable: O) -> Binder where O.ValueType == Bool {
        return bindIsHidden(to: observable, transformer: IdentityTransformer())
    }
    
    public func bindIsHidden<V, O: Observable, T: Transformer>(to observable: O, transformer: T) -> Binder where O.ValueType == V, T.From == V, T.To == Bool {
        return Binder(left: observable,
                      right: ClosureObservable(getter: { return self.isHidden },
                                               setter: { self.isHidden = $0 }),
                      l2r: { transformer.transform($0) },
                      r2l: { transformer.reverseTransform($0) })
    }
    
    public func bindIsHidden<V, O: Observable>(to observable: O,
                             transformer: @escaping (V) -> Bool) -> AnyObject where O.ValueType == V {
        isHidden = transformer(observable.value)
        return observable.register {
            self.isHidden = transformer($0)
        }
    }
}

public extension UIControl {
    public func bindIsEnabled<O: Observable>(to observable: O) -> Binder where O.ValueType == Bool {
        return bindIsEnabled(to: observable, transformer: IdentityTransformer())
    }
    
    public func bindIsEnabled<V, O: Observable, T: Transformer>(to observable: O, transformer: T) -> Binder where O.ValueType == V, T.From == V, T.To == Bool {
        return Binder(left: observable,
                      right: ClosureObservable(getter: { return self.isEnabled },
                                               setter: { self.isEnabled = $0 }),
                      l2r: { transformer.transform($0) },
                      r2l: { transformer.reverseTransform($0) })
    }
}

public extension UIImageView {
    public func bindImage<O: Observable>(to observable: O) -> Binder where O.ValueType == UIImage? {
        return bindImage(to: observable, transformer: IdentityTransformer())
    }
    
    public func bindImage<V, O: Observable, T: Transformer>(to observable: O, transformer: T) -> Binder where O.ValueType == V, T.From == V, T.To == UIImage? {
        return Binder(left: observable,
                      right: ClosureObservable(getter: { return self.image },
                                               setter: { self.image = $0 }),
                      l2r: { transformer.transform($0) },
                      r2l: { transformer.reverseTransform($0) })
    }
}

public extension UserDefaults {
    public func observableBool<O: Observable>(forKey key: String) -> O where O.ValueType == Bool {
        return KVOObservable(object: self,
                                           keyPath: key,
                                           transformer: { $0 as? Bool ?? false }) as! O
    }
}
