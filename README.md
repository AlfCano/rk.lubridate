# rk.lubridate: An RKWard Plugin for the 'lubridate' Package

![Version](https://img.shields.io/badge/Version-0.0.3-blue.svg)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

This package provides an RKWard GUI front-end for many of the powerful and user-friendly date and time manipulation functions from the **`lubridate`** package. It allows users to perform common date-time operations without writing code.

## What's New in Version 0.0.3

This version addresses critical bug fixes related to object saving, ensuring predictable and correct behavior across all plugins.

*   **Corrected Object Saving**: Fixed a significant bug where several plugins were not respecting the `initial` object name defined in their user interface. This affected the following plugins:
    *   **Format Dates as Text**: Now correctly saves the result to `formatted_dates` by default, instead of the generic `lubridate_result`.
    *   **Apply Stamping Function**: Also now correctly saves to `formatted_dates` by default.
    *   **Time Span Plugins** (Create Periods, Durations, and Intervals): These now correctly save to `lubridate_period`, `lubridate_duration`, and `lubridate_interval` respectively.
    
    This change ensures that the hard-coded object name in the R script matches the save object name in the UI, adhering to best practices and preventing unexpected behavior.

*   **XML Layout Fix for Previews**: Resolved a fatal error that occurred in some versions of RKWard where the UI dialog for plugins with a preview pane would fail to load. The XML structure has been corrected to ensure compatibility.

## What's New in Version 0.0.2

This version significantly improves the user experience by adding interactive data previews and expanding functionality.

*   **Interactive Data Previews**: Most data transformation plugins now feature a **Preview** button. This allows you to see the result of your operation *before* you click "Submit," ensuring your settings are correct. Previews have been added to:
    *   Parse Date-Times
    *   Format Dates as Text
    *   Apply Stamping Function
    *   Get Component from Date
    *   Round Date-Times
    *   All Time Span creation dialogs (Periods, Durations, and Intervals).
*   **Expanded Parsing Functions**: The main "Parse Date-Times" plugin now includes a comprehensive dropdown list of all `lubridate` parsing functions (e.g., `ymd_hms`, `dmy_hm`, `myd`, etc.), providing much greater flexibility.
*   **Cleaner Output**: The plugins no longer print the entire resulting data object to the output window by default. Instead, they print a clean confirmation message indicating that the object was created and where it was saved, reducing clutter.
*   **Bug Fixes**:
    *   Corrected an issue where manually entering a vector of dates in the "Parse Date-Times" dialog was not working correctly.
    *   Fixed a critical bug where several plugins were saving results to the wrong object name, ensuring consistent and predictable behavior.

## Features

The plugin provides a suite of tools organized under the `Data -> Date and Time (lubridate)` menu in RKWard:

*   **Parse Date-Times with lubridate**: The main plugin dialog. Convert character or numeric data into proper date-time objects by specifying the order of components (e.g., `ymd`, `mdy_hms`).
*   **Format Dates as Text**: Convert date-time objects into character strings using either a preset format (e.g., "YYYY-MM-DD") or a custom R format string (e.g., `"%A, %B %d"`). Includes language/locale selection for international date formats.
*   **Create Stamping Function**: Creates a reusable R function for a specific date format (e.g., `"Hoy es %A, %d-%m-%Y"`). Supports different languages/locales.
*   **Apply Stamping Function**: Uses a previously created stamping function to format a date-time object.
*   **Get Component from Date**: Extract a single component from a date object, such as the year, month, day, or week.
*   **Set Component in Date**: Modify a component of a date object (e.g., change the year to 2025).
*   **Round Date-Times**: Round dates to the nearest, floor, or ceiling of a specified unit (e.g., round to the nearest month).
*   **Work with Time Zones**: Change the time zone of a date-time object.
*   **Time Spans**: A submenu for creating time span objects.
    *   **Create Periods**: Create human-readable time spans (e.g., "2 months").
    *   **Create Durations**: Create exact, second-based time spans (e.g., "172800 seconds").
    *   **Create Intervals**: Create a time span between a start and end date. This powerful component can output:
        1.  A standard `Interval` object.
        2.  A human-readable `Period` object (e.g., "3y 2m 5d").
        3.  A single `numeric` value representing the total time in a chosen unit (e.g., `3.17` years), powered by `lubridate::time_length()`.

## Installation

### Recommended Method: From GitHub

The easiest way to install the plugin is using the `devtools` package in R.

```R
# If you don't have devtools, install it first
# install.packages("devtools")

devtools::install_github("AlfCano/rk.lubridate")
```


## Usage Example: Extracting the Year from a Date Column

This example demonstrates how to use the "Get Component from Date" feature to extract the year from a date column into a new object.

**1. Prepare Sample Data**
First, we'll use the built-in `airmiles` dataset to create a sample data frame. Run this code in the RKWard console:

```R
# Convert the numeric years (e.g., 1937) into a full date string ("1937-01-01")
date_strings <- paste0(time(airmiles), "-01-01")

# Now, create the data frame using the corrected date strings
airmiles_df <- data.frame(
  date = as.Date(date_strings),
  miles = as.numeric(airmiles)
)
```

You will now have a data frame named `airmiles_df` in your workspace with a proper `date` column.

**2. Open the Plugin**
Go to the RKWard menu: `Data -> Date and Time (lubridate) -> Get Component from Date`.

**3. Configure the Dialog**
*   **Select a date-time object**: From the object selector list, choose `airmiles_df$date`.
*   **Component to get**: From the dropdown menu, ensure **Year** is selected.
*   **Save result as**: `airmiles_year`.

**4. Preview the Result (Optional)**
Click the `Preview` button. A new pane will appear showing the first few rows of the result—a column containing the years. This confirms your settings are correct before running the full operation.

**5. Submit**
Click the `Submit` button. A new object named `airmiles_year` will be created in your workspace containing only the years from the date column.

**6. Verify the Result (Optional)**
You can easily add this new vector as a column to your data frame and view the result. In the R console, run:

```R
airmiles_df$year_component <- airmiles_year
head(airmiles_df)
```

## Author and License

*   **Author**: Alfonso Cano Robles, assisted by Gemini a LLM from Google.
*   **Email**: alfonso.cano@correo.buap.mx
*   **License**: GPL (>= 3)
