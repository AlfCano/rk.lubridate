// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here

}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

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
            code += "original_locale <- Sys.getlocale(\"LC_TIME\")\n";
            code += "Sys.setlocale(\"LC_TIME\", \"" + locale + "\")\n";
            code += "tryCatch({\n";
        }

        code += "  formatted_dates <- format(" + date_object + ", format=\"" + format_str + "\")\n";

        if(locale){
            code += "}, finally = {\n";
            code += "  Sys.setlocale(\"LC_TIME\", original_locale)\n";
            code += "})\n";
        }
        echo(code);
    } else if (date_object && !format_str) {
        echo("rk.stop(\"No format string provided. Please select a preset or enter a custom format.\")");
    }
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Format Dates as Text results")).print();

    var save_name = getValue("save_result.objectname");
    echo("rk.header(\"lubridate Operation Results\")\n");
    echo("rk.header(\"Result saved to object: " + save_name + "\", level=3)\n");
  
	//// save result object
	// read in saveobject variables
	var saveResult = getValue("save_result");
	var saveResultActive = getValue("save_result.active");
	var saveResultParent = getValue("save_result.parent");
	// assign object to chosen environment
	if(saveResultActive) {
		echo(".GlobalEnv$" + saveResult + " <- formatted_dates\n");
	}

}

