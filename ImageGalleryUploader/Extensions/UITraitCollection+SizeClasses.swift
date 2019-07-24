//
//  UITraitCollection+SizeClasses.swift
//  Mobile
//
//  Created by Shady Mustafa on 18.07.19.
//  Copyright © 2019 Spark Network. All rights reserved.
//

import UIKit

public extension UITraitCollection {
    var sizeClasses: (horizontal: UIUserInterfaceSizeClass, vertical: UIUserInterfaceSizeClass) {
        return (horizontal: horizontalSizeClass, vertical: verticalSizeClass)
    }
}
