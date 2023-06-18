import Foundation
import UIKit
import XMLCoder
import CoreLocation

struct GourmetItem: Identifiable {
    let id: UUID
    let name: String
    let link: URL
    let image: URL
    let address: String
    let open: String
    let close: String
    let mobileAccess: String
}

class GourmetData: ObservableObject {
    
    struct ResultXML: Codable {
        let results_available: Int
        let results_returned: Int
        let results_start: Int
        let shop: [Shop]
        
        struct Shop: Codable {
            let id: String
            let name: String
            let logo_image: String
            let address: String
            let mobile_access: String
            let urls: Urls
            let open: String
            let close: String
            
            struct Urls: Codable {
                let pc: String
            }
        }
    }
    
    @Published var gourmetList: [GourmetItem] = []
    
    func searchGourmet(keyword: String) async {
        guard let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        guard let req_url = URL(string: "http://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key=be66f754602a1267&name=\(keyword_encode)") else{
            return
        }
        
        do {
            let (data , _) = try await URLSession.shared.data(from: req_url)
            let decoder = XMLDecoder()
            let xml = try decoder.decode(ResultXML.self, from: data)
            
            DispatchQueue.main.async {
                self.gourmetList.removeAll()
            }
            
            for shop in xml.shop {
                guard let link = URL(string: shop.urls.pc),
                      let image = URL(string: shop.logo_image)
                else {
                    continue
                }
                let gourmet = GourmetItem(id: UUID(), name: shop.name, link: link, image: image, address: shop.address, open: shop.open, close: shop.close, mobileAccess: shop.mobile_access)
                
                DispatchQueue.main.async {
                    self.gourmetList.append(gourmet)
                }
            }
        } catch {
            print("エラーが出ました\(error)")
        }
    }
    
    func searchGourmetByLocation(location: CLLocation, range: Int) async {
        guard let req_url = URL(string: "http://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key=be66f754602a1267&lat=\(location.coordinate.latitude)&lng=\(location.coordinate.longitude)&range=\(range)") else{
            return
        }
        
        do {
            let (data , _) = try await URLSession.shared.data(from: req_url)
            let decoder = XMLDecoder()
            let xml = try decoder.decode(ResultXML.self, from: data)
            
            DispatchQueue.main.async {
                self.gourmetList.removeAll()
            }
            
            for shop in xml.shop {
                guard let link = URL(string: shop.urls.pc),
                      let image = URL(string: shop.logo_image)
                else {
                    continue
                }
                let gourmet = GourmetItem(id: UUID(), name: shop.name, link: link, image: image, address: shop.address, open: shop.open, close: shop.close, mobileAccess: shop.mobile_access)
                
                DispatchQueue.main.async {
                    self.gourmetList.append(gourmet)
                }
            }
        } catch {
            print("エラーが出ました\(error)")
        }
    }
}
                                          
