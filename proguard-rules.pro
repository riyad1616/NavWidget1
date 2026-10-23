# NavWidget ProGuard Rules
keep class com.navwidget.model.NavigationInfo { *; }
keep class com.navwidget.service.* { *; }
keep class com.navwidget.receiver.* { *; }
keep class com.navwidget.ui.* { *; }

-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
