//
//  WidgetBundle.swift
//  APP_GYM
//
//  Bundle de widgets para la app
//  NOTA: Este archivo debe estar en un Widget Extension target separado
//  El @main solo debe estar en el target de widgets, no en el target principal
//

import WidgetKit
import SwiftUI

// @main - Solo debe estar en el Widget Extension target, no aquí
// Si creas un Widget Extension, mueve este archivo allí y descomenta @main
struct APP_GYMWidgets: WidgetBundle {
    var body: some Widget {
        WorkoutStreakWidget()
        NextWorkoutWidget()
    }
}

