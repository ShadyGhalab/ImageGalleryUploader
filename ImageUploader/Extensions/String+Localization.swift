//
//  String+Localization.swift
//  Mobile
//
//  Created by Shady Mustafa on 17.07.19.
//  Copyright © 2019 Ebay. All rights reserved.
//

import Foundation

public extension String {
    /**
     Localized version of this string using it as a key in Localizable.strings in the main Bundle.
     */
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
