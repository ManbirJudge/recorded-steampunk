package com.example.recordedsteampunk

import android.content.Context
import android.widget.Toast

class Utils {
    companion object {
        fun toastIt(text: String, context: Context) {
            Toast.makeText(context, text, Toast.LENGTH_SHORT).show()
        }
    }
}