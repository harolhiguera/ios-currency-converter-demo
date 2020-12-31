//
//  CurrenciesViewController.swift
//  Currency Converter
//
//  Created by Harol_Higuera on 2020/12/29.
//

import UIKit
import RxSwift
import RxCocoa

class CurrenciesViewController: UIViewController {
    
    let cellIdentifier = "CurrenciesTableViewCell"
    
    var refreshPrevious : (() -> Void)?
    
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: CurrenciesViewModel!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = CurrenciesViewModel()
        tableView.register(UINib(nibName: "CurrenciesTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        subscribe()
        viewModel.fetchData()
    }
    
    
    private func subscribe() {
        
        viewModel!.currencies.bind(to: tableView.rx.items(cellIdentifier: cellIdentifier, cellType: CurrenciesTableViewCell.self)) {  (row,element,cell) in
            cell.labelName.text = element.currencyName
            cell.labelCode.text = element.currencyCode
        }.disposed(by: disposeBag)
        
        tableView.rx.modelSelected(RealmCurrency.self).subscribe(onNext: {  [weak self] in
            self?.viewModel.setSelectedCurrencyCode(code: $0.currencyCode)
            self?.refreshPrevious!()
            self?.pop()
        }).disposed(by: disposeBag)
        
        viewModel!
            .onShowError
            .map { [weak self] in
                self?.showAlert(title: "Error", message: $0.localizedDescription)
            }
            .subscribe().disposed(by: disposeBag)
        
        viewModel!
            .onShowLoadingProgress
            .map {  [weak self] in
                $0 ? self?.startLoaderIndicator() : self?.stopLoaderIndicator()
            }
            .subscribe().disposed(by: disposeBag)
    }
    
    private func pop() {
        guard let navigator = navigationController else {
            return
        }
        navigator.popViewController(animated: true)
    }
}
