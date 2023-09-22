//
//  FetchMethods.swift
//  AmlakApp
//
//  Created by nader on 6/31/1402 AP.
//

import Foundation
import CoreData

let BASE_URL = "https://nazm.net:2025"
let mainQueue = DispatchQueue(label: "com.melk.main")

func getMelksData(completion: @escaping ([MelkItem]?, Error?) -> Void) {
    // Fetch data from the API
    fetchMelksFromAPI(maxResultCount: 1, skipCount: 0) { melk, error in
        if let error = error {
            print("Error fetching melks data from API: \(error)")
            return
        }
        
        if let melk = melk {
            fetchMelksFromAPI(maxResultCount: melk.totalCount, skipCount: 0) { melkResponse, error in
                if let error = error {
                    print("Error fetching data from API: \(error)")
                    return
                }
                
                if let melkResponse = melkResponse {
                    
                    
                    mainQueue.async {
                        updateMelksInCoreData(with: melkResponse.items)
                    }
                    
                    completion(melkResponse.items, nil)
                }
            }
        }
    }
}

func fetchMelksFromAPI(maxResultCount: Int, skipCount: Int, completion: @escaping (MelkResponse?, Error?) -> Void) {
    DispatchQueue.global(qos: .background).async {
        let urlString = "\(BASE_URL)/api/app/melk/ba-shoraka?MaxResultCount=\(maxResultCount)&SkipCount=\(skipCount)"
        print(urlString)
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request = addAccessTokenToHeader(request: request)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print(String(data: data, encoding: .utf8) as Any)
                completion(nil, NetworkError.invalidResponse)
                return
            }
            
            do {
                let melkResponse = try JSONDecoder().decode(MelkResponse.self, from: data)
                completion(melkResponse, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
}

func updateMelksInCoreData(with newMelks: [MelkItem]) {
    context.perform {
        
        for newMelk in newMelks {
            let fetchRequest: NSFetchRequest<MelkEntity> = MelkEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "melkId == %@", newMelk.id)
            
            do {
                let existingMelks = try context.fetch(fetchRequest)
                if let existingMelk = existingMelks.first {
                    existingMelk.parvandeh = Int16(newMelk.parvandeh)
                    existingMelk.name = (newMelk.name ?? "").replacingOccurrences(of: "\n", with: "", options: .caseInsensitive)
                    existingMelk.shamarehPelakSabti = (newMelk.shamarehPelakSabti ?? "").replacingOccurrences(of: "\n", with: "", options: .caseInsensitive)
                    existingMelk.melkVaziat = Int16(newMelk.melkVaziat)
                    existingMelk.mabnayehMalekiyyat = Int16(newMelk.mabnayehMalekiyyat)
                    existingMelk.vaziateEntegal = Int16(newMelk.vaziateEntegal)
                    existingMelk.tozihat = newMelk.tozihat
                    existingMelk.shoraka = newMelk.shoraka ?? ""
                    existingMelk.readPermission = newMelk.readPermission
                    existingMelk.updatePermission = newMelk.updatePermission
                    existingMelk.deletePermission = newMelk.deletePermission
                    existingMelk.lastModifierName = newMelk.lastModifierName ?? ""
                    existingMelk.melkAdminConfirmStatus = Int16(newMelk.melkAdminConfirmStatus)
                    existingMelk.melkReviewConfirmStatus = Int16(newMelk.melkReviewConfirmStatus)
                } else {
                    let newMelkEntity = MelkEntity(context: context)
                    newMelkEntity.melkId = newMelk.id
                    newMelkEntity.parvandeh = Int16(newMelk.parvandeh)
                    newMelkEntity.name = (newMelk.name ?? "").replacingOccurrences(of: "\n", with: "", options: .caseInsensitive)
                    newMelkEntity.shamarehPelakSabti = (newMelk.shamarehPelakSabti ?? "").replacingOccurrences(of: "\n", with: "", options: .caseInsensitive)
                    newMelkEntity.melkVaziat = Int16(newMelk.melkVaziat)
                    newMelkEntity.mabnayehMalekiyyat = Int16(newMelk.mabnayehMalekiyyat)
                    newMelkEntity.vaziateEntegal = Int16(newMelk.vaziateEntegal)
                    newMelkEntity.tozihat = newMelk.tozihat
                    newMelkEntity.shoraka = newMelk.shoraka ?? ""
                    newMelkEntity.readPermission = newMelk.readPermission
                    newMelkEntity.updatePermission = newMelk.updatePermission
                    newMelkEntity.deletePermission = newMelk.deletePermission
                    newMelkEntity.creatorName = newMelk.creatorName ?? ""
                    newMelkEntity.lastModifierName = newMelk.lastModifierName ?? ""
                    newMelkEntity.melkAdminConfirmStatus = Int16(newMelk.melkAdminConfirmStatus)
                    newMelkEntity.melkReviewConfirmStatus = Int16(newMelk.melkReviewConfirmStatus)
                }
            } catch {
                print("Error updating melks in Core Data: \(error)")
            }
        }
        
        do {
            try context.save()
            print("Melks updated in Core Data")
        } catch {
            print("Error saving melks data to Core Data: \(error)")
        }
    }
}

func getMelkDetailsData(parvandeh: Int, completion: @escaping ([MelkDetailItem]?, Error?) -> Void) {
    // Fetch data from the API
    fetchMelkDetailsFromAPI(parvandeh: parvandeh, maxResultCount: 1, skipCount: 0) { melkDetail, error in
        if let error = error {
            print("Error fetching melkDetails data from API: \(error)")
            return
        }
        
        if let melkDetail = melkDetail {
            fetchMelkDetailsFromAPI(parvandeh: parvandeh, maxResultCount: melkDetail.totalCount, skipCount: 0) { melkDetailResponse, error in
                if let error = error {
                    print("Error fetching data from API: \(error)")
                    return
                }
                
                if let melkDetailResponse = melkDetailResponse {
                    mainQueue.async {
                        updateMelkDetailsInCoreData(with: melkDetailResponse.items)
                    }
                    
                    completion(melkDetailResponse.items, nil)
                }
            }
        }
    }
}



func fetchMelkDetailsFromAPI(parvandeh: Int, maxResultCount: Int, skipCount: Int, completion: @escaping (MelkDetailResponse?, Error?) -> Void) {
    DispatchQueue.global(qos: .background).async {
        let urlString = "\(BASE_URL)/api/app/melk-detail/?Parvandeh=\(parvandeh)&MaxResultCount=\(maxResultCount)&SkipCount=\(skipCount)"
        print(urlString)
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request = addAccessTokenToHeader(request: request)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print(String(data: data, encoding: .utf8) as Any)
                completion(nil, NetworkError.invalidResponse)
                return
            }
            
            do {
                let melkDetailResponse = try JSONDecoder().decode(MelkDetailResponse.self, from: data)
                completion(melkDetailResponse, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
}

func updateMelkDetailsInCoreData(with newMelkDetails: [MelkDetailItem]) {
    context.perform {
        for newMelkDetail in newMelkDetails {
            let fetchRequest: NSFetchRequest<MelkDetailEntity> = MelkDetailEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "melkId == %ld", newMelkDetail.id)
            
            do {
                let existingMelkDetails = try context.fetch(fetchRequest)
                if let existingMelkDetail = existingMelkDetails.first {
                    existingMelkDetail.parvandeh = Int16(newMelkDetail.parvandeh)
                    existingMelkDetail.radif = Int16(newMelkDetail.radif)
                    existingMelkDetail.radif2 = Int16(newMelkDetail.radif2 ?? 0)
                    //existingMelkDetail.tarikh = newMelkDetail.tarikh
                    existingMelkDetail.sharh = newMelkDetail.sharh
                    existingMelkDetail.aslKopy = Int16(newMelkDetail.aslKopy)
                    existingMelkDetail.kamelNages = Int16(newMelkDetail.kamelNages)
                    existingMelkDetail.tozihat = newMelkDetail.tozihat
                    existingMelkDetail.readPermission = newMelkDetail.readPermission
                    existingMelkDetail.updatePermission = newMelkDetail.updatePermission
                    existingMelkDetail.deletePermission = newMelkDetail.deletePermission
                    existingMelkDetail.creatorName = newMelkDetail.creatorName
                    existingMelkDetail.lastModifierName = newMelkDetail.lastModifierName
                    existingMelkDetail.noskheh = Int16(newMelkDetail.noskheh)
                    existingMelkDetail.germez = newMelkDetail.germez
                    existingMelkDetail.deleterName = newMelkDetail.deleterName
                    //existingMelkDetail.deletionTime = newMelkDetail.deletionTime
                    existingMelkDetail.melkDetailAdminConfirmStatus = Int16(newMelkDetail.melkDetailAdminConfirmStatus)
                    existingMelkDetail.melkDetailReviewConfirmStatus = Int16(newMelkDetail.melkDetailReviewConfirmStatus)
                    //existingMelkDetail.creationTime = newMelkDetail.creationTime
                    //existingMelkDetail.creatorId = newMelkDetail.creatorId
                    // Update other properties of MelkDetailEntity here
                } else {
                    let newMelkDetailEntity = MelkDetailEntity(context: context)
                    newMelkDetailEntity.melkId = Int64(newMelkDetail.id)
                    newMelkDetailEntity.parvandeh = Int16(newMelkDetail.parvandeh)
                    newMelkDetailEntity.radif = Int16(newMelkDetail.radif)
                    newMelkDetailEntity.radif2 = Int16(newMelkDetail.radif2 ?? 0)
                    //newMelkDetailEntity.tarikh = newMelkDetail.tarikh
                    newMelkDetailEntity.sharh = newMelkDetail.sharh
                    newMelkDetailEntity.aslKopy = Int16(newMelkDetail.aslKopy)
                    newMelkDetailEntity.kamelNages = Int16(newMelkDetail.kamelNages)
                    newMelkDetailEntity.tozihat = newMelkDetail.tozihat
                    newMelkDetailEntity.readPermission = newMelkDetail.readPermission
                    newMelkDetailEntity.updatePermission = newMelkDetail.updatePermission
                    newMelkDetailEntity.deletePermission = newMelkDetail.deletePermission
                    newMelkDetailEntity.creatorName = newMelkDetail.creatorName
                    newMelkDetailEntity.lastModifierName = newMelkDetail.lastModifierName
                    newMelkDetailEntity.noskheh = Int16(newMelkDetail.noskheh)
                    newMelkDetailEntity.germez = newMelkDetail.germez
                    newMelkDetailEntity.deleterName = newMelkDetail.deleterName
                    //newMelkDetailEntity.deletionTime = newMelkDetail.deletionTime
                    newMelkDetailEntity.melkDetailAdminConfirmStatus = Int16(newMelkDetail.melkDetailAdminConfirmStatus)
                    newMelkDetailEntity.melkDetailReviewConfirmStatus = Int16(newMelkDetail.melkDetailReviewConfirmStatus)
                    //newMelkDetailEntity.creationTime = newMelkDetail.creationTime
                    //newMelkDetailEntity.creatorId = newMelkDetail.creatorId
                    // Set other properties of MelkDetailEntity here
                }
            } catch {
                print("Error updating MelkDetailEntities in Core Data: \(error)")
            }
        }
        
        do {
            try context.save()
            print("MelkDetailEntities updated in Core Data")
        } catch {
            print("Error saving MelkDetailEntities data to Core Data: \(error)")
        }
    }
}
func getMelkDetailAttachmentsData(melkId: Int, completion: @escaping ([MelkDetailAttachmentItem]?, Error?) -> Void) {
    // Fetch data from the API
    fetchMelkDetailAttachmentsFromAPI(melkId: melkId, maxResultCount: 1, skipCount: 0) { melkDetailAttachment, error in
        if let error = error {
            print("Error fetching melkDetailAttachments data from API: \(error)")
            return
        }
        
        if let melkDetailAttachment = melkDetailAttachment {
            fetchMelkDetailAttachmentsFromAPI(melkId: melkId, maxResultCount: melkDetailAttachment.totalCount, skipCount: 0) { melkDetailAttachmentResponse, error in
                if let error = error {
                    print("Error fetching data from API: \(error)")
                    return
                }
                
                if let melkDetailAttachmentResponse = melkDetailAttachmentResponse {
                    
                    
                    mainQueue.async {
                        updateMelkDetailAttachmentsInCoreData(with: melkDetailAttachmentResponse.items)
                    }
                    
                    completion(melkDetailAttachmentResponse.items, nil)
                }
            }
        }
    }
}

func fetchMelkDetailAttachmentsFromAPI(melkId: Int, maxResultCount: Int, skipCount: Int, completion: @escaping (MelkDetailAttachmentResponse?, Error?) -> Void) {
    DispatchQueue.global(qos: .background).async {
        let urlString = "\(BASE_URL)/api/app/melk-detail-attachment/by-id?Id=\(melkId)&SkipCount=\(skipCount)&MaxResultCount=\(maxResultCount)"
        print(urlString)
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request = addAccessTokenToHeader(request: request)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print(String(data: data, encoding: .utf8) as Any)
                completion(nil, NetworkError.invalidResponse)
                return
            }
            
            do {
                let melkDetailAttachmentResponse = try JSONDecoder().decode(MelkDetailAttachmentResponse.self, from: data)
                completion(melkDetailAttachmentResponse, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
}

func getMelkDetailAttachmentsData(completion: @escaping ([MelkDetailAttachmentItem]?, Error?) -> Void) {
    // Fetch data from the API
    fetchMelkDetailAttachmentsFromAPI(maxResultCount: 1, skipCount: 0) { melkDetailAttachment, error in
        if let error = error {
            print("Error fetching melkDetailAttachments data from API: \(error)")
            return
        }
        
        if let melkDetailAttachment = melkDetailAttachment {
            
            if melkDetailAttachment.totalCount > 1000 {
                var totalPages = melkDetailAttachment.totalCount / 1000;
                if melkDetailAttachment.totalCount % 1000 > 0 {
                    totalPages += 1
                }
                for i in 0...totalPages {
                    
                    fetchMelkDetailAttachmentsFromAPI(maxResultCount: 1000, skipCount: i*1000) { melkDetailAttachmentResponse, error in
                        if let error = error {
                            print("Error fetching data from API: \(error)")
                            return
                        }
                        
                        if let melkDetailAttachmentResponse = melkDetailAttachmentResponse {
                            
                            
                            mainQueue.async {
                                updateMelkDetailAttachmentsInCoreData(with: melkDetailAttachmentResponse.items)
                            }
                            
                            completion(melkDetailAttachmentResponse.items, nil)
                        }
                    }
                    
                    
                    
                }
            }
            else {
                
                fetchMelkDetailAttachmentsFromAPI(maxResultCount: melkDetailAttachment.totalCount, skipCount: 0) { melkDetailAttachmentResponse, error in
                    if let error = error {
                        print("Error fetching data from API: \(error)")
                        return
                    }
                    
                    if let melkDetailAttachmentResponse = melkDetailAttachmentResponse {
                        
                        
                        mainQueue.async {
                            updateMelkDetailAttachmentsInCoreData(with: melkDetailAttachmentResponse.items)
                        }
                        
                        completion(melkDetailAttachmentResponse.items, nil)
                    }
                }
                
            }
        }
    }
}

func fetchMelkDetailAttachmentsFromAPI(maxResultCount: Int, skipCount: Int, completion: @escaping (MelkDetailAttachmentResponse?, Error?) -> Void) {
    DispatchQueue.global(qos: .background).async {
        let urlString = "\(BASE_URL)/api/app/melk-detail-attachment/?SkipCount=\(skipCount)&MaxResultCount=\(maxResultCount)"
        print(urlString)
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request = addAccessTokenToHeader(request: request)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print(String(data: data, encoding: .utf8) as Any)
                completion(nil, NetworkError.invalidResponse)
                return
            }
            
            do {
                let melkDetailAttachmentResponse = try JSONDecoder().decode(MelkDetailAttachmentResponse.self, from: data)
                completion(melkDetailAttachmentResponse, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
}

func updateMelkDetailAttachmentsInCoreData(with newAttachments: [MelkDetailAttachmentItem]) {
    context.perform {
        for newAttachment in newAttachments {
            let fetchRequest: NSFetchRequest<MelkDetailAttachmentEntity> = MelkDetailAttachmentEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "attachId == %@", newAttachment.id)
            
            do {
                let existingAttachments = try context.fetch(fetchRequest)
                if let existingAttachment = existingAttachments.first {
                    existingAttachment.melkDetailId = Int16(newAttachment.melkDetailId)
                    existingAttachment.containerFilePath = newAttachment.containerFilePath
                    existingAttachment.fileName = newAttachment.fileName
                    existingAttachment.fileExtension = newAttachment.fileExtension
                    existingAttachment.description1 = newAttachment.description
                    existingAttachment.creatorName = newAttachment.creatorName
                    //existingAttachment.deleterId = newAttachment.deleterId
                    //existingAttachment.deletionTime = newAttachment.deletionTime
                    //existingAttachment.lastModificationTime = newAttachment.lastModificationTime
                    //existingAttachment.lastModifierId = newAttachment.lastModifierId
                    //existingAttachment.creationTime = newAttachment.creationTime
                    //existingAttachment.creatorId = newAttachment.creatorId
                    // Update other properties of MelkDetailAttachmentEntity here
                } else {
                    let newAttachmentEntity = MelkDetailAttachmentEntity(context: context)
                    newAttachmentEntity.attachId = newAttachment.id
                    newAttachmentEntity.melkDetailId = Int16(newAttachment.melkDetailId)
                    newAttachmentEntity.containerFilePath = newAttachment.containerFilePath
                    newAttachmentEntity.fileName = newAttachment.fileName
                    newAttachmentEntity.fileExtension = newAttachment.fileExtension
                    newAttachmentEntity.description1 = newAttachment.description
                    newAttachmentEntity.creatorName = newAttachment.creatorName
                    //newAttachmentEntity.deleterId = newAttachment.deleterId
                    //newAttachmentEntity.deletionTime = newAttachment.deletionTime
                    //newAttachmentEntity.lastModificationTime = newAttachment.lastModificationTime
                    //newAttachmentEntity.lastModifierId = newAttachment.lastModifierId
                    //newAttachmentEntity.creationTime = newAttachment.creationTime
                    //newAttachmentEntity.creatorId = newAttachment.creatorId
                    // Set other properties of MelkDetailAttachmentEntity here
                }
            } catch {
                print("Error updating MelkDetailAttachmentEntities in Core Data: \(error)")
            }
        }
        
        do {
            try context.save()
            print("MelkDetailAttachmentEntities updated in Core Data")
        } catch {
            print("Error saving MelkDetailAttachmentEntities data to Core Data: \(error)")
        }
    }
}

private func addAccessTokenToHeader(request: URLRequest) -> URLRequest {
    guard let user = currentUser else {
        return request
    }

    var mutableRequest = request
    mutableRequest.addValue("Bearer \(user.accessToken)", forHTTPHeaderField: "Authorization")
    return mutableRequest
}

func getMelkDetailCount(parvandeh: Int) -> Int64 {
    let fetchRequest: NSFetchRequest<MelkDetailEntity> = MelkDetailEntity.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "parvandeh == %d", parvandeh)
    do {
        let count = try context.count(for: fetchRequest)
        return Int64(count)
    } catch let error as NSError {
        print("Error: \(error.localizedDescription)")
    }
    return 0
}

func getMelkDetailAttachmentCount(melkDetailId: Int) -> Int64 {
    let fetchRequest: NSFetchRequest<MelkDetailAttachmentEntity> = MelkDetailAttachmentEntity.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "melkDetailId == %d", melkDetailId)
    do {
        let count = try context.count(for: fetchRequest)
        return Int64(count)
    } catch let error as NSError {
        print("Error: \(error.localizedDescription)")
    }
    return 0
}

func getMelkDetailAttachmentCount() -> Int64 {
    let fetchRequest: NSFetchRequest<MelkDetailAttachmentEntity> = MelkDetailAttachmentEntity.fetchRequest()
    //fetchRequest.predicate = NSPredicate(format: "melkDetailId == %d", melkDetailId)
    do {
        let count = try context.count(for: fetchRequest)
        return Int64(count)
    } catch let error as NSError {
        print("Error: \(error.localizedDescription)")
    }
    return 0
}
