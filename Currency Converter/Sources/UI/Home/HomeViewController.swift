//
//  HomeViewController.swift
//  Currency Converter
//
//  Created by Harol_Higuera on 2020/12/29.
//

import UIKit
import RxSwift

class HomeViewController: UIViewController, UIGestureRecognizerDelegate {
    
    let cellIdentifier = "HomeTableViewCell"
    
    @IBOutlet weak var selectContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    private var selectedCurrencyView: SelectedCurrencyView?
    private var unselectedCurrencyView: UnselectedCurrencyView?
    
    var viewModel: HomeViewModel!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = HomeViewModel()
        tableView.register(UINib(nibName: "HomeTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        subscribe()
        viewModel.input.fetchData.accept(())
    }
    
    private func subscribe() {
        
        viewModel!
            .output.list
            .asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: cellIdentifier, cellType: HomeTableViewCell.self)) {  (row,element,cell) in
                cell.labelCurrencyCode.text = element.rate.currencyCode
                cell.labelCurrencyName.text = element.rate.currencyName
                cell.labelValue.text = "\(element.conversion)"
            }.disposed(by: disposeBag)
        
        viewModel!
            .output.selectedCurrency
            .map { [weak self] in
                if (self?.selectedCurrencyView == nil) {
                    self?.setUpSelectCurrencyContainer(currencySelected: true)
                }
                self?.selectedCurrencyView!.labelCurencyCode.text = $0.currencyCode
                self?.selectedCurrencyView!.labelCurrencyName.text = $0.currencyName
            }
            .subscribe().disposed(by: disposeBag)
        
        viewModel!
            .output.onShowError
            .map { [weak self] in
                self?.showAlert(title: "Error", message: $0)
                if $0 == "Select a currency" {
                    self?.setUpSelectCurrencyContainer(currencySelected: false)
                }
            }
            .subscribe().disposed(by: disposeBag)
        
        viewModel!
            .output.onShowLoadingProgress
            .map {  [weak self] in
                $0 ? self?.startLoaderIndicator() : self?.stopLoaderIndicator()
            }
            .subscribe().disposed(by: disposeBag)
    }
    
    private func setUpSelectCurrencyContainer(currencySelected: Bool) {
        
        selectContainer.subviews.forEach {
            $0.removeFromSuperview()
        }
        
        if currencySelected {
            
            selectedCurrencyView = SelectedCurrencyView(frame: CGRect.zero)
            selectedCurrencyView!.addToContainer(container: selectContainer)
            addTapGestureRecognizer()
            
            selectedCurrencyView!.fieldValue
                .rx
                .text
                .observeOn(MainScheduler.asyncInstance)
                .throttle(.milliseconds(100), latest: false, scheduler: MainScheduler.asyncInstance)
                .bind(to: viewModel.input.convertText)
                .disposed(by: disposeBag)
            
            selectedCurrencyView!.buttonChangeCurrency
                .rx
                .tap
                .throttle(.seconds(1), latest: false, scheduler: MainScheduler.asyncInstance)
                .bind { [weak self] in
                    self?.showSelectCurrency()
                }.disposed(by: disposeBag)
            
        } else {
            
            unselectedCurrencyView = UnselectedCurrencyView(frame: CGRect.zero)
            unselectedCurrencyView!.addToContainer(container: selectContainer)
            
            unselectedCurrencyView!.buttonSelectCurrency
                .rx
                .tap
                .throttle(.seconds(1), latest: false, scheduler: MainScheduler.asyncInstance)
                .bind { [weak self] in
                    self?.showSelectCurrency()
                }.disposed(by: disposeBag)
            
        }
    }
    
    private func addTapGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    @objc func hideKeyboard(recognizer: UITapGestureRecognizer) {
        if selectedCurrencyView != nil {
            selectedCurrencyView!.fieldValue.resignFirstResponder()
        }
    }
    
    private func showSelectCurrency () {
        guard let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "currenciesVC") as? CurrenciesViewController else {
            return
        }
        viewController.refreshPrevious = { [weak self] in
            self?.viewModel.input.fetchData.accept(())
        }
        guard let navigator = navigationController else {
            return
        }
        navigator.pushViewController(viewController, animated: true)
    }
}
