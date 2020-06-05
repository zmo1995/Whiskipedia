//
//  LoadingIndicator.swift
//  Whiskipedia
//
//  Created by ZHI XUAN MO on 6/5/20.
//  Copyright © 2020 zhixuan mo. All rights reserved.
//

import UIKit

open class LoadingIndicator {

internal static var indicator: UIActivityIndicatorView?
public static var style: UIActivityIndicatorView.Style = .whiteLarge
public static var baseBackColor = UIColor.black.withAlphaComponent(0.5)
public static var baseColor = UIColor.white

public static func start(style: UIActivityIndicatorView.Style = style, backgroundColor: UIColor = baseBackColor, color: UIColor = baseColor) {
    if indicator == nil, let window = UIApplication.shared.keyWindow {
        let frame = UIScreen.main.bounds
        indicator = UIActivityIndicatorView(frame: frame)
        indicator?.backgroundColor = backgroundColor
        indicator?.style = style
        indicator?.color = color
        window.addSubview(indicator!)
        indicator?.startAnimating()
    }
}

public static func stop() {
    if indicator != nil {
        indicator?.stopAnimating()
        indicator?.removeFromSuperview()
        indicator = nil
    }
}
}
