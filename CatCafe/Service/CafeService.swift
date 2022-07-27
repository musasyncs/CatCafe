//
//  CafeService.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/17.
//

import FirebaseFirestore

struct CafeService {
    
    static func fetchAllCafes(completion: @escaping([Cafe]) -> Void) {
        firebaseReference(.cafes).getDocuments { snapshot, error in
            if error != nil { return }
            guard let snapshot = snapshot else { return }
            let cafes = snapshot.documents.map({
                Cafe(dic: $0.data())
            })
            completion(cafes)
        }
    }
        
}
