# Golden Rules of RKWard Plugin Development (Revised & Expanded)
# Plugin for the lubridate R package (Final Corrected Version)

local({
  # =========================================================================================
  # Package Definition and Metadata
  # =========================================================================================
  require(rkwarddev)
  rkwarddev.required("0.8-1")

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
      version = "0.0.1",
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
    echo("rk.header(\\"Result saved to object: " + save_name + "\\", level=3)\\n");
  '

  locale_presets <- list(
    "System Default" = list(val = "", chk=TRUE),
    "English (USA)" = list(val = "en_US.UTF-8"),
    "French (France)" = list(val = "fr_FR.UTF-8"),
    "German (Germany)" = list(val = "de_DE.UTF-8"),
    "Spanish (Spain)" = list(val = "es_ES.UTF-8"),
    "Portuguese (Portugal)" = list(val = "pt_PT.UTF-8"),
    "Italian (Italy)" = list(val = "it_IT.UTF-8")
  )
  locale_dropdown <- rk.XML.dropdown(label="Output Language (Locale)", options = locale_presets, id.name = "locale_select")
  locale_help <- rk.XML.text("Note: Exact names for locales can vary by OS (e.g., 'French' on Windows).")

  # =========================================================================================
  # Main Plugin Definition: Parse Date-Times
  # =========================================================================================

  parse_varselector <- rk.XML.varselector(id.name="parse_varselector")
  parse_varslot <- rk.XML.varslot("Object with date-time strings", source="parse_varselector", id.name="parse_varslot", required=FALSE)
  parse_manual_input <- rk.XML.input("OR enter a vector manually (e.g., c('2025-01-20'))", id.name="parse_manual_input")

  parse_dialog <- rk.XML.dialog(
    label = "Parse Date-Times with lubridate",
    child = rk.XML.row(
        parse_varselector,
        rk.XML.col(
            rk.XML.frame(
                parse_varslot,
                parse_manual_input,
                label="Data Source"
            ),
            rk.XML.dropdown(label = "Select parsing order", id.name = "parse_order", options = list(
                "Year, Month, Day" = list(val = "ymd", chk = TRUE),
                "Year, Month, Day, Hour, Minute, Second" = list(val = "ymd_hms"),
                "Month, Day, Year" = list(val = "mdy"),
                "Day, Month, Year" = list(val = "dmy")
            )),
            rk.XML.input("Optional: Time zone", id.name="parse_tz"),
            save_obj
        )
    )
  )

  js_calc_parse <- '
    var date_source = getValue("parse_varslot");
    if(!date_source){
        date_source = getValue("parse_manual_input");
    }

    if(date_source){
        var order = getValue("parse_order");
        var tz = getValue("parse_tz");
        var code = "lubridate_result <- lubridate::" + order + "(" + date_source;
        if(tz) {
            code += ", tz=\\"" + tz + "\\"";
        }
        code += ");\\n";
        echo(code);
    } else {
        echo("rk.stop(\\"No data source provided. Please select an object or enter a vector manually.\\")");
    }
  '

  # =========================================================================================
  # Component: Format Dates as Text
  # =========================================================================================
  format_save_obj <- rk.XML.saveobj("Save formatted text as", initial = "formatted_dates", chk=TRUE, id.name="save_result")
  format_presets <- list(
    "YYYY-MM-DD (e.g., 2025-11-21)" = list(val = "%Y-%m-%d", chk=TRUE),
    "Month Day, Year (e.g., November 21, 2025)" = list(val = "%B %d, %Y"),
    "Weekday, Month Day, Year (e.g., Friday, November 21, 2025)" = list(val = "%A, %B %d, %Y"),
    "MM/DD/YY (e.g., 11/21/25)" = list(val = "%m/%d/%y"),
    "Full ISO DateTime (e.g., 2025-11-21 15:30:00)" = list(val = "%Y-%m-%d %H:%M:%S"),
    "12-Hour Time (e.g., 03:30:00 PM)" = list(val = "%I:%M:%S %p")
  )
  format_dropdown <- rk.XML.dropdown(label="Select a preset format", options = format_presets, id.name = "format_preset_dropdown")
  format_custom_input <- rk.XML.input(label = "OR enter a custom format string", id.name = "format_custom_input")
  format_help_text <- rk.XML.text("Custom format uses R standard codes, e.g., '%d/%m/%y'.")

  format_dialog <- rk.XML.dialog(
      label = "Format Dates as Text (with Format String)",
      child = rk.XML.row(
          dt_varselector,
          rk.XML.col(
              dt_varslot,
              rk.XML.frame(format_dropdown, format_custom_input, format_help_text, label = "Formatting Method"),
              rk.XML.frame(locale_dropdown, locale_help, label="Language"),
              format_save_obj
          )
      )
  )

  js_calc_format <- '
    var date_object = getValue("dt_object");
    var custom_format = getValue("format_custom_input");
    var preset_format = getValue("format_preset_dropdown");
    var locale = getValue("locale_select");

    var format_str = custom_format;
    if(!format_str){
        format_str = preset_format;
    }

    if(date_object && format_str){
        var code = "";
        if(locale){
            code += "original_locale <- Sys.getlocale(\\"LC_TIME\\")\\n";
            code += "Sys.setlocale(\\"LC_TIME\\", \\"" + locale + "\\")\\n";
            code += "tryCatch({\\n";
        }

        code += "  formatted_dates <- format(" + date_object + ", format=\\"" + format_str + "\\")\\n";

        if(locale){
            code += "}, finally = {\\n";
            code += "  Sys.setlocale(\\"LC_TIME\\", original_locale)\\n";
            code += "})\\n";
        }
        echo(code);
    } else if (date_object && !format_str) {
        echo("rk.stop(\\"No format string provided. Please select a preset or enter a custom format.\\")");
    }
  '

  format_component <- rk.plugin.component(
    "Format Dates as Text",
    xml = list(dialog = format_dialog),
    js = list(calculate = js_calc_format, printout = js_print_std),
    hierarchy = list("data", "Date and Time (lubridate)")
  )

  # =========================================================================================
  # Component: Apply Stamping Function
  # =========================================================================================
  stamp_fun_slot <- rk.XML.varslot("Select stamping function", source="dt_varselector", required=TRUE, id.name="stamp_fun_slot")
  apply_stamp_save_obj <- rk.XML.saveobj("Save result as", initial = "formatted_dates", chk=TRUE, id.name="save_result")

  apply_stamp_dialog <- rk.XML.dialog(
      label = "Format Dates as Text (with Stamping Function)",
      child = rk.XML.row(
          dt_varselector,
          rk.XML.col(
              dt_varslot,
              stamp_fun_slot,
              apply_stamp_save_obj
          )
      )
  )

  js_calc_apply_stamp <- '
      var date_object = getValue("dt_object");
      var stamp_fun = getValue("stamp_fun_slot");
      if(date_object && stamp_fun){
          echo("formatted_dates <- " + stamp_fun + "(" + date_object + ")\\n");
      }
  '

  apply_stamp_component <- rk.plugin.component(
      "Apply Stamping Function",
      xml = list(dialog = apply_stamp_dialog),
      js = list(calculate = js_calc_apply_stamp, printout = js_print_std),
      hierarchy = list("data", "Date and Time (lubridate)")
  )

  # =========================================================================================
  # Component: Create Stamping Function
  # =========================================================================================
  stamp_presets <- list(
      "Full Date (e.g., 'Friday, November 21, 2025')" = list(val = "'%A, %B %d, %Y'", chk=TRUE),
      "Spanish Full (e.g., 'Hoy es lunes, 10-11-2025')" = list(val = "'Hoy es %A, %d-%m-%Y'"),
      "ISO Date (e.g., '2025-11-21')" = list(val = "'%Y-%m-%d'"),
      "US Style Short (e.g., '11/21/25')" = list(val = "'%m/%d/%y'"),
      "EU Style Short (e.g., '21/11/25')" = list(val = "'%d/%m/%y'"),
      "Abbreviated (e.g., 'Fri, 21 Nov 2025')" = list(val = "'%a, %d %b %Y'"),
      "Full Timestamp (e.g., '2025-11-21 15:30:00')" = list(val = "'%Y-%m-%d %H:%M:%S'"),
      "Time Only (e.g., '03:30:00 PM')" = list(val = "'%I:%M:%S %p'"),
      "Day of Year (e.g., 'Day 325 of 2025')" = list(val = "'Day %j of %Y'"),
      "Week of Year (e.g., 'Week 47 of 2025')" = list(val = "'Week %U of %Y'")
  )
  stamp_preset_dropdown <- rk.XML.dropdown(label="Select a preset format", options=stamp_presets, id.name="stamp_preset_dropdown")
  stamp_custom_input <- rk.XML.input(label = "OR enter a custom format string (as R code)", id.name = "stamp_custom_input")

  stamp_dialog <- rk.XML.dialog(
    label = "Create Language-Specific Stamping Function",
    child = rk.XML.col(
        rk.XML.frame(stamp_preset_dropdown, stamp_custom_input, label="Formatting Method"),
        rk.XML.frame(locale_dropdown, locale_help, label="Language for Function"),
        save_obj
    )
  )

  js_calc_stamp <- '
    var custom_format = getValue("stamp_custom_input");
    var preset_format = getValue("stamp_preset_dropdown");
    var format_str = custom_format;
    if(!format_str){
        format_str = preset_format;
    }

    var locale = getValue("locale_select");

    if(format_str){
        var code = "lubridate_result <- function(date_object) {\\n";

        if (locale) {
            code += "  original_locale <- Sys.getlocale(\\"LC_TIME\\")\\n";
            code += "  Sys.setlocale(\\"LC_TIME\\", \\"" + locale + "\\")\\n";
            code += "  tryCatch({\\n";
            code += "    format(date_object, format = " + format_str + ")\\n";
            code += "  }, finally = {\\n";
            code += "    Sys.setlocale(\\"LC_TIME\\", original_locale)\\n";
            code += "  })\\n";
        } else {
            code += "  format(date_object, format = " + format_str + ")\\n";
        }

        code += "}\\n";
        echo(code);
    } else {
        echo("rk.stop(\\"No format string provided. Please select a preset or enter a custom format.\\")");
    }
  '

  stamp_component <- rk.plugin.component(
      "Create Stamping Function",
      xml = list(dialog = stamp_dialog),
      js = list(calculate = js_calc_stamp, printout = js_print_std),
      hierarchy = list("data", "Date and Time (lubridate)")
  )

  # =========================================================================================
  # Component: Get Component from Date
  # =========================================================================================
  get_component <- rk.plugin.component( "Get Component from Date", xml = list(dialog = rk.XML.dialog( label = "Get Component from Date", child = rk.XML.row( dt_varselector, rk.XML.col( dt_varslot, rk.XML.dropdown(label="Component to get", id.name="get_comp", options=list( "Year" = list(val="year", chk=TRUE), "Month" = list(val="month"), "Day" = list(val="day"), "Hour" = list(val="hour"), "Minute" = list(val="minute"), "Second" = list(val="second"), "Week" = list(val="week"), "Day of year" = list(val="yday") )), rk.XML.cbox("Get label (e.g., 'January')", id.name="get_label"), save_obj ) ) )), js = list(require = "lubridate", calculate = ' var dt_object = getValue("dt_object"); if(dt_object){ var comp = getValue("get_comp"); var label = getValue("get_label.state"); var code = "lubridate_result <- lubridate::" + comp + "(" + dt_object; if(label == 1){ code += ", label=TRUE"; } code += ");\\n"; echo(code); } ', printout = js_print_std), hierarchy = list("data", "Date and Time (lubridate)"))

  # =========================================================================================
  # Component: Set Component in Date
  # =========================================================================================
  set_component <- rk.plugin.component( "Set Component in Date", xml = list(dialog = rk.XML.dialog( label = "Set Component in Date", child = rk.XML.row( dt_varselector, rk.XML.col( dt_varslot, rk.XML.dropdown(label="Component to set", id.name="set_comp", options=list( "Year" = list(val="year", chk=TRUE), "Month" = list(val="month"), "Day" = list(val="day"), "Hour" = list(val="hour"), "Minute" = list(val="minute"), "Second" = list(val="second") )), rk.XML.input("New value", required=TRUE, id.name="set_value"), save_obj ) ) )), js = list(require = "lubridate", calculate = ' var dt_object = getValue("dt_object"); if(dt_object){ var comp = getValue("set_comp"); var value = getValue("set_value"); var code = "lubridate_result <- " + dt_object + ";\\n"; code += "lubridate::" + comp + "(lubridate_result) <- " + value + ";\\n"; echo(code); } ', printout = js_print_std), hierarchy = list("data", "Date and Time (lubridate)"))

  # =========================================================================================
  # Component: Round Date-Times
  # =========================================================================================
  round_component <- rk.plugin.component( "Round Date-Times", xml = list(dialog = rk.XML.dialog( label = "Round Date-Times", child = rk.XML.row( dt_varselector, rk.XML.col( dt_varslot, rk.XML.dropdown(label="Rounding unit", id.name="round_unit", options=list( "Second" = list(val="second", chk=TRUE), "Minute" = list(val="minute"), "Hour" = list(val="hour"), "Day" = list(val="day"), "Week" = list(val="week"), "Month" = list(val="month"), "Year" = list(val="year") )), rk.XML.radio(label="Rounding function", id.name="round_func", options=list( "Round (nearest)" = list(val="round_date", chk=TRUE), "Floor (round down)" = list(val="floor_date"), "Ceiling (round up)" = list(val="ceiling_date") )), save_obj ) ) )), js = list(require="lubridate", calculate=' var dt_object = getValue("dt_object"); if(!dt_object) return; var func = getValue("round_func"); var unit = getValue("round_unit"); var code = "lubridate_result <- lubridate::" + func + "(" + dt_object + ", unit=\\"" + unit + "\\");\\n"; echo(code); ', printout = js_print_std), hierarchy = list("data", "Date and Time (lubridate)"))

  # =========================================================================================
  # Component: Time Zones
  # =========================================================================================
  tz_component <- rk.plugin.component( "Time Zones", xml = list(dialog = rk.XML.dialog( label = "Work with Time Zones", child = rk.XML.row( dt_varselector, rk.XML.col( dt_varslot, rk.XML.input("Target time zone (e.g., 'UTC', 'America/New_York')", id.name="tz_name", required=TRUE), rk.XML.radio(label="Function", id.name="tz_func", options=list( "with_tz (display in new time zone)" = list(val="with_tz", chk=TRUE), "force_tz (change time zone without changing clock time)" = list(val="force_tz") )), save_obj ) ) )), js = list(require="lubridate", calculate=' var dt_object = getValue("dt_object"); if(!dt_object) return; var func = getValue("tz_func"); var tz = getValue("tz_name"); var code = "lubridate_result <- lubridate::" + func + "(" + dt_object + ", tzone=\\"" + tz + "\\");\\n"; echo(code); ', printout = js_print_std), hierarchy = list("data", "Date and Time (lubridate)"))

  # =========================================================================================
  # Component: Create Periods
  # =========================================================================================
  period_component <- rk.plugin.component( "Create Periods", xml=list(dialog=rk.XML.dialog( label = "Create Periods (human units)", child = rk.XML.col( rk.XML.spinbox("Value", min=0, initial=1, id.name="period_val"), rk.XML.dropdown(label="Unit", id.name="period_unit", options=list( "Years"=list(val="years", chk=TRUE), "Months"=list(val="months"), "Weeks"=list(val="weeks"), "Days"=list(val="days"), "Hours"=list(val="hours"), "Minutes"=list(val="minutes"), "Seconds"=list(val="seconds") )), rk.XML.text("Use for human-centric times, like 'one month from today'."), rk.XML.saveobj("Save period as", initial = "lubridate_period", chk=TRUE, id.name="save_period") ) )), js=list(require="lubridate", calculate=' var val = getValue("period_val"); var unit = getValue("period_unit"); echo("lubridate_period <- lubridate::" + unit + "(" + val + ");\\n"); ', printout=' var save_name = getValue("save_period.objectname"); echo("rk.header(\\"Create Period Results\\")\\n"); echo("rk.header(\\"Result saved to object: " + save_name + "\\", level=3)\\n"); '), hierarchy=list("data", "Date and Time (lubridate)", "Time Spans"))

  # =========================================================================================
  # Component: Create Durations
  # =========================================================================================
  duration_component <- rk.plugin.component( "Create Durations", xml=list(dialog=rk.XML.dialog( label = "Create Durations (exact seconds)", child = rk.XML.col( rk.XML.spinbox("Value", min=0, initial=1, id.name="duration_val"), rk.XML.dropdown(label="Unit", id.name="duration_unit", options=list( "Years"=list(val="dyears", chk=TRUE), "Weeks"=list(val="dweeks"), "Days"=list(val="ddays"), "Hours"=list(val="dhours"), "Minutes"=list(val="dminutes"), "Seconds"=list(val="dseconds") )), rk.XML.text("Use for exact time measurements, handles leap years correctly."), rk.XML.saveobj("Save duration as", initial = "lubridate_duration", chk=TRUE, id.name="save_duration") ) )), js=list(require="lubridate", calculate=' var val = getValue("duration_val"); var unit = getValue("duration_unit"); echo("lubridate_duration <- lubridate::" + unit + "(" + val + ");\\n"); ', printout=' var save_name = getValue("save_duration.objectname"); echo("rk.header(\\"Create Duration Results\\")\\n"); echo("rk.header(\\"Result saved to object: " + save_name + "\\", level=3)\\n"); '), hierarchy=list("data", "Date and Time (lubridate)", "Time Spans"))

  # =========================================================================================
  # Component: Create Intervals (REFACTORED with time_length)
  # =========================================================================================
  output_type_radio <- rk.XML.radio(
      label="Output Type",
      options=list(
          "Interval Object" = list(val="interval", chk=TRUE),
          "Period (human-readable, e.g., '3y 2m 5d')" = list(val="period"),
          "Numeric Length (e.g., 3.17)" = list(val="length")
      ),
      id.name="output_type_radio"
  )
  unit_options <- list(
      "Years" = list(val="years", chk=TRUE),
      "Months" = list(val="months"),
      "Days" = list(val="days"),
      "Hours" = list(val="hours"),
      "Minutes" = list(val="minutes"),
      "Seconds" = list(val="seconds")
  )
  unit_dropdown <- rk.XML.dropdown(label="Unit for Period/Length:", options=unit_options, id.name="unit_select")

  save_obj_interval <- rk.XML.saveobj("Save interval as", initial = "lubridate_interval", chk=TRUE, id.name="save_interval")
  interval_dialog <- rk.XML.dialog(
      label = "Create Interval (from start and end)",
      child = rk.XML.row(
        dt_varselector,
        rk.XML.col(
          rk.XML.varslot("Start date-time object", source="dt_varselector", required=TRUE, id.name="interval_start"),
          rk.XML.varslot("End date-time object", source="dt_varselector", required=TRUE, id.name="interval_end"),
          rk.XML.frame(
              output_type_radio,
              unit_dropdown,
              label = "Output Format"
          ),
          save_obj_interval
        )
      )
  )
  js_calc_interval <- '
      var start = getValue("interval_start");
      var end = getValue("interval_end");
      var output_type = getValue("output_type_radio");
      var unit = getValue("unit_select");

      if(start && end){
        var core_interval = "lubridate::interval(" + start + ", " + end + ")";
        var final_code = "";

        if(output_type == "period"){
            final_code = "as.period(" + core_interval + ", unit=\\"" + unit + "\\")";
        } else if(output_type == "length"){
            final_code = "lubridate::time_length(" + core_interval + ", unit=\\"" + unit + "\\")";
        } else {
            final_code = core_interval;
        }
        echo("lubridate_interval <- " + final_code + "\\n");
      }
  '
  js_print_interval <- '
    var save_name = getValue("save_interval.objectname");
    echo("rk.header(\\"Create Interval Results\\")\\n");
    echo("rk.header(\\"Result saved to object: " + save_name + "\\", level=3)\\n");
  '
  interval_component <- rk.plugin.component(
      "Create Intervals",
      xml=list(dialog=interval_dialog),
      js=list(require="lubridate", calculate=js_calc_interval, printout=js_print_interval),
      hierarchy=list("data", "Date and Time (lubridate)", "Time Spans")
  )

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
      interval_component
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

})
