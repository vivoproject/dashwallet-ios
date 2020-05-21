//
//  Created by administrator
//  Copyright © 2020 Dash Core Group. All rights reserved.
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

#import <DashSync/DashSync.h>
#import <Foundation/Foundation.h>

#import "DWUserDetails.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DWUserDetailsConvertible <NSFetchRequestResult>

- (id<DWUserDetails>)asUserDetails;

@end

@interface DSFriendRequestEntity (DSFriendRequestEntity_DWUserDetailsConvertible) <DWUserDetailsConvertible>

@end

@interface DSDashpayUserEntity (DSDashpayUserEntity_DWUserDetailsConvertible) <DWUserDetailsConvertible>

@end

NS_ASSUME_NONNULL_END
