//
//  CustomPhotoAlbum.swift
//  BitKeys
//
//  Created by Peter on 6/30/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//
import Photos

class CustomPhotoAlbum: NSObject {
    static let albumName = "BitSense"
    static let shared = CustomPhotoAlbum()
    
    private var assetCollection: PHAssetCollection!
    
    private override init() {
        super.init()
        
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
    }
    
    private func checkAuthorizationWithHandler(completion: @escaping ((_ success: Bool) -> Void)) {
        if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) in
                self.checkAuthorizationWithHandler(completion: completion)
            })
        }
        else if PHPhotoLibrary.authorizationStatus() == .authorized {
            self.createAlbumIfNeeded { (success) in
                if success {
                    completion(true)
                } else {
                    completion(false)
                }
                
            }
            
        }
        else {
            completion(false)
        }
    }
    
    private func createAlbumIfNeeded(completion: @escaping ((_ success: Bool) -> Void)) {
        if let assetCollection = fetchAssetCollectionForAlbum() {
            // Album already exists
            self.assetCollection = assetCollection
            completion(true)
        } else {
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: CustomPhotoAlbum.albumName)   // create an asset collection with the album name
            }) { success, error in
                if success {
                    self.assetCollection = self.fetchAssetCollectionForAlbum()
                    completion(true)
                } else {
                    // Unable to create album
                    completion(false)
                }
            }
        }
    }
    
    private func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", CustomPhotoAlbum.albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let _: AnyObject = collection.firstObject {
            return collection.firstObject
        }
        return nil
    }
    
    func save(image: UIImage) {
        self.checkAuthorizationWithHandler { (success) in
            if success, self.assetCollection != nil {
                PHPhotoLibrary.shared().performChanges({
                    let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
                    if let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection) {
                        let enumeration: NSArray = [assetPlaceHolder!]
                        albumChangeRequest.addAssets(enumeration)
                    }
                    
                }, completionHandler: { (success, error) in
                    if success {
                        print("Successfully saved image to Camera Roll.")
                    } else {
                        print("Error writing to image library: \(error!.localizedDescription)")
                    }
                })
                
            }
        }
    }
    
    /*func saveMovieToLibrary(movieURL: URL) {
        
        self.checkAuthorizationWithHandler { (success) in
            if success, self.assetCollection != nil {
                
                PHPhotoLibrary.shared().performChanges({
                    
                    if let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: movieURL) {
                        let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
                        if let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection) {
                            let enumeration: NSArray = [assetPlaceHolder!]
                            albumChangeRequest.addAssets(enumeration)
                        }
                        
                    }
                    
                }, completionHandler:  { (success, error) in
                    if success {
                        print("Successfully saved video to Camera Roll.")
                    } else {
                        print("Error writing to movie library: \(error!.localizedDescription)")
                    }
                })
                
                
            }
        }
        
    }*/
}
/*
import Photos

class CustomPhotoAlbum: NSObject {
    
    
    
    static let albumName = "BitSense"
    static let shared = CustomPhotoAlbum()
    
    private var assetCollection: PHAssetCollection!
    
    private override init() {
        super.init()
        
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
    }
    
    private func checkAuthorizationWithHandler(completion: @escaping ((_ success: Bool) -> Void)) {
        if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) in
                self.checkAuthorizationWithHandler(completion: completion)
            })
        }
        else if PHPhotoLibrary.authorizationStatus() == .authorized {
            self.createAlbumIfNeeded()
            completion(true)
        }
        else {
            completion(false)
        }
    }
    
    private func createAlbumIfNeeded() {
        if let assetCollection = fetchAssetCollectionForAlbum() {
            // Album already exists
            self.assetCollection = assetCollection
        } else {
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: CustomPhotoAlbum.albumName)   // create an asset collection with the album name
            }) { success, error in
                if success {
                    self.assetCollection = self.fetchAssetCollectionForAlbum()
                } else {
                    // Unable to create album
                }
            }
        }
    }
    
    private func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", CustomPhotoAlbum.albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let _: AnyObject = collection.firstObject {
            return collection.firstObject
        }
        return nil
    }
    
    func save(image: UIImage) {
        self.checkAuthorizationWithHandler { (success) in
            if success, self.assetCollection != nil {
                PHPhotoLibrary.shared().performChanges({
                    let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
                    let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
                    let enumeration: NSArray = [assetPlaceHolder!]
                    albumChangeRequest!.addAssets(enumeration)
                    
                }, completionHandler: nil)
            }
        }
    }
}

/*import Foundation
import Photos


/*class CustomPhotoAlbum: NSObject {
    static let albumName = "BitSense"
    static let sharedInstance = CustomPhotoAlbum()
    
    var assetCollection: PHAssetCollection!
    
    override init() {
        super.init()
        
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
        
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
                ()
            })
        }
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            self.createAlbum()
        } else {
            PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
        }
    }
    
    func requestAuthorizationHandler(status: PHAuthorizationStatus) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            // ideally this ensures the creation of the photo album even if authorization wasn't prompted till after init was done
            print("trying again to create the album")
            self.createAlbum()
        } else {
            print("should really prompt the user to let them know it's failed")
            displayAlert(viewController: SecuritySettingsViewController(), title: "Error", message: "Unable to save the images")
        }
    }
    
    func createAlbum() {
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: CustomPhotoAlbum.albumName)   // create an asset collection with the album name
        }) { success, error in
            if success {
                self.assetCollection = self.fetchAssetCollectionForAlbum()
            } else {
                print("error \(String(describing: error))")
            }
        }
    }
    
    func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", CustomPhotoAlbum.albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let _: AnyObject = collection.firstObject {
            return collection.firstObject
        }
        return nil
    }
    
    func save(image: UIImage) {
        if assetCollection == nil {
            return                          // if there was an error upstream, skip the save
        }
        
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
            let enumeration: NSArray = [assetPlaceHolder!]
            albumChangeRequest!.addAssets(enumeration)
            
        }, completionHandler: nil)
    }
}*/

