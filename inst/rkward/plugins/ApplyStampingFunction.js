// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here

}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

      var date_object = getValue("dt_object");
      var stamp_fun = getValue("stamp_fun_slot");
      if(date_object && stamp_fun){
          echo("formatted_dates <- " + stamp_fun + "(" + date_object + ")\n");
      }
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Apply Stamping Function results")).print();

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

