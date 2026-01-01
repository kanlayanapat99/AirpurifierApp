//
//  String+Localization.swift
//  AirPurifier_app
//
//  Created by วิรัญชนา ประเสริฐวณิช on 27/7/2568 BE.
//

import Foundation

extension String {
    var loc: String {
        NSLocalizedString(self, comment: "")
    }
}

func localizedMode(_ mode: String) -> String {
    switch mode.lowercased() {
    case "auto":
        return "Auto".loc
    case "manual":
        return "Manual".loc
    default:
        return mode.capitalized
    }
}


