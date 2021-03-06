//
//  InAppContainersTableViewController.swift
//  Adapty_Example
//
//  Created by Andrey Kyashkin on 03/01/2020.
//  Copyright © 2020 Adapty. All rights reserved.
//

import UIKit
import Adapty

class InAppContainersTableViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var paywalls: [PaywallModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    @objc private func refreshData() {
        loadData(forceUpdate: true)
    }
    
    private func loadData(forceUpdate: Bool = false) {
        Adapty.getPaywalls(forceUpdate: forceUpdate) { (paywalls, products, error) in
            self.tableView.refreshControl?.endRefreshing()
            self.paywalls = paywalls ?? []
            self.tableView.reloadData()
        }
    }
    
    @IBAction func restoreButtonAction(_ sender: Any) {
        setUI(enabled: false)
        Adapty.restorePurchases { (purchaserInfo, receipt, appleValidationResult, error) in
            self.setUI(enabled: true)
            self.showAlert(for: error)
        }
    }

}

extension InAppContainersTableViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(InAppContainersTableViewCell.self)", for: indexPath) as? InAppContainersTableViewCell else {
            return UITableViewCell()
        }
        
        cell.paywall = paywalls[indexPath.row]
        cell.delegate = self
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paywalls.count
    }
    
}

extension InAppContainersTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let paywall = paywalls[indexPath.row]
        
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "\(InAppTableViewController.self)") as? InAppTableViewController else {
            return
        }
        
        vc.paywallToShow = paywall
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension InAppContainersTableViewController: InAppContainersTableViewCellDelegate {
    
    func didShowRemotePaywall(for paywall: PaywallModel) {
        // simple showcase for paywall ui managed by remote config
        let vc = ShowcasePaywallViewController(paywall: paywall)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func didShowVisualPaywall(for paywall: PaywallModel) {
        Adapty.showVisualPaywall(for: paywall, from: self, delegate: self)
    }
}

extension InAppContainersTableViewController: AdaptyVisualPaywallDelegate {
    
    func didPurchase(product: ProductModel, purchaserInfo: PurchaserInfoModel?, receipt: String?, appleValidationResult: Parameters?, paywall: PaywallViewController) {
        Adapty.closeVisualPaywall(paywall)
    }
    
    func didFailPurchase(product: ProductModel, error: AdaptyError, paywall: PaywallViewController) {
        paywall.showAlert(for: error)
    }
    
    func didCancel(paywall: PaywallViewController) {
        Adapty.closeVisualPaywall(paywall)
    }
    
    func didRestore(purchaserInfo: PurchaserInfoModel?, receipt: String?, appleValidationResult: Parameters?, error: AdaptyError?, paywall: PaywallViewController) {
        paywall.showAlert(for: error)
    }
    
}
