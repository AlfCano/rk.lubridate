# rk.lubridate: Date & Time Tools for RKWard

![Version](https://img.shields.io/badge/Version-0.0.4-blue.svg)
![License](https://img.shields.io/badge/License-GPL--3-green.svg)
![R Version](https://img.shields.io/badge/R-%3E%3D%203.0.0-lightgrey.svg)

This package provides a suite of RKWard plugins that create a graphical user interface for the **[lubridate](https://lubridate.tidyverse.org/)** R package. It simplifies working with dates and times by providing tools for parsing, formatting, arithmetic, and interval analysis without memorizing format codes or function names.

## Features / Included Plugins

This package installs a new submenu in RKWard: **Data > Date and Time (lubridate)**.

### Core Tools
*   **Parse Date-Times:** Convert strings (e.g., "2023/01/15") into R Date objects using intuitive "Orders" (ymd, mdy, dmy_hms).
*   **Format Dates as Text:** Convert dates back into text strings with presets (e.g., "Friday, November 21") or custom format codes.
*   **Get/Set Components:** Extract or modify specific parts of a date (Year, Month, Weekday, etc.).
*   **Round Date-Times:** Round dates to the nearest minute, hour, month, or custom unit.
*   **Time Zones:** Convert time zones (`with_tz`) or fix incorrect time zones (`force_tz`).

### Time Spans
*   **Create Periods:** Human-readable time spans (e.g., "1 Month") that account for leap years/days.
*   **Create Durations:** Exact time spans in seconds (e.g., "30 Days" = 2592000s).
*   **Create Intervals:** Define a span of time between a Start Date and End Date.

### Calculations (New in v0.0.4)
*   **Shift Dates:** Add or subtract time from a date (e.g., Date + 2 Months).
*   **Check Overlaps:** Check if a date falls inside a specific interval (`%within%`).
*   **Align Dates:** "Rollback" dates to the last day of the previous month, or find the start/end of a month.
*   **Advanced Extractions:** Extract Business quarters, semesters, days of the year, or check for Leap Years.
*   **Decimal Conversion:** Convert dates to decimal years (2023.5) for regression analysis.

## Requirements

1.  A working installation of **RKWard**.
2.  The R package **`lubridate`**.
    ```R
    install.packages("lubridate")
    ```
3.  The R package **`devtools`** (for installation from source).

## Installation

1.  Open R in RKWard.
2.  Run the following commands in the R console:

```R
local({
## Preparar
require(devtools)
## Computar
  install_github(
    repo="AlfCano/rk.lubridate"
  )
## Imprimir el resultado
rk.header ("Resultados de Instalar desde git")
})
```
3.  Restart RKWard to ensure the new menu items appear correctly.

## Usage & Examples

To test the calculation plugins, create the `test_dates` dataframe using the code below:

```R
library(lubridate)
ref_int <- interval(ymd("2023-01-01"), ymd("2023-03-31"))

test_dates <- data.frame(
  id = 1:5,
  event_date = as.Date(c("2023-01-15", "2023-02-28", "2023-03-31", "2024-02-29", "2025-12-25")),
  q1_2023 = rep(ref_int, 5) # Quarter 1 2023 Interval
)
```

### Example 1: Shift Dates (Add 1 Month)
1.  Navigate to **Data > Date and Time (lubridate) > Calculations > Shift Dates**.
2.  **Select Date Object:** `test_dates$event_date`.
3.  **Operation:** Add (+).
4.  **Amount:** 1.
5.  **Unit:** Months.
6.  **Time Type:** Period.
7.  Click **Submit**.
    *   *Result:* Jan 15 becomes Feb 15. Feb 28 becomes Mar 28.

### Example 2: Check Overlaps
1.  Navigate to **Data > Date and Time (lubridate) > Calculations > Check Overlaps**.
2.  **Date Object:** `test_dates$event_date`.
3.  **Interval Object:** `test_dates$q1_2023`.
4.  Click **Submit**.
    *   *Result:* Returns `TRUE` for the dates in Jan, Feb, Mar 2023. Returns `FALSE` for 2024 and 2025.

### Example 3: Align Dates (Rollback)
1.  Navigate to **Data > Date and Time (lubridate) > Calculations > Align Dates**.
2.  **Date Object:** `test_dates$event_date`.
3.  **Action:** Rollback (Last day of prev month).
4.  Click **Submit**.
    *   *Result:* "2023-01-15" becomes "2022-12-31". Useful for aligning financial reports.

## Author

Alfonso Cano Robles (alfonso.cano@correo.buap.mx)

Assisted by Gemini, a large language model from Google.
