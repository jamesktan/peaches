//
//  PeachButton.swift
//  Peaches
//
//  Created by James Tan on 11/15/14.
//  Copyright (c) 2014 Axon Flux. All rights reserved.
//

import UIKit

@IBDesignable class PeachButton: UIButton {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }

}
