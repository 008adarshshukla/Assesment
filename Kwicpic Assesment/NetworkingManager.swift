//
//  NetworkingManager.swift
//  Kwicpic Assesment
//
//  Created by Adarsh Shukla on 22/01/23.
//

import SwiftUI
import UIKit
import RealmSwift

class NetworkingManager: ObservableObject {
    
    @Published var users: Users = Users(users: [])
    @Published var retunedUsers: [AutoDownloadList] = []
    @Published var imageInfo: [ImageInfo] = []
    
    
    func getAPIData() {
        let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYzNDA1ZGViMWQzM2JlZjNlYjUyZGM3ZCIsImRldmljZUlkIjoiMTY3NDMxNTAyNTg5NiIsImlhdCI6MTY3NDMxNTAyNiwiZXhwIjoxNzA1ODUxMDI2fQ.VWVEMRq8dlhrpRXauTfp-8_iusCQUWhwlVbu_Z0KsjE"
        
        let url = URL(string: "https://api-dev.kwikpic.in/api/app/user/auto-download-list")!
        let headers = ["Authorization": "Bearer \(token)"]
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        
        print("initiating get request for users.")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                // handle error here
                print("error occurred while getting the users from api -- get Request")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            } else {
                self.parseJSONToUserData(data: data)
            }
        }
        task.resume()
    }
    
    func parseJSONToUserData(data: Data) {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(DataModel.self, from: data)
            self.users = decodedData.data
            print("Obtained users from get request.")
            print("users are -")
            print(self.users)
            print("Starting to update to realm database in AutoDownloadList table.")
            updateToDatabase()
            print("Initiating fetching users from AutoDownloadList in realm database.")
            getFromDatabase()
        } catch {
            print(error)
        }
    }
    
    func updateToDatabase() {
        do {
            let realm = try Realm()
            for user in self.users.users {
                let newUser = AutoDownloadList(value: ["_id": user._id,"name": user.name, "countryCode": user.countryCode, "phoneNumber": user.phoneNumber, "email": user.email ?? "", "avatar": user.avatar, "beforeTStamp": "2022-08-31T07:52:48.614Z", "afterTStamp": "2022-08-31T07:52:48.614Z"])
                try realm.write({
                    realm.add(newUser, update: .all)
                })
            }
            print("Written to AutoDownloadList table successfully.")
        } catch {
            print(error)
        }
    }
    
    func getFromDatabase() {
        do {
            let realm = try Realm()
            let returnedData = realm.objects(AutoDownloadList.self)
            for data in returnedData {
                self.retunedUsers.append(data)
            }
            print("Obtained results from autoDownloadList successfully")
            print("retuned users are -")
            print(self.retunedUsers)
            
            for user in self.retunedUsers {
                print("Initiating Post fetch of images for user  - \(user._id)")
                //print(user)
                self.makePostAPIFetch(for: user)
            }
        } catch {
            print(error)
        }
        
    }
    
    
    func makePostAPIFetch(for user: AutoDownloadList) {
        let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYzNDA1ZGViMWQzM2JlZjNlYjUyZGM3ZCIsImRldmljZUlkIjoiMTY3NDMxNTAyNTg5NiIsImlhdCI6MTY3NDMxNTAyNiwiZXhwIjoxNzA1ODUxMDI2fQ.VWVEMRq8dlhrpRXauTfp-8_iusCQUWhwlVbu_Z0KsjE"
        let headers = ["Authorization": "Bearer \(token)"]
        let session = URLSession.shared
        let url = "https://api-dev.kwikpic.in/api/app/user/pics"
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        request.allHTTPHeaderFields = headers
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        var params :[String: Any]
        params = ["date" : user.beforeTStamp, "type" : "LT", "userId": user._id]
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
            let task = session.dataTask(with: request as URLRequest as URLRequest, completionHandler: {(data, response, error) in
                if let response = response {
                    let nsHTTPResponse = response as! HTTPURLResponse
                    _ = nsHTTPResponse.statusCode
                }
                if let error = error {
                    print ("\(error)")
                }
                if let data = data {
                    self.parseJSONToImageUrls(data: data, user: user)
                }
            })
            task.resume()
        }catch _ {
            print ("Oops something happened buddy")
        }
    }
    
    func parseJSONToImageUrls(data: Data, user: AutoDownloadList) {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(ImageDataModel.self, from: data)
            print("Obtained Post fetch of images for user  - \(user._id)")
            self.imageInfo = []
            for imageInfo in decodedData.data.pics {
                self.imageInfo.append(imageInfo)
            }
            if self.imageInfo.isEmpty {
                print("No image urls found")
            }
            else {
                print(self.imageInfo)
                for info in imageInfo {
                    print("staring to download the image")
                    downloadImagesToPhotos(imageInfo: info, user: user)
                }
            }
            
        } catch {
            print(error)
        }
    }
    
    func downloadImagesToPhotos(imageInfo: ImageInfo, user: AutoDownloadList) {
        let newUrlString = imageInfo.url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        guard let url = URL(string: newUrlString) else {
            print("Could not convert url string to url")
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            let image = UIImage(data: data) ?? UIImage()
            print("Image downloaded successfully")
            let imageSaver = ImageSaver()
            imageSaver.writeToPhotoAlbum(image: image)
        }
        task.resume()
        
        do {
            let realm = try Realm()
            print("starting to save image url in DownloadedImages table")
            let newDownloadedImage = DownloadedImages(value: ["_id": imageInfo._id, "url": imageInfo.url])
            try realm.write {
                realm.add(newDownloadedImage, update: .all)
            }
            print("Saved image url in DownloadedImages table")
            
        } catch {
            print(error)
        }
        
        
        
        do {
            let realm = try Realm()
            print("Starting to update beforeTStamp for user - \(user._id)")
            let newUser = AutoDownloadList(value: ["_id": user._id,"name": user.name, "countryCode": user.countryCode, "phoneNumber": user.phoneNumber, "email": user.email, "avatar": user.avatar, "beforeTStamp": imageInfo.uploadedAt, "afterTStamp": "2022-08-31T07:52:48.614Z"])
            try realm.write({
                realm.add(newUser, update: .modified)
                print("beforeTStamp updated to the value - \(imageInfo.uploadedAt)")
            })
            
        } catch {
            print(error)
        }
        
    }
    
}

class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Save to photos Successfully!")
    }
}



