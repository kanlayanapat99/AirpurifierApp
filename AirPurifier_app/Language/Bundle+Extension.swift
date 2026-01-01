//
//  Bundle+Extension.swift
//  AirPurifier_app
//
//  Created by Kanlayanapat Thintupthai on 30/7/2568 BE.
//

import Foundation

private var bundleKey: UInt8 = 0

class LocalizedBundle: Bundle, @unchecked Sendable {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        return (objc_getAssociatedObject(self, &bundleKey) as? Bundle)?.localizedString(forKey: key, value: value, table: tableName) ?? super.localizedString(forKey: key, value: value, table: tableName)
    }
}

extension Bundle {
    static func setLanguage(_ language: String) {
        defer {
            object_setClass(Bundle.main, LocalizedBundle.self)
        }
        let path = Bundle.main.path(forResource: language, ofType: "lproj") ?? Bundle.main.path(forResource: "en", ofType: "lproj")
        let value = path != nil ? Bundle(path: path!) : nil
        objc_setAssociatedObject(Bundle.main, &bundleKey, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
