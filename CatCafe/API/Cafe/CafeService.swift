//
//  CafeService.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/17.
//

import Firebase

struct CafeService {
    
    static func fetchAllCafes(completion: @escaping([Cafe]) -> Void) {
        CCConstant.COLLECTION_CAFES.getDocuments { snapshot, _ in
            guard let snapshot = snapshot else { return }
            let cafes = snapshot.documents.map({
                Cafe(dic: $0.data())
            })
            completion(cafes)
        }
    }
        
}
