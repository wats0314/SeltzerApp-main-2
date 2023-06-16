//
//  User.swift
//  SeltzerApp
//
//  Created by Mitch Watson on 6/9/23.
//

import Foundation
import Foundation
import Firebase
import FirebaseFirestore

struct SeltzerAppUser: Identifiable, Codable {
    var id: String
    var name: String
    var seltzers: [Seltzer]
}

struct Seltzer: Codable {
    var id: String
    var brand: String
    var flavor: String
    var image: String?
    var userScore: Double?
    var globalScore: Double?
    var scored: Bool
    var isUpdatingScore: Bool?

    init(id: String, brand: String, flavor: String, image: String?, userScore: Double?, globalScore: Double?, scored: Bool, isUpdatingScore: Bool? = false) {
        self.id = id
        self.brand = brand
        self.flavor = flavor
        self.image = image
        self.userScore = userScore
        self.globalScore = globalScore
        self.scored = scored
        self.isUpdatingScore = isUpdatingScore
    }
}

