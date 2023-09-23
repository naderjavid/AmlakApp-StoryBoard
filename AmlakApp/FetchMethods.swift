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

func updateMelksInCoreData(with newMelkItems: [MelkItem]) {
    context.perform {
        do {
            // Create a dictionary to map existing melk IDs to melk entities
            var melkIDToMelkEntityMap = [String: MelkEntity]()
            for existingMelkEntity in try context.fetch(MelkEntity.fetchRequest()) {
                melkIDToMelkEntityMap[existingMelkEntity.melkId!] = existingMelkEntity
            }
            
            // Iterate over the new melks and update the corresponding existing melks
            for newMelkItem in newMelkItems {
                var existingMelkEntity = melkIDToMelkEntityMap[newMelkItem.id]
                
                // If the existing melk entity does not exist, create a new one
                if existingMelkEntity == nil {
                    existingMelkEntity = MelkEntity(context: context)
                    existingMelkEntity?.melkId = newMelkItem.id
                }
                
                // Update the existing melk entity with the new data
                existingMelkEntity?.parvandeh = Int16(newMelkItem.parvandeh)
                existingMelkEntity?.name = newMelkItem.name
                existingMelkEntity?.shamarehPelakSabti = newMelkItem.shamarehPelakSabti
                existingMelkEntity?.melkVaziat = Int16(newMelkItem.melkVaziat)
                existingMelkEntity?.mabnayehMalekiyyat = Int16(newMelkItem.mabnayehMalekiyyat)
                existingMelkEntity?.vaziateEntegal = Int16(newMelkItem.vaziateEntegal)
                existingMelkEntity?.tozihat = newMelkItem.tozihat
                existingMelkEntity?.shoraka = newMelkItem.shoraka
                existingMelkEntity?.readPermission = newMelkItem.readPermission
                existingMelkEntity?.updatePermission = newMelkItem.updatePermission
                existingMelkEntity?.deletePermission = newMelkItem.deletePermission
                existingMelkEntity?.creatorName = newMelkItem.creatorName
                existingMelkEntity?.lastModifierName = newMelkItem.lastModifierName
                existingMelkEntity?.melkAdminConfirmStatus = Int16(newMelkItem.melkAdminConfirmStatus)
                existingMelkEntity?.melkReviewConfirmStatus = Int16(newMelkItem.melkReviewConfirmStatus)
            }
            
            // Save the changes to Core Data
            try context.save()
        } catch {
            print("Error updating melks in Core Data: \(error)")
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
        do {
            //Create a dictionary to map existing melkDetail IDs to MelkDetail entities
            var melkDetailIDToMelkDetailEntityMap = [Int: MelkDetailEntity]()
            for existingMelkDetailEntity in try context.fetch(MelkDetailEntity.fetchRequest()) {
                melkDetailIDToMelkDetailEntityMap[Int(existingMelkDetailEntity.melkId)] = existingMelkDetailEntity
            }
            //Iterate over the new melkDetails and update the corresponding existing melkDetails
            for newMelkDetail in newMelkDetails {
                var existingMelkDetail = melkDetailIDToMelkDetailEntityMap[newMelkDetail.id]
                
                //If the existing melkDetail entity does not exist, create a new one
                if existingMelkDetail == nil {
                    existingMelkDetail = MelkDetailEntity(context: context)
                    existingMelkDetail?.melkId = Int64(newMelkDetail.id)
                }
                
                //Update the existing melkDetail entity with the new data
                existingMelkDetail?.parvandeh = Int16(newMelkDetail.parvandeh)
                existingMelkDetail?.radif = Int16(newMelkDetail.radif)
                existingMelkDetail?.radif2 = Int16(newMelkDetail.radif2 ?? 0)
                //existingMelkDetail?.tarikh = newMelkDetail.tarikh
                existingMelkDetail?.sharh = newMelkDetail.sharh
                existingMelkDetail?.aslKopy = Int16(newMelkDetail.aslKopy)
                existingMelkDetail?.kamelNages = Int16(newMelkDetail.kamelNages)
                existingMelkDetail?.tozihat = newMelkDetail.tozihat
                existingMelkDetail?.readPermission = newMelkDetail.readPermission
                existingMelkDetail?.updatePermission = newMelkDetail.updatePermission
                existingMelkDetail?.deletePermission = newMelkDetail.deletePermission
                existingMelkDetail?.creatorName = newMelkDetail.creatorName
                existingMelkDetail?.lastModifierName = newMelkDetail.lastModifierName
                existingMelkDetail?.noskheh = Int16(newMelkDetail.noskheh)
                existingMelkDetail?.germez = newMelkDetail.germez
                existingMelkDetail?.deleterName = newMelkDetail.deleterName
                //existingMelkDetail?.deletionTime = newMelkDetail.deletionTime
                existingMelkDetail?.melkDetailAdminConfirmStatus = Int16(newMelkDetail.melkDetailAdminConfirmStatus)
                existingMelkDetail?.melkDetailReviewConfirmStatus = Int16(newMelkDetail.melkDetailReviewConfirmStatus)
                //existingMelkDetail?.creationTime = newMelkDetail.creationTime
                //existingMelkDetail?.creatorId = newMelkDetail.creatorId
            }
            
            try context.save()
        }
        catch {
            print("Error updating melkDetails in Core Data: \(error)")
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
        
        do {
            
            //create a dictionary to map existing attachment IDs to attachment entities
            var melkDetailAttachmentIDToMelkDetailAttachmentEntityMap = [String:MelkDetailAttachmentEntity]()
            for existingMelkDetailAttachment in try context.fetch(MelkDetailAttachmentEntity.fetchRequest()) {
                melkDetailAttachmentIDToMelkDetailAttachmentEntityMap[existingMelkDetailAttachment.attachId!] = existingMelkDetailAttachment
            }
            
            //Iterate over the new attachments and update the corresponding existing attachments
            for newAttachment in newAttachments {
                var existingAttachment = melkDetailAttachmentIDToMelkDetailAttachmentEntityMap[newAttachment.id]
                
                //If the existing attachment does not exist, create the new one
                if existingAttachment == nil {
                    existingAttachment = MelkDetailAttachmentEntity(context: context)
                    existingAttachment?.attachId = newAttachment.id
                }
                
                //updating existing attachment entity with the new data
                existingAttachment?.melkDetailId = Int16(newAttachment.melkDetailId)
                existingAttachment?.containerFilePath = newAttachment.containerFilePath
                existingAttachment?.fileName = newAttachment.fileName
                existingAttachment?.fileExtension = newAttachment.fileExtension
                existingAttachment?.description1 = newAttachment.description
                existingAttachment?.creatorName = newAttachment.creatorName
                //existingAttachment.deleterId = newAttachment.deleterId
                //existingAttachment.deletionTime = newAttachment.deletionTime
                //existingAttachment.lastModificationTime = newAttachment.lastModificationTime
                //existingAttachment.lastModifierId = newAttachment.lastModifierId
                //existingAttachment.creationTime = newAttachment.creationTime
                //existingAttachment.creatorId = newAttachment.creatorId
                
            }
            
            //Save the changes to Core Data
            try context.save()
            print("attachments updated in Core Data")
        }
        catch {
            print("Error updating attachments in Core Data: \(error)")
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
