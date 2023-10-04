package com.example.recordedsteampunk.adapter

import androidx.recyclerview.selection.ItemKeyProvider
import androidx.recyclerview.widget.RecyclerView

class TestRecordItemKeyProvider(private val recyclerView: RecyclerView) : ItemKeyProvider<Long>(ItemKeyProvider.SCOPE_MAPPED) {
    override fun getKey(position: Int): Long {
        return recyclerView.adapter!!.getItemId(position)
    }

    override fun getPosition(key: Long): Int {
        return recyclerView.findViewHolderForItemId(key).bindingAdapterPosition
    }
}