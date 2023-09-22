//
//  MelkDetailAttachment.swift
//  AmlakApp
//
//  Created by nader on 6/30/1402 AP.
//

import Foundation

struct MelkDetailAttachmentItem: Decodable, Hashable {
    let id: String // This is the "id" property from the API response
    let melkDetailId: Int // The "melkDetailId" property from the API response
    let containerFilePath: String // The "containerFilePath" property from the API response
    let fileName: String // The "fileName" property from the API response
    let fileExtension: String // The "fileExtension" property from the API response
    let description: String? // The "description" property from the API response (nullable)
    let creatorName: String? // The "creatorName" property from the API response
    let isDeleted: Bool // The "isDeleted" property from the API response
    let deleterId: UUID? // The "deleterId" property from the API response (nullable)
    let deletionTime: String? // The "deletionTime" property from the API response (nullable)
    let lastModificationTime: String? // The "lastModificationTime" property from the API response (nullable)
    let lastModifierId: String? // The "lastModifierId" property from the API response (nullable)
    let creationTime: String // The "creationTime" property from the API response
    let creatorId: String // The "creatorId" property from the API response
}

struct MelkDetailAttachmentResponse: Decodable {
    let totalCount: Int
    let items: [MelkDetailAttachmentItem]
}
