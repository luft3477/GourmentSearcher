import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject var gourmetDataList = GourmetData()
    @StateObject var locationManager = LocationManager()
    @State var inputText = ""
    @State var showSafari = false
    @State var searchRange: Double = 2 // Initial value is 200m.
    
    var body: some View{
        VStack{
            TextField("キーワード", text: $inputText, prompt: Text("キーワードで検索するにはこちら"))
                .onSubmit {
                    Task{
                        await gourmetDataList.searchGourmet(keyword: inputText)
                    }
                }
                .submitLabel(.search)
                .padding()
            
            Text("検索範囲: \(Int(searchRange * 100))m")
            Slider(value: $searchRange, in: 2...100) // Slider from 200m to 10km.
                .padding()
            
            Button("現在地から検索") {
                if let location = locationManager.location {
                    print("Location: \(location)")
                    Task {
                        await gourmetDataList.searchGourmetByLocation(location: location, range: Int(searchRange))
                    }
                } else {
                    print("No location available.")
                }
            }

            .padding()
            
            List(gourmetDataList.gourmetList) { gourmet in
                
                Button(action: {
                                   showSafari.toggle()
                               }) {
                                   HStack {
                                       AsyncImage(url: gourmet.image) { image in
                                           image
                                               .resizable()
                                               .aspectRatio(contentMode: .fit)
                                               .frame(height: 60)
                                               .clipShape(RoundedRectangle(cornerRadius: 8))
                                           
                                       } placeholder: {
                                           ProgressView()
                                       }
                                       VStack(alignment: .leading) {
                                           Text(gourmet.name)
                                               .font(.headline)
                                               .foregroundColor(.primary)
                                           Text("住所: \(gourmet.address)")
                                               .font(.subheadline)
                                               .foregroundColor(.secondary)
                                           Text("営業時間: \(gourmet.open)")
                                               .font(.subheadline)
                                               .foregroundColor(.secondary)
                                       }
                                       Spacer()
                                   }
                                   .padding()
                               }
                               .sheet(isPresented: self.$showSafari, content: {
                                   SafariView(url: gourmet.link)
                                       .edgesIgnoringSafeArea(.bottom)
                               })
                           }
                           
                       }
                   }
               }

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
