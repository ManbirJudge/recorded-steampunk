package com.example.recordedsteampunk.dialog

import android.app.DatePickerDialog
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.DatePicker
import androidx.appcompat.widget.Toolbar
import androidx.fragment.app.DialogFragment
import com.example.recordedsteampunk.R
import com.example.recordedsteampunk.adapter.TestRecordRecyclerAdapter.Companion.getDateFormat
import com.google.android.material.textfield.TextInputEditText
import java.util.Calendar
import java.util.Date


class AddTestDialogFragment : DialogFragment() {
    companion object {
        const val TAG = "AddTestDialogFragment [DEBUG]"
    }

    private lateinit var toolbar: Toolbar

    private lateinit var dateInput: TextInputEditText
    private lateinit var titleInput: TextInputEditText
    private lateinit var subjectInput: TextInputEditText
    private lateinit var topicInput: TextInputEditText
    private lateinit var totalMarksInput: TextInputEditText
    private lateinit var marksObtainedInput: TextInputEditText

    private var listener: AddTestDialogListener? = null

    private val currentCal = Calendar.getInstance()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        Log.d(TAG, "TODO: implement: \"setStyle(DialogFragment.STYLE_NORMAL, R.style.)\"")

        currentCal.time = Date()
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        super.onCreateView(inflater, container, savedInstanceState)

        val view: View = inflater.inflate(R.layout.dialog_add_test, container, false)

        toolbar = view.findViewById(R.id.add_test_dialog_toolbar)

        dateInput = view.findViewById(R.id.add_test_dialog_date_input)
        titleInput = view.findViewById(R.id.add_test_dialog_title_input)
        subjectInput = view.findViewById(R.id.add_test_dialog_subject_input)
        topicInput = view.findViewById(R.id.add_test_dialog_topic_input)
        totalMarksInput = view.findViewById(R.id.add_test_dialog_total_marks_input)
        marksObtainedInput = view.findViewById(R.id.add_test_dialog_marks_obtained_input)

        return view
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        // setting up toolbar
        toolbar.setNavigationOnClickListener { dismiss() }
        toolbar.title = "Add New Test"
        toolbar.inflateMenu(R.menu.menu_add_test_dialog)

        // setting up date input and date picker dialog
        dateInput.setText(getDateFormat().format(currentCal.time))

        val datePickerDialog = DatePickerDialog(
            requireContext(),
            { _: DatePicker, year: Int, month: Int, dayOfMonth: Int ->
                currentCal.set(Calendar.YEAR, year)
                currentCal.set(Calendar.MONTH, month)
                currentCal.set(Calendar.DAY_OF_MONTH, dayOfMonth)

                dateInput.setText(getDateFormat().format(currentCal.time))
            },
            currentCal.get(Calendar.YEAR),
            currentCal.get(Calendar.MONTH),
            currentCal.get(Calendar.DAY_OF_MONTH)
        )

        dateInput.setOnClickListener {
            datePickerDialog.show()
        }

        // setting up the done button function
        toolbar.setOnMenuItemClickListener {
            when (it.itemId) {
                R.id.menu_add_test_dialog_action_add -> {
                    val date = currentCal.timeInMillis
                    val title = titleInput.text.toString()
                    val subject = subjectInput.text.toString()
                    val topic = topicInput.text.toString()
                    val totalMarks = totalMarksInput.text.toString().toFloat()
                    val marksObtained = marksObtainedInput.text.toString().toFloat()

                    Log.d(TAG, "$date | $title | $subject | $topic | $totalMarks | $marksObtained")

                    listener?.onAddTest(date, title, subject, topic, totalMarks, marksObtained)

                    dismiss()

                    true
                }

                else -> false
            }
        }
    }

    override fun onStart() {
        super.onStart()

        if (dialog != null) {
            val width = ViewGroup.LayoutParams.MATCH_PARENT
            val height = ViewGroup.LayoutParams.MATCH_PARENT
            dialog!!.window!!.setLayout(width, height)
        }
    }

    fun setListener(l: AddTestDialogListener) {
        listener = l
    }

    interface AddTestDialogListener {
        fun onAddTest(
            date: Long,
            title: String,
            subject: String,
            topic: String,
            totalMarks: Float,
            marksObtained: Float
        )
    }
}