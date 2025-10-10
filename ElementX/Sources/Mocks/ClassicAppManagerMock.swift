//
// Copyright 2026 Element Creations Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Foundation

extension ClassicAppManagerMock {
    struct Configuration {
        let accounts: [ClassicAppAccount]
    }
    
    convenience init(_ configuration: Configuration) {
        self.init()
        
        loadAccountsClosure = { configuration.accounts }
    }
}

extension ClassicAppAccount {
    static var mockDan: ClassicAppAccount {
        ClassicAppAccount(userID: "@dan:matrix.org",
                          displayName: "Dan",
                          avatarURL: .mockMXCUserAvatar,
                          serverName: "matrix.org",
                          cryptoStoreURL: .cachesDirectory,
                          cryptoStorePassphrase: "1234567890")
    }
}
