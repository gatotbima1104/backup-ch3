//
//  UpperFirstLetter.swift
//  MyQuickCook
//
//  Created by Muhamad Gatot Supiadin on 21/06/25.
//

extension String {
    var firstLetterUppercased: String {
        prefix(1).uppercased() + dropFirst()
    }
}
