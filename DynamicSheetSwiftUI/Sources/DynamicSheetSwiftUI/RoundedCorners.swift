//
//  File.swift
//  
//
//  Created by Mohammed Owais on 17/04/24.
//

import SwiftUI


struct RoundedCorners: Shape {
    let corners: UIRectCorner
    let radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
 

extension View {
    func roundedCorner(_ radius: CGFloat, corners: UIRectCorner)-> some View {
        clipShape(RoundedCorners(corners: corners, radius: radius))
    }
}
