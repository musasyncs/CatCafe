//
//  LocalStorage.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/19.
//

import Foundation

class LocalStorage {
    static let shared = LocalStorage()
        
    var hasLogedIn: Bool {
        get {
            UserDefaults.standard.bool(forKey: CCConstant.LocalStorageKey.hasLogedIn)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: CCConstant.LocalStorageKey.hasLogedIn)
        }
    }
    
    func saveUid(_ uid: String?) {
        UserDefaults.standard.set(uid, forKey: CCConstant.LocalStorageKey.userIdKey)
    }

    func getUid() -> String? {
        return UserDefaults.standard.value(forKey: CCConstant.LocalStorageKey.userIdKey) as? String
    }
    
    func clearUid() {
        UserDefaults.standard.set(nil, forKey: CCConstant.LocalStorageKey.userIdKey)
    }
    
}
