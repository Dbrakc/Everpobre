//
//  UiViewController+Navigation.swift
//  Everpobre
//
//  Created by David Braga  on 03/11/2018.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//

import UIKit
extension UIViewController{
    func wrappedInNavigation() -> UINavigationController{
        return UINavigationController(rootViewController: self)
    }
}
