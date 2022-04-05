//
//  HomeViewModel.swift
//  NasaDemo
//
//  Created by Admin on 22/03/22.
//  

import Foundation

class HomeViewModel
{
    var date: String?
    var title: String?
    var explanation: String?
    var url: String?
    var media_type: Constants.MediaType?
    let cache = NSCache<NSString, NasaResponse>()
    var queryDate : NSString?
    
    
    //NASA Astronomy APOD API Call
    func callApodApi(queryDate: Date, completion : @escaping (_ isSuccess: Bool,_ error:String?) -> Void) {
        
        
        self.updateQueryDate(queryDate: queryDate)
        guard let queryDate = self.queryDate else {
            return
        }
        let nasaRequest = NasaRequest(date: queryDate as String)
        let nasaResource = NasaResource()
        nasaResource.getNasaApod(nasaRequest: nasaRequest) { [weak self] (nasaApodApiResponse,error) in
            
            if(error == nil && nasaApodApiResponse != nil) {
                
                self?.updateResponseForDataGet(nasaApodApiResponse!)
                self?.cache.setObject(nasaApodApiResponse!, forKey: Constants.CachedResponseKey as NSString)
                _ = completion(true,nil)
                
            } else {
                
                if let cachedResponse = self?.cache.object(forKey: Constants.CachedResponseKey as NSString)  {
                    // Return Last API Cached Response
                    self?.updateResponseForDataGet(cachedResponse)
                    _ = completion(true,nil)
                }
                _ = completion(false,error)
            }
        }
    }
    
    private func updateQueryDate(queryDate: Date) {
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = Constants.DateFormatForApod
         let dateString = dateFormatter.string(from: queryDate)
         self.queryDate = dateString as NSString
     }
    
    private func updateResponseForDataGet(_ nasaApiResponse: NasaResponse) {
        
        self.date = nasaApiResponse.date
        self.title = nasaApiResponse.title
        self.explanation = nasaApiResponse.explanation
        self.url = nasaApiResponse.url
        if(nasaApiResponse.media_type == Constants.MediaTypeImage) {
            self.media_type = .image
        }else {
            self.media_type = .video
        }
    }
}


