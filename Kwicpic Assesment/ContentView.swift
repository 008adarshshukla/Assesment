//
//  ContentView.swift
//  Kwicpic Assesment
//
//  Created by Adarsh Shukla on 22/01/23.
//

import SwiftUI

struct ContentView: View {
    let myRealmQueue = DispatchQueue(label: "realmQueue", qos: .background)
    @State var vm = NetworkingManager()
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            myRealmQueue.async {
                vm.getAPIData()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
