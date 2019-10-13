//
//  UITraitCollection+SizeClasses.swift
//
//  Created by Shady Mustafa on 18.07.19.
//

import UIKit

public extension UITraitCollection {
    var sizeClasses: (horizontal: UIUserInterfaceSizeClass, vertical: UIUserInterfaceSizeClass) {
        return (horizontal: horizontalSizeClass, vertical: verticalSizeClass)
    }
}
