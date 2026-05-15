package com.example.flutter_application_ems

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews

/**
 * Widget provider per la schermata home di Android.
 * Mostra la fascia ottimale giornaliera di produzione solare.
 */
class SolarWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        private fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val prefs: SharedPreferences = context.getSharedPreferences(
                "HomeWidgetPreferences", Context.MODE_PRIVATE
            )

            val windowText = prefs.getString("window_text", "--:-- – --:--") ?: "--:-- – --:--"
            val radiationText = prefs.getString("radiation_text", "") ?: ""
            val locationText = prefs.getString("location_text", "") ?: ""

            val views = RemoteViews(context.packageName, R.layout.solar_widget)
            views.setTextViewText(R.id.widget_window, windowText)
            views.setTextViewText(R.id.widget_radiation, radiationText)
            views.setTextViewText(R.id.widget_location, locationText)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
