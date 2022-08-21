//
//  Bundle+StatusUI.swift
//  StatusUI
//
//  Created by Guilherme Rambo on 29/06/21.
//  Copyright © 2021 Guilherme Rambo. All rights reserved.
//

import Foundation

private final class _StubForStatusUIBundleInit {}

extension Bundle {
    static let statusUI = Bundle(for: _StubForStatusUIBundleInit.self)
}
