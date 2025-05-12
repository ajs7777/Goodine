//
//  FeatureSelectionView.swift
//  Goodine
//
//  Created by Abhijit Saha on 02/05/25.
//


import SwiftUI

struct FeatureSelectionView: View {
    @State private var customFeature = ""
    @Binding var selectedFeatures: [String]
    let premadeFeatures = ["Reservation Available", "Dine in Available", "Family Friendly", "Couple Friendly", "Takeway Available"]
    
    let columns = [GridItem(.adaptive(minimum: 100), spacing: 10)]

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                TextField("Add feature", text: $customFeature)
                    .padding(.leading)
                    .frame(maxWidth: .infinity)
                    .frame(height: 45)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .inset(by: 3)
                            .stroke(Color("mainbw"), lineWidth: 1)
                    )
                
                Button("Done") {
                    let trimmed = customFeature.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty, !selectedFeatures.contains(trimmed) else { return }
                    selectedFeatures.append(trimmed)
                    customFeature = ""
                }
                .fontWeight(.semibold)
                .foregroundStyle(Color("mainInvert"))
                .padding(10)
                .background(Color("mainbw"))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.vertical)

            let allFeatures = (selectedFeatures + premadeFeatures.filter { !selectedFeatures.contains($0) })

            WrappingHStack(items: allFeatures) { feature in
                HStack(spacing: 4) {
                    Text(feature)
                        .font(.headline)
                        .fontWeight(.semibold)
                    if selectedFeatures.contains(feature) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .onTapGesture {
                                selectedFeatures.removeAll { $0 == feature }
                            }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(selectedFeatures.contains(feature) ? Color(.systemGray3) : Color(.systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .onTapGesture {
                    toggleFeature(feature)
                }
            }
        }
    }

    func toggleFeature(_ feature: String) {
        if selectedFeatures.contains(feature) {
            selectedFeatures.removeAll { $0 == feature }
        } else {
            selectedFeatures.append(feature)
        }
    }
}

extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        Array(Set(self))
    }
}


struct WrappingHStack<Content: View>: View {
    var items: [String]
    var content: (String) -> Content

    @State private var totalHeight = CGFloat.zero

    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(items, id: \.self) { item in
                content(item)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if abs(width - d.width) > geometry.size.width {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if item == items.last {
                            width = 0 // reset at end
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { _ in
                        let result = height
                        if item == items.last {
                            height = 0 // reset at end
                        }
                        return result
                    })
            }
        }
        .background(viewHeightReader($totalHeight))
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        GeometryReader { geometry -> Color in
            DispatchQueue.main.async {
                binding.wrappedValue = geometry.size.height
            }
            return Color.clear
        }
    }
}
