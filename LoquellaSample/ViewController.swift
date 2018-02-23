//
//  ViewController.swift
//  LoquellaSample
//
//  Created by Rasmus Styrk on 19/02/2018.
//  Copyright © 2018 House of Code ApS. All rights reserved.
//

import UIKit
import LoquellaSDK

class ViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.titleLabel.translate() // Autotranslate from nib
        
        self.descriptionLabel.text = "We hope you enjoy our project".translate()
        self.versionLabel.text = "Version: :1".translate("1.0")
    }
}
