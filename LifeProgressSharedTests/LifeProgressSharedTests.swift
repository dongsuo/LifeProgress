//
//  LifeProgressSharedTests.swift
//  LifeProgressSharedTests
//
//  Created by Shaw on 1/3/25.
//

import Testing
@testable import LifeProgressShared

struct EventThemeMatchTests {

    @Test func matchesEnglishTitles() {
        #expect(EventTheme.match(title: "My Wedding Day") == .wedding)
        #expect(EventTheme.match(title: "weddings in July") == .wedding)
        #expect(EventTheme.match(title: "GRADUATION") == .graduation)
        #expect(EventTheme.match(title: "Got promoted!") == .promotion)
        #expect(EventTheme.match(title: "Bought our first house") == .house)
        #expect(EventTheme.match(title: "Trip to Japan") == .travel)
        #expect(EventTheme.match(title: "Adopted a cat") == .pet)
        #expect(EventTheme.match(title: "New job at Cognition") == .firstJob)
    }

    @Test func matchesChineseTitles() {
        #expect(EventTheme.match(title: "毕业啦") == .graduation)
        #expect(EventTheme.match(title: "生了宝宝") == .baby)
        #expect(EventTheme.match(title: "我们结婚了") == .wedding)
        #expect(EventTheme.match(title: "日本旅行") == .travel)
    }

    @Test func matchesMixedLanguageTitles() {
        #expect(EventTheme.match(title: "我们的 wedding") == .wedding)
        #expect(EventTheme.match(title: "Baby 满月") == .baby)
    }

    @Test func avoidsFalsePositives() {
        #expect(EventTheme.match(title: "category meeting") == nil)
        #expect(EventTheme.match(title: "scar tissue") == nil)
        #expect(EventTheme.match(title: "career talk") == nil)
        #expect(EventTheme.match(title: "") == nil)
        #expect(EventTheme.match(title: "lunch with mom") == nil)
    }

    @Test func respectsPriorityOrder() {
        #expect(EventTheme.match(title: "engagement and wedding planning") == .engagement)
    }
}
