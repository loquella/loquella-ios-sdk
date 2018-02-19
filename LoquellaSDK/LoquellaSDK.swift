//
//  LoquellaSDK.swift
//  LoquellaSDK
//
//  Created by Rasmus Styrk on 19/02/2018.
//  Copyright © 2018 House of Code ApS. All rights reserved.
//

import Foundation
import UIKit

extension String {
    /**
     Translate a single string
     
     */
    func translate() -> String {
        // TODO: Imeplement actual logic
        return "[tr]: \(self)"
    }
    
    /**
     Translates a single string and saves a comment for the translator
     
     */
    func translate(comment: String) -> String {
        // TODO: Imeplement actual logic
        return "[tr]: \(self)"
    }
    
    /**
     Translate two strings but only showing either one or the other depending on count input
     
     */
    func translatePlural(count: Int, other: String) -> String {
        if count == 1 {
            return translate()
        } else {
            return other.translate()
        }
    }
}

extension UIView {
    /**
     Traverses all subviews and autotranslates anything with a label
     
     */
    func translateAll() {
        self.subviews.forEach { (view) in
            if view.isKind(of: UILabel.self) {
                if let label = view as? UILabel {
                    label.text = label.text?.translate() ?? ""
                }
            } else if view.isKind(of: UIButton.self) {
                if let button = view as? UIButton {
                    // TODO: Support all states
                    button.setTitle(button.title(for: .normal)?.translate() ?? "", for: .normal)
                }
            }
        }
    }
}
