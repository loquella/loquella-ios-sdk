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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let numberOfPies = 2
        self.titleLabel.text = "I like one pie".translatePlural(count: numberOfPies, other: "I like two pies")
    }
}

