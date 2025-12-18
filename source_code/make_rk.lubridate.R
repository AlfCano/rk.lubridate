local({
  # =========================================================================================
  # Package Definition and Metadata
  # =========================================================================================
  require(rkwarddev)
  rkwarddev.required("0.08-1")

  package_about <- rk.XML.about(
    name = "rk.lubridate",
    author = person(
      given = "Alfonso",
      family = "Cano Robles",
      email = "alfonso.cano@correo.buap.mx",
      role = c("aut", "cre")
    ),
    about = list(
      desc = "An RKWard plugin package for working with dates and times data using the 'lubridate' library.",
      version = "0.0.4",
      url = "https://github.com/AlfCano/rk.lubridate",
      license = "GPL (>= 3)"
    )
  )

  # =========================================================================================
  # --- Reusable UI and JS Helpers ---
  # =========================================================================================

  dt_varselector <- rk.XML.varselector(id.name = "dt_varselector")
  dt_varslot <- rk.XML.varslot("Select a date-time object", source = "dt_varselector", required = TRUE, id.name = "dt_object")
  save_obj <- rk.XML.saveobj("Save result as", initial = "lubridate_result", chk=TRUE, id.name="save_result")

  js_print_std <- '
    var save_name = getValue("save_result.objectname");
    echo("rk.header(\\"lubridate Operation Results\\")\\n");
    if(getValue("save_result.active")){
      echo("rk.header(\\"Result saved to object: " + save_name + "\\", level=3)\\n");
    }
  '

  # Specific helpers
  js_print_period <- ' var save_name = getValue("save_period.objectname"); echo("rk.header(\\"Create Period Results\\")\\n"); if(getValue("save_period.active")){ echo("rk.header(\\"Result saved to object: " + save_name + "\\", level=3)\\n"); } '
  js_print_duration <- ' var save_name = getValue("save_duration.objectname"); echo("rk.header(\\"Create Duration Results\\")\\n"); if(getValue("save_duration.active")){ echo("rk.header(\\"Result saved to object: " + save_name + "\\", level=3)\\n"); } '
  js_print_interval <- ' var save_name = getValue("save_interval.objectname"); echo("rk.header(\\"Create Interval Results\\")\\n"); if(getValue("save_interval.active")){ echo("rk.header(\\"Result saved to object: " + save_name + "\\", level=3)\\n"); } '

  locale_presets <- list( "System Default" = list(val = "", chk=TRUE), "English (USA)" = list(val = "en_US.UTF-8"), "French (France)" = list(val = "fr_FR.UTF-8"), "German (Germany)" = list(val = "de_DE.UTF-8"), "Spanish (Spain)" = list(val = "es_ES.UTF-8"), "Portuguese (Portugal)" = list(val = "pt_PT.UTF-8"), "Italian (Italy)" = list(val = "it_IT.UTF-8") )
  locale_dropdown <- rk.XML.dropdown(label="Output Language (Locale)", options = locale_presets, id.name = "locale_select")
  locale_help <- rk.XML.text("Note: Exact names for locales can vary by OS (e.g., 'French' on Windows).")

  # =========================================================================================
  # Main Plugin Definition: Parse Date-Times
  # =========================================================================================

  parse_varselector <- rk.XML.varselector(id.name="parse_varselector")
  parse_varslot <- rk.XML.varslot("Object with date-time strings", source="parse_varselector", id.name="parse_varslot", required=FALSE)
  parse_manual_input <- rk.XML.input("OR enter a vector manually (e.g., c('2025-01-20'))", id.name="parse_manual_input")
  preview_pane <- rk.XML.preview(mode="data")

  parse_functions_list <- list(
    "ymd" = list(val="ymd", chk=TRUE), "ymd_h" = list(val="ymd_h"), "ymd_hm" = list(val="ymd_hm"), "ymd_hms" = list(val="ymd_hms"),
    "ydm" = list(val="ydm"), "ydm_h" = list(val="ydm_h"), "ydm_hm" = list(val="ydm_hm"), "ydm_hms" = list(val="ydm_hms"),
    "mdy" = list(val="mdy"), "mdy_h" = list(val="mdy_h"), "mdy_hm" = list(val="mdy_hm"), "mdy_hms" = list(val="mdy_hms"),
    "myd" = list(val="myd"), "myd_h" = list(val="myd_h"), "myd_hm" = list(val="myd_hm"), "myd_hms" = list(val="myd_hms"),
    "dmy" = list(val="dmy"), "dmy_h" = list(val="dmy_h"), "dmy_hm" = list(val="dmy_hm"), "dmy_hms" = list(val="dmy_hms"),
    "dym" = list(val="dym"), "dym_h" = list(val="dym_h"), "dym_hm" = list(val="dym_hm"), "dym_hms" = list(val="dym_hms")
  )

  parse_dialog <- rk.XML.dialog(
    label = "Parse Date-Times with lubridate",
    child = rk.XML.row(
        parse_varselector,
        rk.XML.col(
            rk.XML.frame(parse_varslot, parse_manual_input, label="Data Source"),
            rk.XML.dropdown(label = "Select parsing function", id.name = "parse_order", options = parse_functions_list),
            rk.XML.input("Optional: Time zone", id.name="parse_tz"),
            save_obj,
            preview_pane
        )
    )
  )

  js_common_parse_logic <- '
    var manual_input = getValue("parse_manual_input");
    var date_source;
    var r_command;
    if(manual_input){ date_source = manual_input; } else { date_source = getValue("parse_varslot"); }
    if(date_source){
        var order = getValue("parse_order");
        var tz = getValue("parse_tz");
        r_command = "lubridate::" + order + "(" + date_source;
        if(tz) { r_command += ", tz=\\"" + tz + "\\""; }
        r_command += ")";
    } else { r_command = "stop(\\"No data source provided.\\")"; }
  '
  js_calc_parse <- paste(js_common_parse_logic, 'echo("lubridate_result <- " + r_command + ";\\n");')
  js_preview_parse <- paste(js_common_parse_logic, 'echo("preview_data <- data.frame(Result=" + r_command + ");\\n");')

  # =========================================================================================
  # Component: Format Dates as Text
  # =========================================================================================
  format_save_obj <- rk.XML.saveobj("Save formatted text as", initial = "formatted_dates", chk=TRUE, id.name="save_result")
  format_presets <- list( "YYYY-MM-DD (e.g., 2025-11-21)" = list(val = "%Y-%m-%d", chk=TRUE), "Month Day, Year" = list(val = "%B %d, %Y"), "Weekday, Month Day, Year" = list(val = "%A, %B %d, %Y"), "MM/DD/YY" = list(val = "%m/%d/%y"), "Full ISO DateTime" = list(val = "%Y-%m-%d %H:%M:%S"), "12-Hour Time" = list(val = "%I:%M:%S %p") )
  format_dropdown <- rk.XML.dropdown(label="Select a preset format", options = format_presets, id.name = "format_preset_dropdown")
  format_custom_input <- rk.XML.input(label = "OR enter a custom format string", id.name = "format_custom_input")
  format_varslot <- rk.XML.varslot("Select a date-time object", source = "dt_varselector", required = TRUE, id.name = "dt_object")
  format_preview_pane <- rk.XML.preview(mode="data")

  format_dialog <- rk.XML.dialog( label = "Format Dates as Text", child = rk.XML.row( dt_varselector, rk.XML.col( format_varslot, rk.XML.frame(format_dropdown, format_custom_input, rk.XML.text("Custom format uses R standard codes."), label = "Formatting Method"), rk.XML.frame(locale_dropdown, locale_help, label="Language"), format_save_obj, format_preview_pane ) ) )

  js_common_format_logic <- '
    var date_object = getValue("dt_object");
    var custom_format = getValue("format_custom_input");
    var preset_format = getValue("format_preset_dropdown");
    var locale = getValue("locale_select");
    var r_command = "";
    var format_str = custom_format;
    if(!format_str){ format_str = preset_format; }
    if(date_object && format_str){
        if(locale){
            r_command += "local({ original_locale <- Sys.getlocale(\\"LC_TIME\\"); Sys.setlocale(\\"LC_TIME\\", \\"" + locale + "\\"); tryCatch({ ";
        }
        r_command += "format(" + date_object + ", format=\\"" + format_str + "\\")";
        if(locale){ r_command += " }, finally = { Sys.setlocale(\\"LC_TIME\\", original_locale) }) })"; }
    } else if (date_object && !format_str) { r_command = "stop(\\"No format string provided.\\")"; }
  '
  js_calc_format <- paste(js_common_format_logic, 'echo("formatted_dates <- " + r_command + ";\\n");')
  js_preview_format <- paste(js_common_format_logic, 'if(r_command) { echo("preview_data <- data.frame(Result=" + r_command + ");\\n"); }')

  format_component <- rk.plugin.component( "Format Dates as Text", xml = list(dialog = format_dialog), js = list(calculate = js_calc_format, preview = js_preview_format, printout = js_print_std), hierarchy = list("data", "Date and Time (lubridate)") )

  # =========================================================================================
  # Component: Apply Stamping Function
  # =========================================================================================
  stamp_fun_slot <- rk.XML.varslot("Select stamping function", source="dt_varselector", required=TRUE, id.name="stamp_fun_slot")
  apply_stamp_save_obj <- rk.XML.saveobj("Save result as", initial = "formatted_dates", chk=TRUE, id.name="save_result")
  apply_stamp_dialog <- rk.XML.dialog( label = "Format Dates as Text (with Stamping Function)", child = rk.XML.row( dt_varselector, rk.XML.col( dt_varslot, stamp_fun_slot, apply_stamp_save_obj, rk.XML.preview(mode="data") ) ) )
  js_common_apply_stamp_logic <- ' var date_object = getValue("dt_object"); var stamp_fun = getValue("stamp_fun_slot"); var r_command = ""; if(date_object && stamp_fun){ r_command = stamp_fun + "(" + date_object + ")"; } '
  js_calc_apply_stamp <- paste(js_common_apply_stamp_logic, 'if(r_command){ echo("formatted_dates <- " + r_command + ";\\n"); }')
  js_preview_apply_stamp <- paste(js_common_apply_stamp_logic, 'if(r_command){ echo("preview_data <- data.frame(Result=" + r_command + ");\\n"); }')
  apply_stamp_component <- rk.plugin.component( "Apply Stamping Function", xml = list(dialog = apply_stamp_dialog), js = list(calculate = js_calc_apply_stamp, preview = js_preview_apply_stamp, printout = js_print_std), hierarchy = list("data", "Date and Time (lubridate)") )

  # =========================================================================================
  # Component: Create Stamping Function
  # =========================================================================================
  stamp_presets <- list( "Full Date" = list(val = "'%A, %B %d, %Y'", chk=TRUE), "Spanish Full" = list(val = "'Hoy es %A, %d-%m-%Y'"), "ISO Date" = list(val = "'%Y-%m-%d'"), "US Short" = list(val = "'%m/%d/%y'"), "EU Short" = list(val = "'%d/%m/%y'"), "Abbreviated" = list(val = "'%a, %d %b %Y'") )
  stamp_preset_dropdown <- rk.XML.dropdown(label="Select a preset format", options=stamp_presets, id.name="stamp_preset_dropdown")
  stamp_custom_input <- rk.XML.input(label = "OR enter a custom format string (as R code)", id.name = "stamp_custom_input")
  stamp_dialog <- rk.XML.dialog( label = "Create Language-Specific Stamping Function", child = rk.XML.col( rk.XML.frame(stamp_preset_dropdown, stamp_custom_input, label="Formatting Method"), rk.XML.frame(locale_dropdown, locale_help, label="Language for Function"), save_obj ) )
  js_calc_stamp <- ' var custom_format = getValue("stamp_custom_input"); var preset_format = getValue("stamp_preset_dropdown"); var format_str = custom_format; if(!format_str){ format_str = preset_format; } var locale = getValue("locale_select"); if(format_str){ var code = "lubridate_result <- function(date_object) {\\n"; if (locale) { code += "  original_locale <- Sys.getlocale(\\"LC_TIME\\")\\n"; code += "  Sys.setlocale(\\"LC_TIME\\", \\"" + locale + "\\")\\n"; code += "  tryCatch({\\n"; code += "    format(date_object, format = " + format_str + ")\\n"; code += "  }, finally = {\\n"; code += "    Sys.setlocale(\\"LC_TIME\\", original_locale)\\n"; code += "  })\\n"; } else { code += "  format(date_object, format = " + format_str + ")\\n"; } code += "}\\n"; echo(code); } else { echo("rk.stop(\\"No format string provided.\\")"); } '
  stamp_component <- rk.plugin.component( "Create Stamping Function", xml = list(dialog = stamp_dialog), js = list(calculate = js_calc_stamp, printout = js_print_std), hierarchy = list("data", "Date and Time (lubridate)") )

  # =========================================================================================
  # Component: Get Component from Date
  # =========================================================================================
  get_comp_dialog <- rk.XML.dialog( label = "Get Component from Date", child = rk.XML.row( dt_varselector, rk.XML.col( dt_varslot, rk.XML.dropdown(label="Component to get", id.name="get_comp", options=list( "Year" = list(val="year", chk=TRUE), "Month" = list(val="month"), "Day" = list(val="day"), "Hour" = list(val="hour"), "Minute" = list(val="minute"), "Second" = list(val="second"), "Week" = list(val="week"), "Day of year" = list(val="yday") )), rk.XML.cbox("Get label (e.g., 'January')", id.name="get_label", value="1"), save_obj, rk.XML.preview(mode="data") ) ) )
  js_common_get_comp_logic <- ' var dt_object = getValue("dt_object"); var r_command = ""; if(dt_object){ var comp = getValue("get_comp"); var label = getValue("get_label"); r_command = "lubridate::" + comp + "(" + dt_object; if(label == 1){ r_command += ", label=TRUE"; } r_command += ")"; } '
  js_calc_get_comp <- paste(js_common_get_comp_logic, 'if(r_command){ echo("lubridate_result <- " + r_command + ";\\n"); }')
  js_preview_get_comp <- paste(js_common_get_comp_logic, 'if(r_command){ echo("preview_data <- data.frame(Result=" + r_command + ");\\n"); }')
  get_component <- rk.plugin.component( "Get Component from Date", xml = list(dialog = get_comp_dialog), js = list(require = "lubridate", calculate = js_calc_get_comp, preview = js_preview_get_comp, printout = js_print_std), hierarchy = list("data", "Date and Time (lubridate)") )

  # =========================================================================================
  # Component: Set Component in Date
  # =========================================================================================
  set_component <- rk.plugin.component( "Set Component in Date", xml = list(dialog = rk.XML.dialog( label = "Set Component in Date", child = rk.XML.row( dt_varselector, rk.XML.col( dt_varslot, rk.XML.dropdown(label="Component to set", id.name="set_comp", options=list( "Year" = list(val="year", chk=TRUE), "Month" = list(val="month"), "Day" = list(val="day"), "Hour" = list(val="hour"), "Minute" = list(val="minute"), "Second" = list(val="second") )), rk.XML.input("New value", required=TRUE, id.name="set_value"), save_obj ) ) )), js = list(require = "lubridate", calculate = ' var dt_object = getValue("dt_object"); if(dt_object){ var comp = getValue("set_comp"); var value = getValue("set_value"); var code = "lubridate_result <- " + dt_object + ";\\n"; code += "lubridate::" + comp + "(lubridate_result) <- " + value + ";\\n"; echo(code); } ', printout = js_print_std), hierarchy = list("data", "Date and Time (lubridate)"))

  # =========================================================================================
  # Component: Round Date-Times
  # =========================================================================================
  round_dialog <- rk.XML.dialog( label = "Round Date-Times", child = rk.XML.row( dt_varselector, rk.XML.col( dt_varslot, rk.XML.dropdown(label="Rounding unit", id.name="round_unit", options=list( "Second" = list(val="second", chk=TRUE), "Minute" = list(val="minute"), "Hour" = list(val="hour"), "Day" = list(val="day"), "Week" = list(val="week"), "Month" = list(val="month"), "Year" = list(val="year") )), rk.XML.radio(label="Rounding function", id.name="round_func", options=list( "Round (nearest)" = list(val="round_date", chk=TRUE), "Floor (round down)" = list(val="floor_date"), "Ceiling (round up)" = list(val="ceiling_date") )), save_obj, rk.XML.preview(mode="data") ) ) )
  js_common_round_logic <- ' var dt_object = getValue("dt_object"); var r_command = ""; if(dt_object){ var func = getValue("round_func"); var unit = getValue("round_unit"); r_command = "lubridate::" + func + "(" + dt_object + ", unit=\\"" + unit + "\\")"; } '
  js_calc_round <- paste(js_common_round_logic, 'if(r_command){ echo("lubridate_result <- " + r_command + ";\\n"); }')
  js_preview_round <- paste(js_common_round_logic, 'if(r_command){ echo("preview_data <- data.frame(Result=" + r_command + ");\\n"); }')
  round_component <- rk.plugin.component( "Round Date-Times", xml = list(dialog = round_dialog), js = list(require="lubridate", calculate=js_calc_round, preview=js_preview_round, printout = js_print_std), hierarchy = list("data", "Date and Time (lubridate)") )

  # =========================================================================================
  # Component: Time Zones
  # =========================================================================================
  tz_component <- rk.plugin.component( "Time Zones", xml = list(dialog = rk.XML.dialog( label = "Work with Time Zones", child = rk.XML.row( dt_varselector, rk.XML.col( dt_varslot, rk.XML.input("Target time zone (e.g., 'UTC', 'America/New_York')", id.name="tz_name", required=TRUE), rk.XML.radio(label="Function", id.name="tz_func", options=list( "with_tz (display in new time zone)" = list(val="with_tz", chk=TRUE), "force_tz (change time zone without changing clock time)" = list(val="force_tz") )), save_obj ) ) )), js = list(require="lubridate", calculate=' var dt_object = getValue("dt_object"); if(!dt_object) return; var func = getValue("tz_func"); var tz = getValue("tz_name"); var code = "lubridate_result <- lubridate::" + func + "(" + dt_object + ", tzone=\\"" + tz + "\\");\\n"; echo(code); ', printout = js_print_std), hierarchy = list("data", "Date and Time (lubridate)"))

  # =========================================================================================
  # Component: Time Spans
  # =========================================================================================
  js_common_period_logic <- ' var val = getValue("period_val"); var unit = getValue("period_unit"); var r_command = "lubridate::" + unit + "(" + val + ")"; '
  js_calc_period <- paste(js_common_period_logic, 'echo("lubridate_period <- " + r_command + ";\\n");')
  js_preview_period <- paste(js_common_period_logic, 'echo("preview_data <- data.frame(Result=as.character(" + r_command + "));\\n");')
  period_component <- rk.plugin.component( "Create Periods", xml=list(dialog=rk.XML.dialog( label = "Create Periods (human units)", child = rk.XML.col( rk.XML.spinbox("Value", min=0, initial=1, id.name="period_val"), rk.XML.dropdown(label="Unit", id.name="period_unit", options=list( "Years"=list(val="years", chk=TRUE), "Months"=list(val="months"), "Weeks"=list(val="weeks"), "Days"=list(val="days"), "Hours"=list(val="hours"), "Minutes"=list(val="minutes"), "Seconds"=list(val="seconds") )), rk.XML.text("Use for human-centric times, like 'one month from today'."), rk.XML.saveobj("Save period as", initial = "lubridate_period", chk=TRUE, id.name="save_period"), rk.XML.preview(mode="data") ) )), js=list(require="lubridate", calculate=js_calc_period, preview=js_preview_period, printout=js_print_period), hierarchy=list("data", "Date and Time (lubridate)", "Time Spans"))

  js_common_duration_logic <- ' var val = getValue("duration_val"); var unit = getValue("duration_unit"); var r_command = "lubridate::" + unit + "(" + val + ")"; '
  js_calc_duration <- paste(js_common_duration_logic, 'echo("lubridate_duration <- " + r_command + ";\\n");')
  js_preview_duration <- paste(js_common_duration_logic, 'echo("preview_data <- data.frame(Result=as.character(" + r_command + "));\\n");')
  duration_component <- rk.plugin.component( "Create Durations", xml=list(dialog=rk.XML.dialog( label = "Create Durations (exact seconds)", child = rk.XML.col( rk.XML.spinbox("Value", min=0, initial=1, id.name="duration_val"), rk.XML.dropdown(label="Unit", id.name="duration_unit", options=list( "Years"=list(val="dyears", chk=TRUE), "Weeks"=list(val="dweeks"), "Days"=list(val="ddays"), "Hours"=list(val="dhours"), "Minutes"=list(val="dminutes"), "Seconds"=list(val="dseconds") )), rk.XML.text("Use for exact time measurements, handles leap years correctly."), rk.XML.saveobj("Save duration as", initial = "lubridate_duration", chk=TRUE, id.name="save_duration"), rk.XML.preview(mode="data") ) )), js=list(require="lubridate", calculate=js_calc_duration, preview=js_preview_duration, printout=js_print_duration), hierarchy=list("data", "Date and Time (lubridate)", "Time Spans"))

  output_type_radio <- rk.XML.radio( label="Output Type", options=list( "Interval Object" = list(val="interval", chk=TRUE), "Period" = list(val="period"), "Numeric Length" = list(val="length") ), id.name="output_type_radio" )
  unit_dropdown_int <- rk.XML.dropdown(label="Unit for Period/Length:", options=list("Years" = list(val="years", chk=TRUE), "Months" = list(val="months"), "Days" = list(val="days")), id.name="unit_select")
  save_obj_interval <- rk.XML.saveobj("Save interval as", initial = "lubridate_interval", chk=TRUE, id.name="save_interval")
  interval_dialog <- rk.XML.dialog( label = "Create Interval", child = rk.XML.row( dt_varselector, rk.XML.col( rk.XML.varslot("Start date", source="dt_varselector", required=TRUE, id.name="interval_start"), rk.XML.varslot("End date", source="dt_varselector", required=TRUE, id.name="interval_end"), rk.XML.frame(output_type_radio, unit_dropdown_int, label = "Output Format"), save_obj_interval, rk.XML.preview(mode="data") ) ) )
  js_common_interval_logic <- ' var start = getValue("interval_start"); var end = getValue("interval_end"); var output_type = getValue("output_type_radio"); var unit = getValue("unit_select"); var r_command = ""; if(start && end){ var core_interval = "lubridate::interval(" + start + ", " + end + ")"; if(output_type == "period"){ r_command = "as.period(" + core_interval + ", unit=\\"" + unit + "\\")"; } else if(output_type == "length"){ r_command = "lubridate::time_length(" + core_interval + ", unit=\\"" + unit + "\\")"; } else { r_command = core_interval; } } '
  js_calc_interval <- paste(js_common_interval_logic, 'if(r_command) { echo("lubridate_interval <- " + r_command + ";\\n"); }')
  js_preview_interval <- paste(js_common_interval_logic, 'if(r_command) { echo("preview_data <- data.frame(Result=as.character(" + r_command + "));\\n"); }')
  interval_component <- rk.plugin.component( "Create Intervals", xml=list(dialog=interval_dialog), js=list(require="lubridate", calculate=js_calc_interval, preview=js_preview_interval, printout=js_print_interval), hierarchy=list("data", "Date and Time (lubridate)", "Time Spans") )

  # =========================================================================================
  # NEW COMPONENTS: Calculations (FIXED)
  # =========================================================================================

  # 1. Shift Dates (UPDATED: Added %m+% support)
  shift_varslot <- rk.XML.varslot("Select Date Object", source = "dt_varselector", required = TRUE, id.name = "shift_date_obj")
  shift_op <- rk.XML.radio(label="Operation", options=list("Add (+)"=list(val="add", chk=TRUE), "Subtract (-)"=list(val="sub")), id.name="shift_op")
  shift_val <- rk.XML.spinbox(label="Amount", min=0, initial=1, id.name="shift_val")
  shift_unit <- rk.XML.dropdown(label="Unit", options=list("Days"=list(val="days", chk=TRUE), "Weeks"=list(val="weeks"), "Months"=list(val="months"), "Years"=list(val="years"), "Hours"=list(val="hours")), id.name="shift_unit")
  shift_type <- rk.XML.radio(label="Time Type", options=list("Period (Smart, e.g. 1 month)"=list(val="period", chk=TRUE), "Duration (Exact, e.g. 30 days)"=list(val="duration")), id.name="shift_type")
  shift_roll <- rk.XML.cbox(label = "Handle end-of-month rollover (%m+%)", value = "1", id.name = "shift_roll")
  shift_save <- rk.XML.saveobj("Save result as", initial = "shifted_date", chk=TRUE, id.name="save_result")

  shift_dialog <- rk.XML.dialog(label="Shift Dates (Add/Subtract)", child=rk.XML.row(dt_varselector, rk.XML.col(shift_varslot, rk.XML.frame(shift_op, shift_val, shift_unit, shift_type, shift_roll, label="Settings"), shift_save, rk.XML.preview(mode="data"))))

  js_common_shift <- '
    var dt = getValue("shift_date_obj");
    var op = getValue("shift_op");
    var val = getValue("shift_val");
    var unit = getValue("shift_unit");
    var type = getValue("shift_type");
    var roll = getValue("shift_roll");

    var time_obj = "";
    if (type == "period") { time_obj = "lubridate::period(" + val + ", units=\\"" + unit + "\\")"; }
    else { time_obj = "lubridate::duration(" + val + ", units=\\"" + unit + "\\")"; }

    var operator = "";
    // Logic for rollover operator (%m+% / %m-%) which only works with periods
    if (roll == "1" && type == "period" && (unit == "months" || unit == "years")) {
         operator = (op == "add") ? "%m+%" : "%m-%";
    } else {
         operator = (op == "add") ? "+" : "-";
    }

    var r_command = dt + " " + operator + " " + time_obj;
  '
  js_calc_shift <- paste(js_common_shift, 'echo("shifted_date <- " + r_command + ";\\n");')
  js_prev_shift <- paste(js_common_shift, 'echo("preview_data <- data.frame(Result=as.character(" + r_command + "));\\n");')

  shift_component <- rk.plugin.component("Shift Dates", xml=list(dialog=shift_dialog), js=list(require="lubridate", calculate=js_calc_shift, preview=js_prev_shift, printout=js_print_std), hierarchy=list("data", "Date and Time (lubridate)", "Calculations"))

  # 2. Check Overlaps
  overlap_date <- rk.XML.varslot("Date Object", source="dt_varselector", required=TRUE, id.name="overlap_date")
  overlap_int <- rk.XML.varslot("Interval Object", source="dt_varselector", required=TRUE, id.name="overlap_int")
  overlap_save <- rk.XML.saveobj("Save logical result as", initial = "is_within", chk=TRUE, id.name="save_result")

  overlap_dialog <- rk.XML.dialog(label="Check Date Overlaps (%within%)", child=rk.XML.row(dt_varselector, rk.XML.col(overlap_date, overlap_int, overlap_save, rk.XML.preview(mode="data"))))
  js_common_overlap <- 'var d = getValue("overlap_date"); var i = getValue("overlap_int"); var r_command = d + " %within% " + i;'
  js_calc_overlap <- paste(js_common_overlap, 'echo("is_within <- " + r_command + ";\\n");')
  js_prev_overlap <- paste(js_common_overlap, 'echo("preview_data <- data.frame(Within=" + r_command + ");\\n");')

  overlap_component <- rk.plugin.component("Check Overlaps", xml=list(dialog=overlap_dialog), js=list(require="lubridate", calculate=js_calc_overlap, preview=js_prev_overlap, printout=js_print_std), hierarchy=list("data", "Date and Time (lubridate)", "Calculations"))

  # 3. Business Extractions
  extr_varslot <- rk.XML.varslot("Date Object", source="dt_varselector", required=TRUE, id.name="dt_object")
  extr_opts <- rk.XML.dropdown(label="Extract", options=list(
      "Quarter"=list(val="quarter", chk=TRUE), "Semester"=list(val="semester"),
      "Day of Year"=list(val="yday"), "Day of Quarter"=list(val="qday"),
      "Weekday"=list(val="wday"), "Is Leap Year?"=list(val="leap_year"), "Is AM?"=list(val="am"), "Is DST?"=list(val="dst")
  ), id.name="extr_func")
  extr_chk <- rk.XML.cbox("Label / With Year (applies to Quarter/Weekday)", id.name="extr_lbl", value="1")
  extr_save <- rk.XML.saveobj("Save result as", initial = "date_part", chk=TRUE, id.name="save_result")

  extr_dialog <- rk.XML.dialog(label="Business Extractions", child=rk.XML.row(dt_varselector, rk.XML.col(extr_varslot, extr_opts, extr_chk, extr_save, rk.XML.preview(mode="data"))))
  js_common_extr <- '
    var dt = getValue("dt_object"); var func = getValue("extr_func"); var lbl = getValue("extr_lbl");
    var r_command = "lubridate::" + func + "(" + dt;
    if(lbl == "1") {
        if(func == "quarter") r_command += ", with_year=TRUE";
        else if(func == "wday" || func == "month") r_command += ", label=TRUE";
    }
    r_command += ")";
  '
  js_calc_extr <- paste(js_common_extr, 'echo("date_part <- " + r_command + ";\\n");')
  js_prev_extr <- paste(js_common_extr, 'echo("preview_data <- data.frame(Result=" + r_command + ");\\n");')

  extr_component <- rk.plugin.component("Advanced Extractions", xml=list(dialog=extr_dialog), js=list(require="lubridate", calculate=js_calc_extr, preview=js_prev_extr, printout=js_print_std), hierarchy=list("data", "Date and Time (lubridate)", "Calculations"))

  # 4. Align Dates (Rollback)
  align_varslot <- rk.XML.varslot("Date Object", source="dt_varselector", required=TRUE, id.name="dt_object")
  align_act <- rk.XML.dropdown(label="Action", options=list(
      "Rollback (Last day of prev month)"=list(val="rollback", chk=TRUE),
      "Start of Month (Floor)"=list(val="floor"),
      "End of Month (Ceiling)"=list(val="ceiling"),
      "Days in Month"=list(val="days_in_month")
  ), id.name="align_act")
  align_save <- rk.XML.saveobj("Save result as", initial = "aligned_date", chk=TRUE, id.name="save_result")

  align_dialog <- rk.XML.dialog(label="Align Dates", child=rk.XML.row(dt_varselector, rk.XML.col(align_varslot, align_act, align_save, rk.XML.preview(mode="data"))))
  js_common_align <- '
    var dt = getValue("dt_object"); var act = getValue("align_act");
    var r_command = "";
    if(act == "rollback") r_command = "lubridate::rollback(" + dt + ")";
    else if(act == "floor") r_command = "lubridate::floor_date(" + dt + ", unit=\\"month\\")";
    else if(act == "ceiling") r_command = "lubridate::ceiling_date(" + dt + ", unit=\\"month\\") - lubridate::days(1)";
    else r_command = "lubridate::days_in_month(" + dt + ")";
  '
  js_calc_align <- paste(js_common_align, 'echo("aligned_date <- " + r_command + ";\\n");')
  js_prev_align <- paste(js_common_align, 'echo("preview_data <- data.frame(Result=" + r_command + ");\\n");')

  align_component <- rk.plugin.component("Align Dates", xml=list(dialog=align_dialog), js=list(require="lubridate", calculate=js_calc_align, preview=js_prev_align, printout=js_print_std), hierarchy=list("data", "Date and Time (lubridate)", "Calculations"))

  # 5. Decimal Dates
  dec_varslot <- rk.XML.varslot("Input Object", source="dt_varselector", required=TRUE, id.name="dt_object")
  dec_func <- rk.XML.radio(label="Convert To...", options=list("Decimal (e.g. 2015.5)"=list(val="decimal_date", chk=TRUE), "Date (from Decimal)"=list(val="date_decimal")), id.name="dec_func")
  dec_save <- rk.XML.saveobj("Save result as", initial = "dec_result", chk=TRUE, id.name="save_result")

  dec_dialog <- rk.XML.dialog(label="Decimal Conversion", child=rk.XML.row(dt_varselector, rk.XML.col(dec_varslot, dec_func, dec_save, rk.XML.preview(mode="data"))))
  js_common_dec <- 'var dt = getValue("dt_object"); var func = getValue("dec_func"); var r_command = "lubridate::" + func + "(" + dt + ")";'
  js_calc_dec <- paste(js_common_dec, 'echo("dec_result <- " + r_command + ";\\n");')
  js_prev_dec <- paste(js_common_dec, 'echo("preview_data <- data.frame(Result=" + r_command + ");\\n");')

  dec_component <- rk.plugin.component("Decimal Conversion", xml=list(dialog=dec_dialog), js=list(require="lubridate", calculate=js_calc_dec, preview=js_prev_dec, printout=js_print_std), hierarchy=list("data", "Date and Time (lubridate)", "Calculations"))

  # =========================================================================================
  # Final Plugin Skeleton Call
  # =========================================================================================

  rk.plugin.skeleton(
    about = package_about,
    path = ".",
    xml = list(dialog = parse_dialog ),
    js = list(
      require = "lubridate",
      calculate = js_calc_parse,
      preview = js_preview_parse,
      printout = js_print_std
    ),
    components = list(
      format_component,
      apply_stamp_component,
      stamp_component,
      get_component,
      set_component,
      round_component,
      tz_component,
      period_component,
      duration_component,
      interval_component,
      # New components
      shift_component,
      overlap_component,
      extr_component,
      align_component,
      dec_component
    ),
    pluginmap = list(
        name = "Parse Date-Times with lubridate",
        hierarchy = list("data", "Date and Time (lubridate)")
    ),
    create = c("pmap", "xml", "js", "desc", "about"),
    load = TRUE,
    overwrite = TRUE,
    show = FALSE
  )

  cat("\nPlugin package 'rk.lubridate' updated (v0.0.4) with rollover support.\n")
  cat("  1. rk.updatePluginMessages(path=\".\")\n")
  cat("  2. devtools::install(\".\")\n")
})
