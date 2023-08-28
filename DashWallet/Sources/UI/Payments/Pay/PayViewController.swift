//
//  Created by PT
//  Copyright © 2023 Dash Core Group. All rights reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://opensource.org/licenses/MIT
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

// MARK: - PayViewControllerDelegate

protocol PayViewControllerDelegate: AnyObject {
    func payViewControllerDidFinishPayment(_ controller: PayViewController, contact: DWDPBasicUserItem?)
}

// MARK: - PayViewController

class PayViewController: BaseViewController, PayableViewController {
    @IBOutlet weak var tableView: UITableView!

    var paymentController: PaymentController!

    var payModel: DWPayModelProtocol!
    
    var dataProvider: DWTransactionListDataProviderProtocol!

    var maxActionButtonWidth: CGFloat = 0

    var demoMode = false

    var delegate: PayViewControllerDelegate?

    static func controller(with payModel: DWPayModelProtocol, dataProvider: DWTransactionListDataProviderProtocol) -> PayViewController {
        let storyboard = UIStoryboard(name: "Pay", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! PayViewController
        controller.payModel = payModel
        controller.dataProvider = dataProvider

        return controller
    }

    // MARK: Actions

    private func showEnterAddressController() {
        let vc = EnterAddressViewController()
        vc.paymentControllerDelegate = self
        navigationController?.pushViewController(vc, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configurePaymentController()
        configureHierarchy()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.flashScrollIndicators()
        if demoMode {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.performPayToPasteboardAction()
            }
        }
    }
}

extension PayViewController {
    private func configurePaymentController() {
        paymentController = PaymentController()
        paymentController.delegate = self
        paymentController.presentationContextProvider = self
    }

    private func configureHierarchy() {
        let cellId = PayTableViewCell.reuseIdentifier
        let nib = UINib(nibName: cellId, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
        tableView.rowHeight = 59
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = EmptyView()
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: CGFloat.leastNormalMagnitude))
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.sectionHeaderHeight = CGFloat.leastNonzeroMagnitude
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate

extension PayViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        payModel.options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = PayTableViewCell.reuseIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PayTableViewCell
        let option = payModel.options[indexPath.row]
        cell.model = option
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let payOption = payModel.options[indexPath.row]

        switch payOption.type {
        case .scanQR:
            performScanQRCodeAction(delegate: self)
        case .pasteboard:
            showEnterAddressController()
        case .NFC:
            performNFCReadingAction()
        case .dashPayUser:
            performPayToDashPayUser(with: dataProvider, delegate: self)
        @unknown default:
            break
        }
    }
}



// MARK: DWQRScanModelDelegate

extension PayViewController: DWQRScanModelDelegate {
    func qrScanModel(_ viewModel: DWQRScanModel, didScanPaymentInput paymentInput: DWPaymentInput) {
        dismiss(animated: true) { [weak self] in
            self?.paymentController.performPayment(with: paymentInput)
        }
    }

    func qrScanModelDidCancel(_ viewModel: DWQRScanModel) {
        dismiss(animated: true)
    }
}

// MARK: PaymentControllerDelegate, PaymentControllerPresentationContextProviding

extension PayViewController: PaymentControllerDelegate, PaymentControllerPresentationContextProviding {
    func presentationAnchorForPaymentController(_ controller: PaymentController) -> PaymentControllerPresentationAnchor {
        self
    }

    func paymentControllerDidFinishTransaction(_ controller: PaymentController, transaction: DSTransaction) {
        let model = TxDetailModel(transaction: transaction)
        let vc = SuccessTxDetailViewController(model: model)
        vc.modalPresentationStyle = .fullScreen
        vc.contactItem = paymentController.contactItem
        vc.delegate = self
        present(vc, animated: true)
    }

    func paymentControllerDidCancelTransaction(_ controller: PaymentController) { }

    func paymentControllerDidFailTransaction(_ controller: PaymentController) { }
}

// MARK: SuccessTxDetailViewControllerDelegate

extension PayViewController: SuccessTxDetailViewControllerDelegate {
    func txDetailViewControllerDidFinish(controller: SuccessTxDetailViewController) {
        delegate?.payViewControllerDidFinishPayment(self, contact: paymentController.contactItem)
    }
}

// MARK: DWContactsViewControllerPayDelegate
extension PayViewController: DWContactsViewControllerPayDelegate {
    func contactsViewController(_ controller: DWContactsViewController, payTo item: DWDPBasicUserItem) {
        dismiss(animated: true) { [weak self] in
            self?.performPayToUser(userItem: item)
        }
    }
    
    private func performPayToUser(userItem: DWDPBasicUserItem) {
        let paymentInput = payModel.paymentInput(withUser: userItem)
        self.paymentController.performPayment(with: paymentInput)
    }
}
