//
//  UIView+Extension.swift
//  SearchTextField
//
//  Created by Rishu Gupta on 05/12/20.
//

import UIKit

//MARK:- UIView Extension
extension UIView {
    func addShadow(offset: CGSize = CGSize.zero, color: UIColor = .black, opacity: Float = 0.11, radius: CGFloat = 10.0) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
    }

}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
