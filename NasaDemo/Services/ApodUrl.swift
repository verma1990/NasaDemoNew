//
//  URLS.swift
//  NasaApod
//
//  Created by Vishal on 9/1/2022.
//  All Required API Enpoints can be configured here

import Foundation

struct ApiEndpoints {
    
    let apodURL: String
    
    init(date:String) {

        self.apodURL = "https://api.nasa.gov/planetary/apod?api_key=7aQUfnPcTf2KosdnTnIiDwZb2AClZ8qf23MZA2Hv"
    }
    
}
