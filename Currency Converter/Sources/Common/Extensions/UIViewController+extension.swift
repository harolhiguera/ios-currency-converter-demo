//
//  UIViewController+extension.swift
//  Currency Converter
//
//  Created by Harol_Higuera on 2020/12/29.
//

import UIKit

extension UIViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // ********** ********** Activity Indicator Utility ************ ******************* START ******
    
    var loaderIndicatorTag: Int { return 0x1686_BB6F }
    var overlayViewTag: Int { return 0x1090_6C47 }
    var overlayProgressViewTag: Int { return 0x1666_C412 }
    
    func startLoaderIndicator() {

        guard view.viewWithTag(loaderIndicatorTag) as? UIImageView == nil &&
            view.viewWithTag(overlayViewTag) == nil &&
            view.viewWithTag(overlayProgressViewTag) == nil else {
                return
        }
        
        // Let's ensure the UI is updated from the main thread.
        DispatchQueue.main.async(execute: {
            let overlay: UIView = UIView(frame: self.view.frame)
            overlay.backgroundColor = UIColor.clear
            overlay.isUserInteractionEnabled = true
            overlay.tag = self.overlayViewTag
            self.view.addSubview(overlay)
                    
            let activityIndicator = UIActivityIndicatorView(style: .medium)
            activityIndicator.tag = self.loaderIndicatorTag
            activityIndicator.hidesWhenStopped = true
            activityIndicator.startAnimating()
            activityIndicator.addCenteredToContainer(container: self.view)
        })
    }
    
    func stopLoaderIndicator() {
        DispatchQueue.main.async(execute: {
            for item in self.view.subviews {
                if item.tag == self.loaderIndicatorTag{
                    if let activityIndicator = item as? UIActivityIndicatorView {
                        activityIndicator.stopAnimating()
                        activityIndicator.removeFromSuperview()
                    }
                }else if item.tag == self.overlayViewTag || item.tag == self.overlayProgressViewTag {
                    item.removeFromSuperview()
                }
            }
        })
    }
}
