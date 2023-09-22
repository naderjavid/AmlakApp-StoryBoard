//
//  Melk.swift
//  AmlakApp
//
//  Created by nader on 6/30/1402 AP.
//

import Foundation

struct MelkItem: Decodable, Hashable {
    let id: String
    let parvandeh: Int
    let name: String?
    let shamarehPelakSabti: String?
    let melkVaziat: Int
    let mabnayehMalekiyyat: Int
    let vaziateEntegal: Int
    let tozihat: String?
    let shoraka: String?
    let readPermission: Bool
    let updatePermission: Bool
    let deletePermission: Bool
    let creatorName: String
    let lastModifierName: String?
    let melkAdminConfirmStatus: Int
    let melkReviewConfirmStatus: Int
}

struct MelkResponse: Decodable {
    let totalCount: Int
    let items: [MelkItem]
}