class CustomPhotoAlbum: NSObject {
    static let albumName = "Name of Custom Album"
    static let sharedInstance = CustomPhotoAlbum()
    
    var assetCollection: PHAssetCollection!
    
    override init() {
        super.init()
        
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
        
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
                status
            })
        }
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            self.createAlbum()
        } else {
            PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
        }
    }
    
    func requestAuthorizationHandler(status: PHAuthorizationStatus) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            // ideally this ensures the creation of the photo album even if authorization wasn't prompted till after init was done
            print("trying again to create the album")
            self.createAlbum()
        } else {
            print("should really prompt the user to let them know it's failed")
            displayAlert(viewController: SecuritySettingsViewController(), title: "Error", message: "Unable to save the images")
        }
    }
    
    func createAlbum() {
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: CustomPhotoAlbum.albumName)   // create an asset collection with the album name
        }) { success, error in
            if success {
                self.assetCollection = self.fetchAssetCollectionForAlbum()
            } else {
                print("error \(String(describing: error))")
                displayAlert(viewController: SecuritySettingsViewController(), title: "Error", message: "\(String(describing: error))")
            }
        }
    }
    
    func fetchAssetCollectionForAlbum() -> PHAssetCollection! {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", CustomPhotoAlbum.albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let _: AnyObject = collection.firstObject {
            return collection.firstObject as! PHAssetCollection
        }
        return nil
    }
    
    func saveImage(image: UIImage, metadata: NSDictionary) {
        if assetCollection == nil {
            return                          // if there was an error upstream, skip the save
        }
        
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
            let enumeration: NSArray = [assetPlaceHolder!]
            albumChangeRequest!.addAssets(enumeration)
        }, completionHandler: nil)
    }
}*/
*/
