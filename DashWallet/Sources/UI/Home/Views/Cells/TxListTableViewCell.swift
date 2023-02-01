//  
//  Created by tkhp
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

@objc(DWTxListTableViewCell)
final class TxListTableViewCell: UITableViewCell {
    @IBOutlet var txItemView: TransactionItemView!

    @objc
    func update(with transaction: DSTransaction, dataProvider: DWTransactionListDataProviderProtocol) {
        txItemView.update(with: transaction, dataProvider: dataProvider)
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        dw_pressedAnimation(.light, pressed: highlighted)
    }

    override class var dw_reuseIdentifier: String { "DWTxListTableViewCell" }
}
