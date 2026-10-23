package com.navwidget.model

data class NavigationInfo(
    val distanceToNextTurn: String = "",
    val direction: String = "",
    val maneuverIcon: String = "",
    val totalTimeRemaining: String = "",
    val totalDistanceRemaining: String = "",
    val arrivalTime: String = "",
    val destination: String = "",
    val timestamp: Long = System.currentTimeMillis()
) {
    val isActive: Boolean
        get() = totalTimeRemaining.isNotEmpty()
}

enum class WidgetSize(val label: String) {
    Small("Small"), Normal("Normal"), Large("Large")
}
