//
//  SelectedCurrencyView.swift
//  Currency Converter
//
//  Created by Harol_Higuera on 2020/12/29.
//

import UIKit

class SelectedCurrencyView: UIView {
    
    @IBOutlet weak var fieldValue: UITextField!
    @IBOutlet weak var labelCurencyCode: UILabel!
    @IBOutlet weak var labelCurrencyName: UILabel!
    @IBOutlet weak var buttonChangeCurrency: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNib()
    }
    
    private func loadNib() {
        if let view = Bundle.main.loadNibNamed(String(describing: type(of: self)), owner: self)?.first as? UIView {
            view.frame = self.bounds
            self.addSubview(view)
        }
    }
    
}
