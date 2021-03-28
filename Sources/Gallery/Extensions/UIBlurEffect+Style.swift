//
//  UIBlurEffect+Style.swift
//  Gallery-iOS
//
//  Created by Vlada Radchenko on 10/2/19.
//  Copyright © 2019 Hyper Interaktiv AS. All rights reserved.
//

#if os(iOS)

import UIKit

extension UIBlurEffect.Style {

    static var albumsStyle: UIBlurEffect.Style {
        if #available(iOS 13, *) {
            return .systemThickMaterial
        } else {
            return .extraLight
        }
    }
}

#endif
