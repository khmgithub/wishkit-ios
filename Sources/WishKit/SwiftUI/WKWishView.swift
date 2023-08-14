//
//  SwiftUIView.swift
//  wishkit-ios
//
//  Created by Martin Lasek on 8/12/23.
//  Copyright © 2023 Martin Lasek. All rights reserved.
//

import SwiftUI

struct WKWishView: View {

    @Environment(\.colorScheme)
    var colorScheme

    private let title: String

    private let description: String

    init(title: String, description: String) {
        self.title = title
        self.description = description
    }

    var body: some View {
        HStack(spacing: 0) {
            Button(action: { print("upvoted..") }) {
                VStack(spacing: 5) {
                    Image(systemName: "arrowtriangle.up.fill")
                    Text(String(describing: 9))
                }
                .foregroundColor(textColor)
                .padding([.leading, .trailing], 20)
                .padding([.top, .bottom], 10)
                .cornerRadius(12)
            }

            VStack(spacing: 5) {
                HStack {
                    Text(title)
                        .foregroundColor(textColor)
                        .font(.system(size: 17))
                        .fontWeight(.semibold)
                    Spacer()
                }

                HStack {
                    Text(description)
                        .foregroundColor(textColor)
                        .font(.system(size: 13))
                    Spacer()
                }
            }
        }
        .padding([.top, .bottom, .trailing], 15)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(1/5), radius: 4, y: 3)
    }
}

extension WKWishView {
    var textColor: Color {
        switch colorScheme {
        case .light:

            if let color = WishKit.theme.textColor {
                return color.light
            }

            return .black
        case .dark:
            if let color = WishKit.theme.textColor {
                return color.dark
            }

            return .white
        }
    }

    var backgroundColor: Color {
        switch colorScheme {
        case .light:

            if let color = WishKit.theme.secondaryColor {
                return color.light
            }

            return PrivateTheme.elementBackgroundColor.light
        case .dark:
            if let color = WishKit.theme.secondaryColor {
                return color.dark
            }

            return PrivateTheme.elementBackgroundColor.dark
        }
    }
}

struct WKWishView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            WKWishView(
                title: "📈 Statistics of my workouts!",
                description: "Seeing a chart showing when and how much I worked out to see my progress in how much more volume I can list would be really ncie."
            ).padding()
            Spacer()
        }.background(Color.red)
    }
}
