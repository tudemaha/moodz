import SwiftUI

struct ResponseDisplayView: View {
    let response: String
    let errorMessage: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let error = errorMessage {
                ErrorView(message: error)
            }
            
            if !response.isEmpty {
                ResponseContentView(response: response)
            }
        }
    }
}

struct ErrorView: View {
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            Text(message)
                .foregroundColor(.red)
                .font(.caption)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ResponseContentView: View {
    let response: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Response")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "doc.text")
                    .foregroundColor(.secondary)
            }
            
            ScrollView {
                Text(response)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(12)
            }
        }
    }
}
