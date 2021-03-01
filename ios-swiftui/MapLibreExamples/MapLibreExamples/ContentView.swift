import SwiftUI

struct ContentView: View {
    var body: some View {
        MainView()
    }
}

struct MainView: View {
    let samples = sdkSamples
    var body: some View {
        NavigationView {
            List(samples) { sample in
              NavigationLink(destination: sample.controller) {
                    Text(sample.title)
                 }
            }
            .navigationBarTitle("SDK Samples")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
