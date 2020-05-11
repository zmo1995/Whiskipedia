//
//  ArrayExtension.swift
//  Whiskipedia
//
//  Created by ZHI XUAN MO on 4/21/20.
//  Copyright © 2020 zhixuan mo. All rights reserved.
//

import Foundation



extension Array where Element: Equatable {

    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        guard let index = firstIndex(of: object) else {return}
        remove(at: index)
    }

}
