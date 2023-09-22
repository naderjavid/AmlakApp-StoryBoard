//
//  MelkDetail.swift
//  AmlakApp
//
//  Created by nader on 6/30/1402 AP.
//

import Foundation

struct MelkDetailItem: Decodable, Hashable {
    let id: Int // This is the "melkId" from the API response
    let parvandeh: Int // The "parvandeh" property from the API response
    let radif: Int // The "radif" property from the API response
    let radif2: Int? // The "radif2" property from the API response
    let tarikh: String? // The "tarikh" property from the API response (nullable)
    let sharh: String // The "sharh" property from the API response
    let aslKopy: Int // The "aslKopy" property from the API response
    let kamelNages: Int // The "kamelNages" property from the API response
    let tozihat: String? // The "tozihat" property from the API response (nullable)
    let readPermission: Bool // The "readPermission" property from the API response
    let updatePermission: Bool // The "updatePermission" property from the API response
    let deletePermission: Bool // The "deletePermission" property from the API response
    let creatorName: String // The "creatorName" property from the API response
    let lastModifierName: String // The "lastModifierName" property from the API response
    let noskheh: Int // The "noskheh" property from the API response
    let germez: Bool // The "germez" property from the API response
    let deleterName: String? // The "deleterName" property from the API response (nullable)
    let deletionTime: String? // The "deletionTime" property from the API response (nullable)
    let melkDetailAdminConfirmStatus: Int // The "melkDetailAdminConfirmStatus" property from the API response
    let melkDetailReviewConfirmStatus: Int // The "melkDetailReviewConfirmStatus" property from the API response
    let creationTime: String // The "creationTime" property from the API response
    let creatorId: String? // The "creatorId" property from the API response (nullable)
    let mojavvezMelks: [String]? // The "mojavvezMelks" property from the API response (It seems to be an array of unspecified type)
}

struct MelkDetailResponse: Decodable {
    let totalCount: Int
    let items: [MelkDetailItem]
}

