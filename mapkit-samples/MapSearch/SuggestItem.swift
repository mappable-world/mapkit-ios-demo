//
//  SuggestItem.swift
//  MapSearch
//
//  Created by Daniil Pustotin on 14.08.2023.
//

import MappableMobile

struct SuggestItem {
    let title: MMKSpannableString
    let subtitle: MMKSpannableString?
    let onClick: () -> Void
}
