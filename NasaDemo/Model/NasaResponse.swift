//
//  NasaResponse.swift
//  NasaDemo
//
//  Created by Admin on 22/03/22.
//  

class NasaResponse : Decodable {
    var date: String
    var title: String
    var explanation: String
    var url: String
    var media_type: String
    
    init(date:String,title: String,explanation: String,url: String,media_type: String) {
        
        self.date = date
        self.title = title
        self.explanation = explanation
        self.url = url
        self.media_type = media_type
    }
}
