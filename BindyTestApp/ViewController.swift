//
//  ViewController.swift
//  BindyTestApp
//
//  Created by Cristian Kocza on 18/01/2017.
//  Copyright © 2017 cristik. All rights reserved.
//

import UIKit
import Bindy

class ViewController: UIViewController {
    @IBOutlet weak var switch1: UISwitch!
    @IBOutlet weak var textfield1: UITextField!
    
    @IBOutlet weak var switch2: UISwitch!
    @IBOutlet weak var label2: UILabel!
    
    var binders: [AnyObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        binders.append(switch1.bindIsOn(to: textfield1.observableText(continous: true),
                                        transform: { return $0 == "On" },
                                        reverseTransform: { $0 ? "On" : "Off" }))
        //binders.append(switch2.bindIsOn(to: UserDefaults.standard.observableBool(forKey: "switch2")))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

