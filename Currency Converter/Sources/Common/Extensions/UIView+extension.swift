//
//  UIView+extension.swift
//  Currency Converter
//
//  Created by Harol_Higuera on 2020/12/29.
//

import UIKit

extension UIView {
    func addToContainer(container: UIView) {
        container.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        let left = NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: container, attribute: .left, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: container, attribute: .right, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1, constant: 0)
        container.addConstraints([left, top, right, bottom])
    }
    
    func addCenteredToContainer(container: UIView)  {
        container.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        let x = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: container, attribute: .centerX, multiplier: 1, constant: 0)
        let y = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: container, attribute: .centerY, multiplier: 1, constant: 0)
        container.addConstraints([x, y])
    }
}
