//
//  ApodResource.swift
//  NasaDemo
//
//  Created by Admin on 22/03/22.
//  All API's resources can be configured here

import Foundation

struct NasaResource
{
    func getNasaApod(nasaRequest: NasaRequest, completion :@escaping (_ result: NasaResponse?,_ error:String?) -> Void)
    {
        let url =  "\(Constants.BaseURL)apod?api_key=\(Constants.APIKey)&date=\(nasaRequest.date)"
        
        if let apodUrl = URL(string: url) {
            
            let httpUtility = HttpUtility()
            
            httpUtility.getApiData(requestUrl: apodUrl, resultType: NasaResponse.self) { (apodApiResponse,error)  in
                _ = completion(apodApiResponse,error)
            }
        }
    }
    
}
