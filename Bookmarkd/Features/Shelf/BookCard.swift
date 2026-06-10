//
//  BookCard.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 14/06/26.
//

import SwiftUI
import Kingfisher

struct BookCard: View {
    let book: Book
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.white)
                .offset(x: 4, y: -4)
            
            Rectangle()
                .stroke(.black, lineWidth: 0.3)
                .offset(x: 3, y: -3)
            
            Rectangle()
                .stroke(.black, lineWidth: 0.3)
                .offset(x: 2, y: -2)
            
            Rectangle()
                .stroke(.black, lineWidth: 0.3)
                .offset(x: 1, y: -1)
            
            KFImage(book.coverURL)
                .resizable()
                .placeholder { _ in
                    Rectangle()
                        .fill(.highlight.opacity(0.15))
                        .overlay(
                            VStack(spacing: 6) {
                                Image(systemName: "book.closed.fill")
                                    .font(.title)
                                    .foregroundStyle(.highlight.opacity(0.4))
                                Text(book.title)
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.highlight.opacity(0.6))
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 4)
                            }
                        )
                }
        }
        .aspectRatio(3/4, contentMode: .fit)
        .frame(width: 130)
        .compositingGroup()
        .shadow(radius: 8, x: 5, y: -4)
    }
}
