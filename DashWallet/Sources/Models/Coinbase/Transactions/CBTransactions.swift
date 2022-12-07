//
//  Created by tkhp
//  Copyright © 2022 Dash Core Group. All rights reserved.
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

import Foundation

final class CBTransactions {
    private var httpClient: CoinbaseAPI { CoinbaseAPI.shared }

    func send(from accountId: String, amount: String, to address: String, verificationCode: String?) async throws -> CoinbaseTransaction {
        let dto = CoinbaseTransactionsRequest(type: .send,
                                              to: address,
                                              amount: amount,
                                              currency: kDashCurrency,
                                              idem: UUID())

        let result: BaseDataResponse<CoinbaseTransaction> = try await httpClient
            .request(.sendCoinsToWallet(accountId: accountId, verificationCode: verificationCode, dto: dto))
        return result.data
    }
}
